Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 616996B0297
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 08:39:46 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id n4so39636946qte.18
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 05:39:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r53si17897426qta.258.2017.04.24.05.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 05:39:45 -0700 (PDT)
Date: Mon, 24 Apr 2017 14:39:40 +0200
From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170424123936.GA6152@redhat.com>
References: <20170307133057.26182-1-mhocko@kernel.org>
 <1488916356.6405.4.camel@redhat.com>
 <20170309180540.GA8678@cmpxchg.org>
 <20170310102010.GD3753@dhcp22.suse.cz>
 <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
 <201704231924.GDF05718.LQSMtJOOFOFHFV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704231924.GDF05718.LQSMtJOOFOFHFV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com

On Sun, Apr 23, 2017 at 07:24:21PM +0900, Tetsuo Handa wrote:
> On 2017/03/10 20:44, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> >> On Thu 09-03-17 13:05:40, Johannes Weiner wrote:
> >>> On Tue, Mar 07, 2017 at 02:52:36PM -0500, Rik van Riel wrote:
> >>>> It only does this to some extent.  If reclaim made
> >>>> no progress, for example due to immediately bailing
> >>>> out because the number of already isolated pages is
> >>>> too high (due to many parallel reclaimers), the code
> >>>> could hit the "no_progress_loops > MAX_RECLAIM_RETRIES"
> >>>> test without ever looking at the number of reclaimable
> >>>> pages.
> >>>
> >>> Hm, there is no early return there, actually. We bump the loop counter
> >>> every time it happens, but then *do* look at the reclaimable pages.
> >>>
> >>>> Could that create problems if we have many concurrent
> >>>> reclaimers?
> >>>
> >>> With increased concurrency, the likelihood of OOM will go up if we
> >>> remove the unlimited wait for isolated pages, that much is true.
> >>>
> >>> I'm not sure that's a bad thing, however, because we want the OOM
> >>> killer to be predictable and timely. So a reasonable wait time in
> >>> between 0 and forever before an allocating thread gives up under
> >>> extreme concurrency makes sense to me.
> >>>
> >>>> It may be OK, I just do not understand all the implications.
> >>>>
> >>>> I like the general direction your patch takes the code in,
> >>>> but I would like to understand it better...
> >>>
> >>> I feel the same way. The throttling logic doesn't seem to be very well
> >>> thought out at the moment, making it hard to reason about what happens
> >>> in certain scenarios.
> >>>
> >>> In that sense, this patch isn't really an overall improvement to the
> >>> way things work. It patches a hole that seems to be exploitable only
> >>> from an artificial OOM torture test, at the risk of regressing high
> >>> concurrency workloads that may or may not be artificial.
> >>>
> >>> Unless I'm mistaken, there doesn't seem to be a whole lot of urgency
> >>> behind this patch. Can we think about a general model to deal with
> >>> allocation concurrency? 
> >>
> >> I am definitely not against. There is no reason to rush the patch in.
> > 
> > I don't hurry if we can check using watchdog whether this problem is occurring
> > in the real world. I have to test corner cases because watchdog is missing.
> > 
> Ping?
> 
> This problem can occur even immediately after the first invocation of
> the OOM killer. I believe this problem can occur in the real world.
> When are we going to apply this patch or watchdog patch?
> 
> ----------------------------------------
> [    0.000000] Linux version 4.11.0-rc7-next-20170421+ (root@ccsecurity) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-11) (GCC) ) #588 SMP Sun Apr 23 17:38:02 JST 2017
> [    0.000000] Command line: BOOT_IMAGE=/boot/vmlinuz-4.11.0-rc7-next-20170421+ root=UUID=17c3c28f-a70a-4666-95fa-ecf6acd901e4 ro vconsole.keymap=jp106 crashkernel=256M vconsole.font=latarcyrheb-sun16 security=none sysrq_always_enabled console=ttyS0,115200n8 console=tty0 LANG=en_US.UTF-8 debug_guardpage_minorder=1

Are you debugging memory corruption problem?

FWIW, if you use debug_guardpage_minorder= you can expect any
allocation memory problems. This option is intended to debug
memory corruption bugs and it shrinks available memory in 
artificial way. Taking that, I don't think justifying any
patch, by problem happened when debug_guardpage_minorder= is 
used, is reasonable.
 
Stanislaw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
