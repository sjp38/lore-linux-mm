Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 56FE56B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 17:13:31 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so6102309pbc.32
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 14:13:31 -0700 (PDT)
Date: Tue, 17 Sep 2013 23:13:17 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: doing lots of disk writes causes oom killer to kill processes
Message-ID: <20130917211317.GB6537@quack.suse.cz>
References: <CAJd=RBBbJMWox5yJaNzW_jUdDfKfWe-Y7d1riYdN6huQStxzcA@mail.gmail.com>
 <CAOMqctQyS2SFraqJpzE0sRFcihFpMHRhT+3QuZhxft=SUXYVDw@mail.gmail.com>
 <CAOMqctQ+XchmXk_Xno6ViAoZF-tHFPpDWoy7LVW1nooa+ywbmg@mail.gmail.com>
 <CAOMqctT2u7E0kwpm052B9pkNo4D=sYHO+Vk=P_TziUb5KvTMKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOMqctT2u7E0kwpm052B9pkNo4D=sYHO+Vk=P_TziUb5KvTMKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Suchanek <hramrach@gmail.com>
Cc: Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

  Hello,

On Tue 17-09-13 15:31:31, Michal Suchanek wrote:
> On 5 September 2013 12:12, Michal Suchanek <hramrach@gmail.com> wrote:
> > On 26 August 2013 15:51, Michal Suchanek <hramrach@gmail.com> wrote:
> >> On 12 March 2013 03:15, Hillf Danton <dhillf@gmail.com> wrote:
> >>>>On 11 March 2013 13:15, Michal Suchanek <hramrach@gmail.com> wrote:
> >>>>>On 8 February 2013 17:31, Michal Suchanek <hramrach@gmail.com> wrote:
> >>>>> Hello,
> >>>>>
> >>>>> I am dealing with VM disk images and performing something like wiping
> >>>>> free space to prepare image for compressing and storing on server or
> >>>>> copying it to external USB disk causes
> >>>>>
> >>>>> 1) system lockup in order of a few tens of seconds when all CPU cores
> >>>>> are 100% used by system and the machine is basicaly unusable
> >>>>>
> >>>>> 2) oom killer killing processes
> >>>>>
> >>>>> This all on system with 8G ram so there should be plenty space to work with.
> >>>>>
> >>>>> This happens with kernels 3.6.4 or 3.7.1
> >>>>>
> >>>>> With earlier kernel versions (some 3.0 or 3.2 kernels) this was not a
> >>>>> problem even with less ram.
> >>>>>
> >>>>> I have  vm.swappiness = 0 set for a long  time already.
> >>>>>
> >>>>>
> >>>>I did some testing with 3.7.1 and with swappiness as much as 75 the
> >>>>kernel still causes all cores to loop somewhere in system when writing
> >>>>lots of data to disk.
> >>>>
> >>>>With swappiness as much as 90 processes still get killed on large disk writes.
> >>>>
> >>>>Given that the max is 100 the interval in which mm works at all is
> >>>>going to be very narrow, less than 10% of the paramater range. This is
> >>>>a severe regression as is the cpu time consumed by the kernel.
> >>>>
> >>>>The io scheduler is the default cfq.
> >>>>
> >>>>If you have any idea what to try other than downgrading to an earlier
> >>>>unaffected kernel I would like to hear.
> >>>>
> >>> Can you try commit 3cf23841b4b7(mm/vmscan.c: avoid possible
> >>> deadlock caused by too_many_isolated())?
> >>>
> >>> Or try 3.8 and/or 3.9, additionally?
> >>>
> >>
> >> Hello,
> >>
> >> with deadline IO scheduler I experience this issue less often but it
> >> still happens.
> >>
> >> I am on 3.9.6 Debian kernel so 3.8 did not fix this problem.
> >>
> >> Do you have some idea what to log so that useful information about the
> >> lockup is gathered?
> >>
> >
> > This appears to be fixed in vanilla 3.11 kernel.
> >
> > I still get short intermittent lockups and cpu usage spikes up to 20%
> > on a core but nowhere near the minute+ long lockups with all cores
> > 100% on earlier kernels.
> >
> 
> So I did more testing on the 3.11 kernel and while it works OK with
> tar you can get severe lockups with mc or kvm. The difference is
> probably the fact that sane tools do fsync() on files they close
> forcing the file to write out and the kernel returning possible write
> errors before they move on to next file.
  Sorry for chiming in a bit late. But is this really writing to a normal
disk? SATA drive or something else?

> With kvm writing to a file used as virtual disk the system would stall
> indefinitely until the disk driver in the emulated system would time
> out, return disk IO error, and the emulated system would stop writing.
> In top I see all CPU cores 90%+ in wait. System is unusable. With mc
> the lockups would be indefinite, probably because there is no timeout
> on writing a file in mc.
> 
> I tried tuning swappiness and eleveators but the the basic problem is
> solved by neither: the dirty buffers fill up memory and system stalls
> trying to resolve the situation.
  This is really strange. There is /proc/sys/vm/dirty_ratio, which limits
amount of dirty memory. By default it is set to 20% of memory which tends
to be too much for 8 GB machine. Can you set it to something like 5% and
/proc/sys/vm/dirty_background_ratio to 2%? That would be more appropriate
sizing (assuming standard SATA drive). Does it change anything?

If the problem doesn't go away, can you install systemtap on your system
and run attached script? It should report where exactly processes stall and
for how long which should help us address the issue. Thanks.

> Obviously the kernel puts off writing any dirty buffers until the
> memory pressure is overwhelming and the vmm flops.
> 
> At least the OOM killer does not get invoked anymore since there is
> lots of memory - just Linux does not know how to use it.
> 
> The solution to this problem is quite simple - use the ancient
> userspace bdflushd or what it was called. I emulate it with
> { while true ; do sleep 5; sync ; done } &
> 
> The system performance suddenly increases - to the awesome Debian stable levels.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
