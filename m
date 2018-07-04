Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C032F6B027B
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:15:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f13-v6so1889643wmb.4
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:15:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b21-v6sor440408wme.76.2018.07.04.08.15.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 08:15:31 -0700 (PDT)
Date: Wed, 4 Jul 2018 17:15:29 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: kernel BUG at mm/gup.c:LINE!
Message-ID: <20180704151529.GA23317@techadventures.net>
References: <000000000000fe4b15057024bacd@google.com>
 <da0f4abb-9401-cfac-6332-9086aadf67eb@I-love.SAKURA.ne.jp>
 <20180704111731.GJ22503@dhcp22.suse.cz>
 <FB141DA1-F8B8-4E9A-84E5-176B07463AEB@cs.rutgers.edu>
 <20180704121107.GL22503@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180704121107.GL22503@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, syzbot <syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, mst@redhat.com, syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, ying.huang@intel.com

> 
> Not really. vm_brk_flags does call mm_populate for mlocked brk which is
> the case for mlockall. I do not see any len sanitization in that path.
> Well do_brk_flags does the roundup. I think we should simply remove the
> bug on and round up there. mm_populate is an internal API and we should
> trust our callers.
> 
> Anyway, the minimum fix seems to be the following (untested):
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 9859cd4e19b9..56ad19cf2aea 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -186,8 +186,8 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
>  	return next;
>  }
>  
> -static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf);
> -
> +static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long flags,
> +		struct list_head *uf);
>  SYSCALL_DEFINE1(brk, unsigned long, brk)
>  {
>  	unsigned long retval;
> @@ -245,7 +245,7 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
>  		goto out;
>  
>  	/* Ok, looks good - let it rip. */
> -	if (do_brk(oldbrk, newbrk-oldbrk, &uf) < 0)
> +	if (do_brk_flags(oldbrk, newbrk-oldbrk, 0, &uf) < 0)
>  		goto out;
>  
>  set_brk:
> @@ -2939,12 +2939,6 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  	pgoff_t pgoff = addr >> PAGE_SHIFT;
>  	int error;
>  
> -	len = PAGE_ALIGN(request);
> -	if (len < request)
> -		return -ENOMEM;
> -	if (!len)
> -		return 0;
> -
>  	/* Until we need other flags, refuse anything except VM_EXEC. */
>  	if ((flags & (~VM_EXEC)) != 0)
>  		return -EINVAL;
> @@ -3016,18 +3010,20 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
>  	return 0;
>  }
>  
> -static int do_brk(unsigned long addr, unsigned long len, struct list_head *uf)
> -{
> -	return do_brk_flags(addr, len, 0, uf);
> -}
> -
> -int vm_brk_flags(unsigned long addr, unsigned long len, unsigned long flags)
> +int vm_brk_flags(unsigned long addr, unsigned long request, unsigned long flags)
>  {
>  	struct mm_struct *mm = current->mm;
> +	unsigned long len;
>  	int ret;
>  	bool populate;
>  	LIST_HEAD(uf);
>  
> +	len = PAGE_ALIGN(request);
> +	if (len < request)
> +		return -ENOMEM;
> +	if (!len)
> +		return 0;
> +
>  	if (down_write_killable(&mm->mmap_sem))
>  		return -EINTR;

I gave this patch a try but the system doesn't boot.
Unfortunately, I don't have the stacktrace on hand, but I'll get back to it tomorrow.

Anyway, I just gave it a try, and making sure that bss gets page aligned seems to
"fix" the issue (at the process doesn't hang anymore):

-       bss = eppnt->p_memsz + eppnt->p_vaddr;
+       bss = ELF_PAGESTART(eppnt->p_memsz + eppnt->p_vaddr);
	if (bss > len) {
                error = vm_brk(len, bss - len);

Although I'm not sure about the correctness of this.

-- 
Oscar Salvador
SUSE L3
