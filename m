Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 06D026B0048
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 07:12:24 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mBJCEXkt001592
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 19 Dec 2008 21:14:33 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DDD145DE50
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 21:14:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0310345DD7A
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 21:14:33 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DDA061DB8013
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 21:14:32 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 90BC51DB8016
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 21:14:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: Corruption with O_DIRECT and unaligned user buffers
In-Reply-To: <494B8AD5.3090901@cn.fujitsu.com>
References: <20081218152952.GW24856@random.random> <494B8AD5.3090901@cn.fujitsu.com>
Message-Id: <20081219210242.ECC4.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 19 Dec 2008 21:14:31 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Tim LaBerge <tim.laberge@quantum.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Wang Chen <wangchen@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > diff -ur rhel-5.2/kernel/fork.c x/kernel/fork.c
> > --- rhel-5.2/kernel/fork.c	2008-07-10 17:26:43.000000000 +0200
> > +++ x/kernel/fork.c	2008-12-18 15:57:31.000000000 +0100
> > @@ -368,7 +368,7 @@
> >  		rb_parent = &tmp->vm_rb;
> >  
> >  		mm->map_count++;
> > -		retval = copy_page_range(mm, oldmm, mpnt);
> > +		retval = copy_page_range(mm, oldmm, tmp);
> >  
> 
> Could you explain a bit why this change is needed?

maybe..

__handle_mm_fault() change rmap of passwd vma.
we need to parent process has original page, child process has new page.
then we need child vma.


> Seems this is a revert of the following commit:
> 
> commit 0b0db14c536debd92328819fe6c51a49717e8440
> Author: Hugh Dickins <hugh@veritas.com>
> Date:   Mon Nov 21 21:32:20 2005 -0800
> 
>     [PATCH] unpaged: copy_page_range vma
> 
>     For copy_one_pte's print_bad_pte to show the task correctly (instead of
>     "???"), dup_mmap must pass down parent vma rather than child vma.

I think you are right.
This patch reintroduce the same problem.

end up, print_bad_pte() need parent vma.
__handle_mm_fault() need child vma.

corrent?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
