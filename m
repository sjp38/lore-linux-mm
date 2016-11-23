Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2D3486B0069
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 02:49:53 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id w13so3330015wmw.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:49:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l90si1231192wmi.65.2016.11.22.23.49.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Nov 2016 23:49:51 -0800 (PST)
Date: Wed, 23 Nov 2016 08:49:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Softlockup during memory allocation
Message-ID: <20161123074947.GE2864@dhcp22.suse.cz>
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com>
 <a73f4917-48ac-bf1e-04d9-64fb937abfc6@kyup.com>
 <CAJFSNy5_z_FA4DTPAtqBdOU+LmnfvdeVBtDhHuperv1MVU-9VA@mail.gmail.com>
 <20161121053154.GA29816@dhcp22.suse.cz>
 <ab42c7a5-49e2-4e46-be60-e0a56704a11d@kyup.com>
 <20161122143056.GB6831@dhcp22.suse.cz>
 <6c33f44b-327c-d943-73da-5935136a83c9@kyup.com>
 <20161122170239.GH6831@dhcp22.suse.cz>
 <dca0dfb4-6623-f11f-5f6e-1afac02d5ee6@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dca0dfb4-6623-f11f-5f6e-1afac02d5ee6@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Linux MM <linux-mm@kvack.org>

On Wed 23-11-16 09:44:45, Nikolay Borisov wrote:
> 
> 
> On 11/22/2016 07:02 PM, Michal Hocko wrote:
> > On Tue 22-11-16 16:35:38, Nikolay Borisov wrote:
> >>
> >>
> >> On 11/22/2016 04:30 PM, Michal Hocko wrote:
> >>> On Tue 22-11-16 10:56:51, Nikolay Borisov wrote:
> >>>>
> >>>>
> >>>> On 11/21/2016 07:31 AM, Michal Hocko wrote:
> >>>>> Hi,
> >>>>> I am sorry for a late response, but I was offline until this weekend. I
> >>>>> will try to get to this email ASAP but it might take some time.
> >>>>
> >>>> No worries. I did some further digging up and here is what I got, which
> >>>> I believe is rather strange:
> >>>>
> >>>> struct scan_control {
> >>>>   nr_to_reclaim = 32,
> >>>>   gfp_mask = 37880010,
> >>>>   order = 0,
> >>>>   nodemask = 0x0,
> >>>>   target_mem_cgroup = 0xffff8823990d1400,
> >>>>   priority = 7,
> >>>>   may_writepage = 1,
> >>>>   may_unmap = 1,
> >>>>   may_swap = 0,
> >>>>   may_thrash = 1,
> >>>>   hibernation_mode = 0,
> >>>>   compaction_ready = 0,
> >>>>   nr_scanned = 0,
> >>>>   nr_reclaimed = 0
> >>>> }
> >>>>
> >>>> Parsing: 37880010
> >>>> #define ___GFP_HIGHMEM		0x02
> >>>> #define ___GFP_MOVABLE		0x08
> >>>> #define ___GFP_IO		0x40
> >>>> #define ___GFP_FS		0x80
> >>>> #define ___GFP_HARDWALL		0x20000
> >>>> #define ___GFP_DIRECT_RECLAIM	0x400000
> >>>> #define ___GFP_KSWAPD_RECLAIM	0x2000000
> >>>>
> >>>> And initial_priority is 12 (DEF_PRIORITY). Given that nr_scanned is 0
> >>>> and priority is 7 this means we've gone 5 times through the do {} while
> >>>> in do_try_to_free_pages. Also total_scanned seems to be 0.  Here is the
> >>>> zone which was being reclaimed :
> >>
> >> This is also very strange that total_scanned is 0.
> >>
> >>
> >>>>
> >>>> http://sprunge.us/hQBi
> >>>
> >>> LRUs on that zones seem to be empty from a quick glance. kmem -z in the
> >>> crash can give you per zone counters much more nicely.
> >>>
> >>
> >> So here are the populated zones:
> > [...]
> >> NODE: 0  ZONE: 2  ADDR: ffff88207fffcf00  NAME: "Normal"
> >>   SIZE: 33030144  MIN/LOW/HIGH: 22209/27761/33313
> >>   VM_STAT:
> >>                 NR_FREE_PAGES: 62436
> >>                NR_ALLOC_BATCH: 2024
> >>              NR_INACTIVE_ANON: 8177867
> >>                NR_ACTIVE_ANON: 5407176
> >>              NR_INACTIVE_FILE: 5804642
> >>                NR_ACTIVE_FILE: 9694170
> > 
> > So your LRUs are definitely not empty as I have thought. Having 
> > 0 pages scanned is indeed very strange. We do reset sc->nr_scanned
> > for each priority but my understanding was that you are looking at a
> > state where we are somwhere in the middle of shrink_zones. Moreover
> > total_scanned should be cumulative.
> 
> So the server began acting wonky. People logged on it and saw the
> softlockup as per my initial email. They then initiated a crashdump via
> sysrq since most commands weren't going through (e.g. forking) so
> crashing it was a last resort measure. After that I start looking at the
> crashdump and observe that prior to the crash machine seems to have
> locked up judging from the dmesg logs. However, when I manually inspect
> the *current* (and current being at the time the crash was actually
> initiated) state of the processes reported as softlock up they seem to
> have made progress are now in
> shrink_zone->shrink_lruvec->shrink_inactive_list->_cond_resched->__schedule

OK, I see.

> And the softlockup was being shown to be in mem_cgroup_iter. So it's
> mystery how come this function can softlockup and after the softlockup
> apparently got resolved reclaim is not making any progress.

This might be just a coincidence and the lockup might really mean that
we couldn't isolate (thus scan) any pages at the time the lockup was
detected. mem_cgroup_iter shouldn't itself loop without any bounds to
trigger the lockup on its own. There is a loop around
css_next_descendant_pre but this should take only few iterations in case
we are racing with cgroup removal AFAIR. So to me it sounds more like a
problem with the state of LRU lists rather than anything else.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
