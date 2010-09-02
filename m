Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C1E36B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:18:59 -0400 (EDT)
Date: Thu, 2 Sep 2010 15:18:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100902131855.GC10265@tiehlicka.suse.cz>
References: <20100822004232.GA11007@localhost>
 <20100823092246.GA25772@tiehlicka.suse.cz>
 <20100831141942.GA30353@localhost>
 <20100901121951.GC6663@tiehlicka.suse.cz>
 <20100901124138.GD6663@tiehlicka.suse.cz>
 <20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902082829.GA10265@tiehlicka.suse.cz>
 <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902092454.GA17971@tiehlicka.suse.cz>
 <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu 02-09-10 20:19:45, Hiroyuki Kamezawa wrote:
> 2010/9/2 Michal Hocko <mhocko@suse.cz>:
> > On Thu 02-09-10 18:03:43, KAMEZAWA Hiroyuki wrote:
> >> On Thu, 2 Sep 2010 10:28:29 +0200
> >> Michal Hocko <mhocko@suse.cz> wrote:
> >>
> >> > On Thu 02-09-10 14:45:00, KAMEZAWA Hiroyuki wrote:
[...]
> >> > By the higher fragmentation you mean that all movable pageblocks (even
> >> > reclaimable) gets to MIGRATE_MOVABLE until we get first failure. In the
> >> > worst case, if we fail near the end of the zone then there is imbalance
> >> > in MIGRATE_MOVABLE vs. MIGRATE_RECALIMABLE. Is that what you are
> >> > thinking of? Doesn't this just gets the zone to the state after
> >> > onlining? Or is the problem if we fail somewhere in the middle?
> >> >
> >>
> >> No. My concern is pageblock type changes before/after memory hotplug failure.
> >> ? ? ? before isolation: MIGRATE_RECLAIMABLE
> >> ? ? ? after isolation failure : MIGRATE_MOVABLE
> >
> > Ahh, OK I can see your point now. unset_migratetype_isolate called on
> > the failure path sets migrate type unconditionally as it cannot know
> > what was the original migration type.
> >
> Right.
> 
> > What about MIGRATE_RESERVE? Is there anything that can make those
> > allocations fail offlining?
> >
> MIGRATE_RESERVE can contain several typs of pages, mixture of movable/unmovable
> pages.

Ahh, ok. This is just a fallback zone. I see.

> 
> IIRC, my 1st version of code of set_migratetype_isolate() just checks
> zone_idx and
> I think checking MIGRATE_TYPE is my mistake.
> (As Mel explained, it can be a mixture of several types.)
> 
> So, how about using the latter half of set_migratetype_isolate()'s check ?
> It checks that the given range just includes free pages and LRU pages.
> It's 100% accurate and more trustable than migrate_type check.
> 
> Whatever migratetype the pageblock has, if the block only contains free pages
> and lru pages, changing the type as MOVABLE (at failure) is not very bad.
> 
> (Or, checking contents of pageblock in failure path and set proper
> MIGRATE type.)
> 
> Anyway, not very difficult. Just a bit larger patch than you have.

What about this? Just compile tested.

---
