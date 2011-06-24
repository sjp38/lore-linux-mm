Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7899F900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 02:33:07 -0400 (EDT)
Subject: Re: sandy bridge kswapd0 livelock with pagecache
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <4E00A96D.8020806@draigBrady.com>
References: <4E0069FE.4000708@draigBrady.com>
	 <20110621103920.GF9396@suse.de> <4E0076C7.4000809@draigBrady.com>
	 <20110621113447.GG9396@suse.de> <4E008784.80107@draigBrady.com>
	 <20110621130756.GH9396@suse.de>  <4E00A96D.8020806@draigBrady.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 24 Jun 2011 14:33:04 +0800
Message-ID: <1308897184.15392.170.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?P=E1draig?= Brady <P@draigBrady.com>
Cc: Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 2011-06-21 at 22:23 +0800, PA!draig Brady wrote:
> On 21/06/11 14:07, Mel Gorman wrote:
> > On Tue, Jun 21, 2011 at 12:59:00PM +0100, P?draig Brady wrote:
> >> On 21/06/11 12:34, Mel Gorman wrote:
> >>> On Tue, Jun 21, 2011 at 11:47:35AM +0100, P?draig Brady wrote:
> >>>> On 21/06/11 11:39, Mel Gorman wrote:
> >>>>> On Tue, Jun 21, 2011 at 10:53:02AM +0100, P?draig Brady wrote:
> >>>>>> I tried the 2 patches here to no avail:
> >>>>>> http://marc.info/?l=linux-mm&m=130503811704830&w=2
> >>>>>>
> >>>>>> I originally logged this at:
> >>>>>> https://bugzilla.redhat.com/show_bug.cgi?id=712019
> >>>>>>
> >>>>>> I can compile up and quickly test any suggestions.
> >>>>>>
> >>>>>
> >>>>> I recently looked through what kswapd does and there are a number
> >>>>> of problem areas. Unfortunately, I haven't gotten around to doing
> >>>>> anything about it yet or running the test cases to see if they are
> >>>>> really problems. In your case, the following is a strong possibility
> >>>>> though. This should be applied on top of the two patches merged from
> >>>>> that thread.
> >>>>>
> >>>>> This is not tested in any way, based on 3.0-rc3
> >>>>
> >>>> This does not fix the issue here.
> >>>>
> >>>
> >>> I made a silly mistake here.  When you mentioned two patches applied,
> >>> I assumed you meant two patches that were finally merged from that
> >>> discussion thread instead of looking at your linked mail. Now that I
> >>> have checked, I think you applied the SLUB patches while the patches
> >>> I was thinking of are;
> >>>
> >>> [afc7e326: mm: vmscan: correct use of pgdat_balanced in sleeping_prematurely]
> >>> [f06590bd: mm: vmscan: correctly check if reclaimer should schedule during shrink_slab]
> >>>
> >>> The first one in particular has been reported by another user to fix
> >>> hangs related to copying large files. I'm assuming you are testing
> >>> against the Fedora kernel. As these patches were merged for 3.0-rc1, can
> >>> you check if applying just these two patches to your kernel helps?
> >>
> >> These patches are already present in my 2.6.38.8-32.fc15.x86_64 kernel :(
> >>
> > 
> > Would it be possible to record a profile while it is livelocked to check
> > if it's stuck in this loop in shrink_slab()?
> 
> I did:
> 
> perf record -a -g sleep 10
> perf report --stdio > livelock.perf #attached
> perf annotate shrink_slab -k rpmbuild/BUILD/kernel-2.6.38.fc15/linux-2.6.38.x86_64/vmlinux > shrink_slab.annotate #attached
> 
> > 
> >                 while (total_scan >= SHRINK_BATCH) {
> >                         long this_scan = SHRINK_BATCH;
> >                         int shrink_ret;
> >                         int nr_before;
> > 
> >                         nr_before = do_shrinker_shrink(shrinker, shrink, 0);
> >                         shrink_ret = do_shrinker_shrink(shrinker, shrink,
> >                                                         this_scan);
> >                         if (shrink_ret == -1)
> >                                 break;
> >                         if (shrink_ret < nr_before)
> >                                 ret += nr_before - shrink_ret;
> >                         count_vm_events(SLABS_SCANNED, this_scan);
> >                         total_scan -= this_scan;
> > 
> >                         cond_resched();
> >                 }
> 
> shrink_slab() looks to be the culprit, but it seems
> to be the loop outside the above that is spinning.
> 
> > Also, can you post the output of sysrq+m at a few different times while
> > kswapd is spinning heavily? I want to see if all_unreclaimable has been
> > set on zones with a reasonable amount of memory. If they are, it's
> > possible for kswapd to be in a continual loop calling shrink_slab() and
> > skipping over normal page reclaim because all_unreclaimable is set
> > everywhere until a page is freed.
> 
> I did that 3 times. Attached.
from the perf log:
    62.70%          kswapd0  [i915]                              [k]
i915_gem_object_bind_to_gtt
                    |
                    --- i915_gem_object_bind_to_gtt
                       |          
                       |--99.98%-- shrink_slab
                       |          kswapd

Maybe a graphics driver bug. shrink_slab tries to free memory, but
i915_gem_object_bind_gtt could do memory allocation, IIRC.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
