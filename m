Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2557A600373
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 02:48:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o386mPkp002199
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 8 Apr 2010 15:48:25 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 12AA145DE4F
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:48:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF5C945DE4D
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:48:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9858AE78003
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:48:24 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A8D9E38003
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 15:48:24 +0900 (JST)
Date: Thu, 8 Apr 2010 15:44:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 -mmotm 2/2] memcg: move charge of file pages
Message-Id: <20100408154434.0f87bddf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100408141131.6bf5fd1a.nishimura@mxp.nes.nec.co.jp>
References: <20100408140922.422b21b0.nishimura@mxp.nes.nec.co.jp>
	<20100408141131.6bf5fd1a.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Apr 2010 14:11:31 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> This patch adds support for moving charge of file pages, which include normal
> file, tmpfs file and swaps of tmpfs file. It's enabled by setting bit 1 of
> <target cgroup>/memory.move_charge_at_immigrate. Unlike the case of anonymous
> pages, file pages(and swaps) in the range mmapped by the task will be moved even
> if the task hasn't done page fault, i.e. they might not be the task's "RSS",
> but other task's "RSS" that maps the same file. And mapcount of the page is
> ignored(the page can be moved even if page_mapcount(page) > 1). So, conditions
> that the page/swap should be met to be moved is that it must be in the range
> mmapped by the target task and it must be charged to the old cgroup.
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  Documentation/cgroups/memory.txt |   12 ++++++--
>  include/linux/swap.h             |    5 +++
>  mm/memcontrol.c                  |   55 +++++++++++++++++++++++++++++--------
>  mm/shmem.c                       |   37 +++++++++++++++++++++++++
>  4 files changed, 94 insertions(+), 15 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 1b5bd04..13d40e7 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -461,14 +461,20 @@ charges should be moved.
>     0  | A charge of an anonymous page(or swap of it) used by the target task.
>        | Those pages and swaps must be used only by the target task. You must
>        | enable Swap Extension(see 2.4) to enable move of swap charges.
> + -----+------------------------------------------------------------------------
> +   1  | A charge of file pages(normal file, tmpfs file(e.g. ipc shared memory)
> +      | and swaps of tmpfs file) mmaped by the target task. Unlike the case of
> +      | anonymous pages, file pages(and swaps) in the range mmapped by the task
> +      | will be moved even if the task hasn't done page fault, i.e. they might
> +      | not be the task's "RSS", but other task's "RSS" that maps the same file.
> +      | And mapcount of the page is ignored(the page can be moved even if
> +      | page_mapcount(page) > 1). You must enable Swap Extension(see 2.4) to
> +      | enable move of swap charges.
>  
>  Note: Those pages and swaps must be charged to the old cgroup.
> -Note: More type of pages(e.g. file cache, shmem,) will be supported by other
> -      bits in future.
>  

About both of documenataion for 0 and 1, I think following information is omitted.

 "An account of a page of task is moved only when it's under task's current memory cgroup."

Plz add somewhere easy-to-be-found.

But ok, the patch itself much simpler. Thank you for your patient works!

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
