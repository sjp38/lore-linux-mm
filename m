Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BCA78E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:34:47 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id d6so2321855wrm.19
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 22:34:47 -0800 (PST)
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id f3si23989375wrp.49.2019.01.15.22.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 22:34:46 -0800 (PST)
Date: Wed, 16 Jan 2019 07:34:30 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
Message-ID: <20190116063430.GA22938@nautica>
References: <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com>
 <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica>
 <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
Content-Disposition: inline
In-Reply-To: <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Linus Torvalds wrote on Wed, Jan 16, 2019:
> Anybody willing to test the above patch instead? And replace the
> 
>    || capable(CAP_SYS_ADMIN)
> 
> check with something like
> 
>    || inode_permission(inode, MAY_WRITE) == 0
> 
> instead?
> 
> (This is obviously after you've reverted the "only check mmap
> residency" patch..)

That seems to work on an x86_64 vm.

I've tested with the attached patch:
 - root can lookup pages on any file I tried;
 - user can lookup page on file it owns, assuming it can write to it
(e.g. it won't work on a 0400 file you own)
 - user cannot lookup pages on e.g. /lib64/libc-2.28.so

There is a difference with your previous patch though, that used to list
no page in core when it didn't know; this patch lists pages as in core
when it refuses to tell. I don't think that's very important, though.

If anything, the 0400 user-owner file might be a problem in some edge
case (e.g. if you're preloading git directories, many objects are 0444);
should we *also* check ownership?...

-- 
Dominique

--BOKacYhQ+x31HxR3
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="mincore.diff"

 mm/mincore.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..11ed7064f4eb 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -169,6 +169,13 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 	return 0;
 }
 
+static inline bool can_do_mincore(struct vm_area_struct *vma)
+{
+	return vma_is_anonymous(vma)
+		|| (vma->vm_file && (vma->vm_file->f_mode & FMODE_WRITE))
+		|| inode_permission(file_inode(vma->vm_file), MAY_WRITE) == 0;
+}
+
 /*
  * Do a chunk of "sys_mincore()". We've already checked
  * all the arguments, we hold the mmap semaphore: we should
@@ -189,8 +196,13 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
-	mincore_walk.mm = vma->vm_mm;
 	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
+	if (!can_do_mincore(vma)) {
+		unsigned long pages = (end - addr) >> PAGE_SHIFT;
+		memset(vec, 1, pages);
+		return pages;
+	}
+	mincore_walk.mm = vma->vm_mm;
 	err = walk_page_range(addr, end, &mincore_walk);
 	if (err < 0)
 		return err;

--BOKacYhQ+x31HxR3--
