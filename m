Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id ED79F6B007E
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 02:09:59 -0500 (EST)
Received: by bkty12 with SMTP id y12so5677296bkt.14
        for <linux-mm@kvack.org>; Sun, 19 Feb 2012 23:09:58 -0800 (PST)
Message-ID: <4F41F1C2.3030908@openvz.org>
Date: Mon, 20 Feb 2012 11:09:54 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: Fine granularity page reclaim
References: <20120217092205.GA9462@gmail.com> <4F3EB675.9030702@openvz.org> <20120220062006.GA5028@gmail.com>
In-Reply-To: <20120220062006.GA5028@gmail.com>
Content-Type: multipart/mixed;
 boundary="------------010609060400070508090203"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernl@vger.kernel.org" <linux-kernl@vger.kernel.org>

This is a multi-part message in MIME format.
--------------010609060400070508090203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Zheng Liu wrote:
> Cc linux-kernel mailing list.
>
> On Sat, Feb 18, 2012 at 12:20:05AM +0400, Konstantin Khlebnikov wrote:
>> Zheng Liu wrote:
>>> Hi all,
>>>
>>> Currently, we encounter a problem about page reclaim. In our product system,
>>> there is a lot of applictions that manipulate a number of files. In these
>>> files, they can be divided into two categories. One is index file, another is
>>> block file. The number of index files is about 15,000, and the number of
>>> block files is about 23,000 in a 2TB disk. The application accesses index
>>> file using mmap(2), and read/write block file using pread(2)/pwrite(2). We hope
>>> to hold index file in memory as much as possible, and it works well in Redhat
>>> 2.6.18-164. It is about 60-70% of index files that can be hold in memory.
>>> However, it doesn't work well in Redhat 2.6.32-133. I know in 2.6.18 that the
>>> linux uses an active list and an inactive list to handle page reclaim, and in
>>> 2.6.32 that they are divided into anonymous list and file list. So I am
>>> curious about why most of index files can be hold in 2.6.18? The index file
>>> should be replaced because mmap doesn't impact the lru list.
>>
>> There was my patch for fixing similar problem with shared/executable mapped pages
>> "vmscan: promote shared file mapped pages" commit 34dbc67a644f and commit c909e99364c
>> maybe it will help in your case.
>
> Hi Konstantin,
>
> Thank you for your reply.  I have tested it in upstream kernel.  These
> patches are useful for multi-processes applications.  But, in our product
> system, there are some applications that are multi-thread.  So
> 'references_ptes>  1' cannot help these applications to hold the data in
> memory.

Ok, what if you mmap you data as executable, just to test.
Then these pages will be activated after first touch.
In attachment patch with per-mm flag with the same effect.

>
> Regards,
> Zheng
>
>>
>>>
>>> BTW, I have some problems that need to be discussed.
>>>
>>> 1. I want to let index and block files are separately reclaimed. Is there any
>>> ways to satisify me in current upstream?
>>>
>>> 2. Maybe we can provide a mechansim to let different files to be mapped into
>>> differnet nodes. we can provide a ioctl(2) to tell kernel that this file should
>>> be mapped into a specific node id. A nid member is added into addpress_space
>>> struct. When alloc_page is called, the page can be allocated from that specific
>>> node id.
>>>
>>> 3. Currently the page can be reclaimed according to pid in memcg. But it is too
>>> coarse. I don't know whether memcg could provide a fine granularity page
>>> reclaim mechansim. For example, the page is reclaimed according to inode number.
>>>
>>> I don't subscribe this mailing list, So please Cc me. Thank you.
>>>
>>> Regards,
>>> Zheng
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
>>> Don't email:<a href=mailto:"dont@kvack.org">   email@kvack.org</a>
>>


--------------010609060400070508090203
Content-Type: text/plain;
 name="mm-introduce-mmf_vm_preferrded-flag"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mm-introduce-mmf_vm_preferrded-flag"

mm: introduce MMF_VM_PREFERRDED flag

From: Konstantin Khlebnikov <khlebnikov@openvz.org>

This patch introduce mm->flags bit: MMF_VM_PREFERRED,
which doubles access bit weight for this mm.

Currently the only one effect:
mm with this bit activates mapped file pages after first touch,
if vma does not marked as sequentially accessed.

This should be per-vma sign, but there no free bits in vma->vm_flags,
maybe we can make this stuff 64-only.

interface:
prctl(PR_SET_MM_PREFERRED, 1) to set and
prctl(PR_SET_MM_PREFERRED, 0) to clear.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 include/linux/prctl.h |    2 ++
 include/linux/sched.h |    1 +
 kernel/sys.c          |   17 +++++++++++++++++
 mm/rmap.c             |    5 ++++-
 4 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/include/linux/prctl.h b/include/linux/prctl.h
index 7ddc7f1..d0f9ceb 100644
--- a/include/linux/prctl.h
+++ b/include/linux/prctl.h
@@ -114,4 +114,6 @@
 # define PR_SET_MM_START_BRK		6
 # define PR_SET_MM_BRK			7
 
+#define PR_SET_MM_PREFERRED	36
+
 #endif /* _LINUX_PRCTL_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 75c15c5..b60883a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -437,6 +437,7 @@ extern int get_dumpable(struct mm_struct *mm);
 					/* leave room for more dump flags */
 #define MMF_VM_MERGEABLE	16	/* KSM may merge identical pages */
 #define MMF_VM_HUGEPAGE		17	/* set when VM_HUGEPAGE is set on vma */
+#define MMF_VM_PREFERRED	18	/* Double pte access bits weight */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/kernel/sys.c b/kernel/sys.c
index 4070153..bacf8d5 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -1810,6 +1810,20 @@ static int prctl_set_mm(int opt, unsigned long addr,
 }
 #endif
 
+static int set_mm_preferred(struct mm_struct *mm, int state)
+{
+	switch (state) {
+		case 0:
+			clear_bit(MMF_VM_PREFERRED, &mm->flags);
+			return 0;
+		case 1:
+			set_bit(MMF_VM_PREFERRED, &mm->flags);
+			return 0;
+		default:
+			return -EINVAL;
+	}
+}
+
 SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		unsigned long, arg4, unsigned long, arg5)
 {
@@ -1962,6 +1976,9 @@ SYSCALL_DEFINE5(prctl, int, option, unsigned long, arg2, unsigned long, arg3,
 		case PR_SET_MM:
 			error = prctl_set_mm(arg2, arg3, arg4, arg5);
 			break;
+		case PR_SET_MM_PREFERRED:
+			error = set_mm_preferred(me->mm, arg2);
+			break;
 		default:
 			error = -EINVAL;
 			break;
diff --git a/mm/rmap.c b/mm/rmap.c
index 78cc46b..b0fd1d1 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -766,8 +766,11 @@ int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 
 	(*mapcount)--;
 
-	if (referenced)
+	if (referenced) {
+		if (test_bit(MMF_VM_PREFERRED, &mm->flags))
+			referenced <<= 1;
 		*vm_flags |= vma->vm_flags;
+	}
 out:
 	return referenced;
 }

--------------010609060400070508090203--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
