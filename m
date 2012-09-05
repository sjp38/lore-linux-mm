Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A233A6B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 23:22:20 -0400 (EDT)
Message-ID: <5046C4E7.5040407@cn.fujitsu.com>
Date: Wed, 05 Sep 2012 11:20:07 +0800
From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Reply-To: gaowanlong@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix mmap overflow checking
References: <1346750580-11352-1-git-send-email-gaowanlong@cn.fujitsu.com> <20120904135924.b61e04e0.akpm@linux-foundation.org>
In-Reply-To: <20120904135924.b61e04e0.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, open@kvack.org, list@kvack.org, MEMORY MANAGEMENT <linux-mm@kvack.org>

On 09/05/2012 04:59 AM, Andrew Morton wrote:
> On Tue, 4 Sep 2012 17:23:00 +0800
> Wanlong Gao <gaowanlong@cn.fujitsu.com> wrote:
> 
>> POSIX said that if the file is a regular file and the value of "off"
>> plus "len" exceeds the offset maximum established in the open file
>> description associated with fildes, mmap should return EOVERFLOW.
> 
> That's what POSIX says, but what does Linux do?  It is important that

Current Linux checks whether the shifted off+len exceed ULONG_MAX, it seems
never happen.

> we precisely describe and understand the behaviour change, as there is
> potential here to break existing applications.
> 
> I'm assuming that Linux presently permits the mmap() and then generates
> SIGBUS if an access is attempted beyond the max file size?

What I saw is ENOMEM because the "len" here is too large.
 
> 
>> 	/* offset overflow? */
>> -	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
>> -               return -EOVERFLOW;
>> +	if (off + len < off)
>> +		return -EOVERFLOW;
> 
> Well, this treats sizeof(off_t) as the "offset maximum established in
> the open file".  But from my reading of the above excerpt, we should in
> fact be checking against the underlying fs's s_maxbytes?

More reasonable, how about following?

---
 mm/mmap.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index ae18a48..4d7bc64 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -980,6 +980,10 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
 	vm_flags_t vm_flags;
+	loff_t off = pgoff << PAGE_SHIFT;
+	loff_t maxbytes = -1;
+	if (file)
+		maxbytes = file->f_mapping->host->i_sb->s_maxbytes;
 
 	/*
 	 * Does the application expect PROT_READ to imply PROT_EXEC?
@@ -1003,8 +1007,8 @@ unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 		return -ENOMEM;
 
 	/* offset overflow? */
-	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
-               return -EOVERFLOW;
+	if (off + len > maxbytes)
+		return -EOVERFLOW;
 
 	/* Too many mappings? */
 	if (mm->map_count > sysctl_max_map_count)
-- 

Thanks,
Wanlong Gao

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
