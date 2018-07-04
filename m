Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F54F6B0007
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 08:11:11 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d10-v6so2356773pgv.8
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 05:11:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x10-v6si3288214pln.427.2018.07.04.05.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 05:11:10 -0700 (PDT)
Date: Wed, 4 Jul 2018 14:11:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180704121107.GL22503@dhcp22.suse.cz>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

On Wed 04-07-18 07:48:27, Zi Yan wrote:
> On 4 Jul 2018, at 7:17, Michal Hocko wrote:
> 
> > On Wed 04-07-18 19:01:51, Tetsuo Handa wrote:
> >> +Michal Hocko
> >>
> >> On 2018/07/04 13:19, syzbot wrote:
> >>> Hello,
> >>>
> >>> syzbot found the following crash on:
> >>>
> >>> HEAD commit:    d3bc0e67f852 Merge tag 'for-4.18-rc2-tag' of git://git.ker..
> >>> git tree:       upstream
> >>> console output: https://syzkaller.appspot.com/x/log.txt?x=1000077c400000
> >>> kernel config:  https://syzkaller.appspot.com/x/.config?x=a63be0c83e84d370
> >>> dashboard link: https://syzkaller.appspot.com/bug?extid=5dcb560fe12aa5091c06
> >>> compiler:       gcc (GCC) 8.0.1 20180413 (experimental)
> >>> userspace arch: i386
> >>> syzkaller repro:https://syzkaller.appspot.com/x/repro.syz?x=158577a2400000
> >>
> >> Here is C reproducer made from syz reproducer. mlockall(MCL_FUTURE) is involved.
> >>
> >> This problem is triggerable by an unprivileged user.
> >> Shows different result on x86_64 (crash) and x86_32 (stall).
> >>
> >> ------------------------------------------------------------
> >> /* Need to compile using "-m32" option if host is 64bit. */
> >> #include <sys/types.h>
> >> #include <sys/stat.h>
> >> #include <fcntl.h>
> >> #include <unistd.h>
> >> #include <sys/mman.h>
> >> int uselib(const char *library);
> >>
> >> int main(int argc, char *argv[])
> >> {
> >> 	int fd = open("file", O_WRONLY | O_CREAT, 0644);
> >> 	write(fd, "\x7f\x45\x4c\x46\x00\x80\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02"
> >> 	      "\x00\x06\x00\xca\x3f\x8b\xca\x00\x00\x00\x00\x38\x00\x00\x00\x00\x00"
> >> 	      "\x00\xf7\xff\xff\xff\xff\xff\xff\x1f\x00\x02\x00\x00\x00\x00\x00\x00"
> >> 	      "\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\xf8\x7b"
> >> 	      "\x66\xff\x00\x00\x05\x00\x00\x00\x76\x86\x00\x00\x00\x00\x00\x00\x00"
> >> 	      "\x00\x00\x00\x31\x0f\xf3\xee\xc1\xb0\x00\x0c\x08\x53\x55\xbe\x88\x47"
> >> 	      "\xc2\x2e\x30\xf5\x62\x82\xc6\x2c\x95\x72\x3f\x06\x8f\xe4\x2d\x27\x96"
> >> 	      "\xcc", 120);
> >> 	fchmod(fd, 0755);
> >> 	close(fd);
> >> 	mlockall(MCL_FUTURE); /* Removing this line avoids the bug. */
> >> 	uselib("file");
> >> 	return 0;
> >> }
> >> ------------------------------------------------------------
> >>
> >> ------------------------------------------------------------
> >> CentOS Linux 7 (Core)
> >> Kernel 4.18.0-rc3 on an x86_64
> >>
> >> localhost login: [   81.210241] emacs (9634) used greatest stack depth: 10416 bytes left
> >> [  140.099935] ------------[ cut here ]------------
> >> [  140.101904] kernel BUG at mm/gup.c:1242!
> >
> > Is this
> > 	VM_BUG_ON(len != PAGE_ALIGN(len));
> > in __mm_populate? I do not really get why we should VM_BUG_ON when the
> > len is not page aligned to be honest. The library is probably containing
> > some funky setup but if we simply cannot round up to the next PAGE_SIZE
> > boundary then we should probably just error out and fail. This is an
> > area I am really familiar with so I cannot really judge.
> 
> A strange thing is that __mm_populate() is only called by do_mlock() from mm/mlock.c,
> which makes len PAGE_ALIGN already. That VM_BUG_ON should not be triggered.

Not really. vm_brk_flags does call mm_populate for mlocked brk which is
the case for mlockall. I do not see any len sanitization in that path.
Well do_brk_flags does the roundup. I think we should simply remove the
bug on and round up there. mm_populate is an internal API and we should
trust our callers.

Anyway, the minimum fix seems to be the following (untested):

diff --git a/mm/mmap.c b/mm/mmap.c
index 9859cd4e19b9..56ad19cf2aea 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -186,8 +186,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 	return next;
 }
 
-static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf);
-
+static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags,
+		struct list_head *uf);
 SYSCALL_DEFINE1(brk, unsigned long, brk)
 {
 	unsigned long retval;
@@ -245,7 +245,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 		goto out;
 
 	/* Ok, looks good - let it rip. */
-	if (do_brk(oldbrk, newbrk-oldbrk, &uf) < 0)
+	if (do_brk_flags(oldbrk, newbrk-oldbrk, 0, &uf) < 0)
 		goto out;
 
 set_brk:
@@ -2939,12 +2939,6 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	pgoff_t pgoff = addr >> PAGE_SHIFT;
 	int error;
 
-	len = PAGE_ALIGN(request);
-	if (len < request)
-		return -ENOMEM;
-	if (!len)
-		return 0;
-
 	/* Until we need other flags, refuse anything except VM_EXEC. */
 	if ((flags & (~VM_EXEC)) != 0)
 		return -EINVAL;
@@ -3016,18 +3010,20 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	return 0;
 }
 
-static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf)
-{
-	return do_brk_flags(addr, len, 0, uf);
-}
-
-int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
+int vm_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
 {
 	struct mm_struct *mm = current->mm;
+	unsigned long len;
 	int ret;
 	bool populate;
 	LIST_HEAD(uf);
 
+	len = PAGE_ALIGN(request);
+	if (len < request)
+		return -ENOMEM;
+	if (!len)
+		return 0;
+
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
-- 
Michal Hocko
SUSE Labs
