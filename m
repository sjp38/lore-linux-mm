Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 0804C6B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 10:42:01 -0500 (EST)
Date: Tue, 24 Jan 2012 13:38:35 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [RFC 1/3] /dev/low_mem_notify
Message-ID: <20120124153835.GA10990@amt.cnet>
References: <CAOJsxLGiG_Bsp8eMtqCjFToxYAPCE4HC9XCebpZ+-G8E3gg5bw@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB98269045596EA@008-AM1MPN1-003.mgdnok.nokia.com>
 <CAOJsxLG4hMrAdsyOg6QUe71SPqEBq3eZXvRvaKFZQo8HS1vphQ@mail.gmail.com>
 <84FF21A720B0874AA94B46D76DB982690455978C@008-AM1MPN1-003.mgdnok.nokia.com>
 <4F175706.8000808@redhat.com>
 <alpine.LFD.2.02.1201190922390.3033@tux.localdomain>
 <4F17DCED.4020908@redhat.com>
 <CAOJsxLG3x_R5xq85hh5RvPoD+nhgYbHJfbLW=YMxCZockAXJqw@mail.gmail.com>
 <4F17E058.8020008@redhat.com>
 <84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84FF21A720B0874AA94B46D76DB9826904559D46@008-AM1MPN1-003.mgdnok.nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: rhod@redhat.com, penberg@kernel.org, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, kosaki.motohiro@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com

On Thu, Jan 19, 2012 at 10:53:29AM +0000, leonid.moiseichuk@nokia.com wrote:
> > -----Original Message-----
> > From: ext Ronen Hod [mailto:rhod@redhat.com]
> > Sent: 19 January, 2012 11:20
> > To: Pekka Enberg
> ...
> > >>> Isn't
> > >>>
> > >>> /proc/sys/vm/min_free_kbytes
> > >>>
> > >>> pretty much just that?
> > >> Would you suggest to use min_free_kbytes as the threshold for sending
> > >> low_memory_notifications to applications, and separately as a target
> > >> value for the applications' memory giveaway?
> > > I'm not saying that the kernel should use it directly but it seems
> > > like the kind of "ideal number of free pages" threshold you're
> > > suggesting. So userspace can read that value and use it as the "number
> > > of free pages" threshold for VM events, no?
> > 
> > Yes, I like it. The rules of the game are simple and consistent all over, be it the
> > alert threshold, voluntary poling by the apps, and for concurrent work by
> > several applications.
> > Well, as long as it provides a good indication for low_mem_pressure.
> 
> For me it doesn't look that have much sense. min_free_kbytes could be set from user-space (or auto-tuned by kernel) to keep some amount 
> of memory available for GFP_ATOMIC allocations.  In case situation comes under pointed level kernel will reclaim memory from e.g. caches.
> 
> >From potential user point of view the proposed API has number of lacks which would be nice to have implemented:
> 1. rename this API from low_mem_pressure to something more related to notification and memory situation in system: memory_pressure, memnotify, memory_level etc. The word "low" is misleading here
> 2. API must use deferred timers to prevent use-time impact. Deferred timer will be triggered only in case HW event or non-deferrable timer, so if device sleeps timer might be skipped and that is what expected for user-space

Having userspace specify the "sample period" for low memory notification
makes no sense. The frequency of notifications is a function of the
memory pressure.

> 3. API should be tunable for propagate changes when level is Up or Down, maybe both ways. 


> 4. to avoid triggering too much events probably has sense to filter according to amount of change but that is optional. If subscriber set timer to 1s the amount of events should not be very big.
> 5. API must provide interface to request parameters e.g. available swap or free memory just to have some base.

It would make the interface easier to use if it provided the number of
pages to free, in the notification (kernel can calculate that as the
delta between current_free_pages -> comfortable_free_pages relative to
process RSS).

> 6. I do not understand how work with attributes performed ( ) but it has sense to use mask and fill requested attributes using mask and callback table i.e. if free pages requested - they are reported, otherwise not.
> 7. would have sense to backport couple of attributes from memnotify.c
> 
> I can submit couple of patches if some of proposals looks sane for everyone.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
