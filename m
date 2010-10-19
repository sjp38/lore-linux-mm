Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E8EE6B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:35:40 -0400 (EDT)
Date: Tue, 19 Oct 2010 10:35:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101019023537.GB8310@localhost>
References: <20101019093142.509d6947@notabene>
 <20101018154137.90f5325f.akpm@linux-foundation.org>
 <20101019095144.A1B0.A69D9226@jp.fujitsu.com>
 <AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> @@ -2054,10 +2069,11 @@ rebalance:
>                 goto got_pg;
> 
>         /*
> -        * If we failed to make any progress reclaiming, then we are
> -        * running out of options and have to consider going OOM
> +        * If we failed to make any progress reclaiming and there aren't
> +        * many parallel reclaiming, then we are unning out of options and
> +        * have to consider going OOM
>          */
> -       if (!did_some_progress) {
> +       if (!did_some_progress && !too_many_isolated_zone(preferred_zone)) {
>                 if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
>                         if (oom_killer_disabled)
>                                 goto nopage;

This is simply wrong.

It disabled this block for 99% system because there won't be enough
tasks to make (!too_many_isolated_zone == true). As a result the LRU
will be scanned like mad and no task get OOMed when it should be.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
