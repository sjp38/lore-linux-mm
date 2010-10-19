Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A7ED76B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 23:05:21 -0400 (EDT)
Date: Tue, 19 Oct 2010 11:05:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
Message-ID: <20101019030515.GB11924@localhost>
References: <20101019093142.509d6947@notabene>
 <20101018154137.90f5325f.akpm@linux-foundation.org>
 <20101019095144.A1B0.A69D9226@jp.fujitsu.com>
 <AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
 <20101019023537.GB8310@localhost>
 <AANLkTikHxDyjOGgM8-X6FNT15Hr3s4NaA-=+FRhma+3D@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTikHxDyjOGgM8-X6FNT15Hr3s4NaA-=+FRhma+3D@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 10:52:47AM +0800, Minchan Kim wrote:
> Hi Wu,
> 
> On Tue, Oct 19, 2010 at 11:35 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> @@ -2054,10 +2069,11 @@ rebalance:
> >> A  A  A  A  A  A  A  A  goto got_pg;
> >>
> >> A  A  A  A  /*
> >> - A  A  A  A * If we failed to make any progress reclaiming, then we are
> >> - A  A  A  A * running out of options and have to consider going OOM
> >> + A  A  A  A * If we failed to make any progress reclaiming and there aren't
> >> + A  A  A  A * many parallel reclaiming, then we are unning out of options and
> >> + A  A  A  A * have to consider going OOM
> >> A  A  A  A  A */
> >> - A  A  A  if (!did_some_progress) {
> >> + A  A  A  if (!did_some_progress && !too_many_isolated_zone(preferred_zone)) {
> >> A  A  A  A  A  A  A  A  if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
> >> A  A  A  A  A  A  A  A  A  A  A  A  if (oom_killer_disabled)
> >> A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  goto nopage;
> >
> > This is simply wrong.
> >
> > It disabled this block for 99% system because there won't be enough
> > tasks to make (!too_many_isolated_zone == true). As a result the LRU
> > will be scanned like mad and no task get OOMed when it should be.
> 
> If !too_many_isolated_zone is false, it means there are already many
> direct reclaiming tasks.
> So they could exit reclaim path and !too_many_isolated_zone will be true.
> What am I missing now?

Ah sorry, my brain get short circuited.. but I still feel uneasy with
this change. It's not fixing the root cause and won't prevent too many
LRU pages be isolated. It's too late to test too_many_isolated_zone()
after direct reclaim returns (after sleeping for a long time).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
