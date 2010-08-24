Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E3ABD6B0386
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:00:57 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7O00tKD026791
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 24 Aug 2010 09:00:56 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8A49545DE4F
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 09:00:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 56FDE45DE4C
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 09:00:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 19F391DB8017
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 09:00:55 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C3D111DB8013
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 09:00:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on dirty_ratio
In-Reply-To: <20100823062359.GA19586@localhost>
References: <20100823144248.15fbb700@notabene> <20100823062359.GA19586@localhost>
Message-Id: <20100824085812.F3AD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 24 Aug 2010 09:00:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Neil Brown <neilb@suse.de>, Con Kolivas <kernel@kolivas.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, "david@fromorbit.com" <david@fromorbit.com>, "hch@lst.de" <hch@lst.de>, "axboe@kernel.dk" <axboe@kernel.dk>
List-ID: <linux-mm.kvack.org>

> writeback: remove the internal 5% low bound on dirty_ratio
> 
> The dirty_ratio was silently limited in global_dirty_limits() to >= 5%. This
> is not a user expected behavior. And it's inconsistent with calc_period_shift(),
> which uses the plain vm_dirty_ratio value. So let's rip the internal bound.
> 
> At the same time, force a user visible low bound of 1% for the vm.dirty_ratio
> interface. Applications trying to write 0 will be rejected with -EINVAL. This
> will break user space applications if they
> 1) try to write 0 to vm.dirty_ratio
> 2) and check the return value
> That is very weird combination, so the risk of breaking user space is low.

I'm ok this one too. because I bet nobody use 0% dirty ratio on their production
server and/or their own desktop. (i.e. I don't mind lab machine crash)

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

> 
> CC: Jan Kara <jack@suse.cz>
> CC: Neil Brown <neilb@suse.de>
> CC: Rik van Riel <riel@redhat.com>
> CC: Con Kolivas <kernel@kolivas.org>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  kernel/sysctl.c     |    2 +-
>  mm/page-writeback.c |   10 ++--------
>  2 files changed, 3 insertions(+), 9 deletions(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-08-20 20:14:11.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-08-23 10:31:01.000000000 +0800
> @@ -415,14 +415,8 @@ void global_dirty_limits(unsigned long *
>  
>  	if (vm_dirty_bytes)
>  		dirty = DIV_ROUND_UP(vm_dirty_bytes, PAGE_SIZE);
> -	else {
> -		int dirty_ratio;
> -
> -		dirty_ratio = vm_dirty_ratio;
> -		if (dirty_ratio < 5)
> -			dirty_ratio = 5;
> -		dirty = (dirty_ratio * available_memory) / 100;
> -	}
> +	else
> +		dirty = (vm_dirty_ratio * available_memory) / 100;
>  
>  	if (dirty_background_bytes)
>  		background = DIV_ROUND_UP(dirty_background_bytes, PAGE_SIZE);
> --- linux-next.orig/kernel/sysctl.c	2010-08-23 14:06:11.000000000 +0800
> +++ linux-next/kernel/sysctl.c	2010-08-23 14:07:30.000000000 +0800
> @@ -1029,7 +1029,7 @@ static struct ctl_table vm_table[] = {
>  		.maxlen		= sizeof(vm_dirty_ratio),
>  		.mode		= 0644,
>  		.proc_handler	= dirty_ratio_handler,
> -		.extra1		= &zero,
> +		.extra1		= &one,
>  		.extra2		= &one_hundred,
>  	},
>  	{



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
