Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9C246B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 11:11:53 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id q17so25560458lbn.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:11:53 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id bn6si1302987wjb.32.2016.06.02.08.11.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 08:11:51 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id z87so73734993wmh.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 08:11:51 -0700 (PDT)
Date: Thu, 2 Jun 2016 17:11:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
Message-ID: <20160602151149.GT1995@dhcp22.suse.cz>
References: <20160523072904.GC2278@dhcp22.suse.cz>
 <20160523151419.GA8284@redhat.com>
 <20160524071619.GB8259@dhcp22.suse.cz>
 <20160524224341.GA11961@redhat.com>
 <20160525120957.GH20132@dhcp22.suse.cz>
 <20160529212540.GA15180@redhat.com>
 <20160531125253.GK26128@dhcp22.suse.cz>
 <20160531235626.GA24319@redhat.com>
 <20160601100020.GK26601@dhcp22.suse.cz>
 <20160601213829.GA16808@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160601213829.GA16808@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 01-06-16 23:38:30, Oleg Nesterov wrote:
> On 06/01, Michal Hocko wrote:
> >
> > On Wed 01-06-16 01:56:26, Oleg Nesterov wrote:
> > > On 05/31, Michal Hocko wrote:
> > > >
> > > > On Sun 29-05-16 23:25:40, Oleg Nesterov wrote:
> > > > >
> > > > > This single change in get_scan_count() under for_each_evictable_lru() loop
> > > > >
> > > > > 	-	size = lruvec_lru_size(lruvec, lru);
> > > > > 	+	size = zone_page_state_snapshot(lruvec_zone(lruvec), NR_LRU_BASE + lru);
> > > > >
> > > > > fixes the problem too.
> > > > >
> > > > > Without this change shrink*() continues to scan the LRU_ACTIVE_FILE list
> > > > > while it is empty. LRU_INACTIVE_FILE is not empty (just a few pages) but
> > > > > we do not even try to scan it, lruvec_lru_size() returns zero.
> > > >
> > > > OK, you seem to be really seeing a different issue than me.
> > >
> > > quite possibly, but
> > >
> > > > My debugging
> > > > patch was showing when nothing was really isolated from the LRU lists
> > > > (both for shrink_{in}active_list.
> > >
> > > in my debugging session too. LRU_ACTIVE_FILE was empty, so there is nothing to
> > > isolate even if shrink_active_list() is (wrongly called) with nr_to_scan != 0.
> > > LRU_INACTIVE_FILE is not empty but it is not scanned because nr_to_scan == 0.
> > >
> > > But I am afraid I misunderstood you, and you meant something else.
> >
> > What I wanted to say is that my debugging hasn't shown a single case
> > when nothing would be isolated. Which seems to be the case for you.
> 
> Ah, got it, thanks. Yes, I see that there is no "nothing scanned" in
> oom-test.qcow_serial.log.gz from http://marc.info/?l=linux-kernel&m=146417822608902
> you sent. I applied this patch and I do see "nothing scanned".
> 
> But, unlike you, I do not see the messages from free-pages... perhaps you
> have more active tasks. To remind, I tested this with the single user-space
> process, /bin/sh running with pid==1, then I did "while true; do ./oom; done".

Well, I was booting into a standard init which will have a couple of
processes. So yes this would make a slight difference.
 
> So of course I do not know if you see another issue or the same, but now I am
> wondering if the change in get_scan_count() above fixes the problem for you.

I have played with it but the interfering freed pages just ruined the
whole zone_reclaimable expectations.
 
> Probably not, but the fact you do not see "nothing scanned" can't prove this,
> it is possible that shrink_*_list() was not called because vm_stat == 0 but
> zone_reclaimable() sees the per-cpu counter. In this case 0db2cb8da89d can
> make a difference, but see below.
> 
> > > > But I am thinking whether we should simply revert 0db2cb8da89d ("mm,
> > > > vmscan: make zone_reclaimable_pages more precise") in 4.6 stable tree.
> > > > Does that help as well?
> > >
> > > I'll test this tomorrow,
> 
> So it doesn't help.

OK, so we at least know this is not a regression.

> > but even if it helps I am not sure... Yes, this
> > > way zone_reclaimable() and get_scan_count() will see the same numbers, but
> > > how this can help to make zone_reclaimable() == F at the end?
> >
> > It won't in some cases.
> 
> And unless I am notally confused  hit exactly this case.
> 
> > And that has been the case for ages so I do not
> > think we need any steps for the stable.
> 
> OK, agreed.
> 
> > What meant to address is a
> > potential regression caused by 0db2cb8da89d which would make this more
> > likely because of the mismatch
> 
> Again, I can be easily wrong, but I do not see how 0db2cb8da89d could make
> the things worse...
> 
> Unless both get_scan_count() and zone_reclaimable() use "snapshot" variant,
> we can't guarantee zone_reclaimable() becomes false. The fact that they see
> different numbers (after 0db2cb8da89d) doesn't really matter.
> 
> Anyway, this was already fixed, so lets forget it ;)

Yes, especially as this doesn't seem to be a regression.

Thanks for your effort anyway.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
