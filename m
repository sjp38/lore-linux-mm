Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 394976B0078
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 16:14:13 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: s2disk hang update
Date: Tue, 23 Feb 2010 22:13:56 +0100
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com> <201002222017.55588.rjw@sisk.pl> <9b2b86521002230624g20661564mc35093ee0423ff77@mail.gmail.com>
In-Reply-To: <9b2b86521002230624g20661564mc35093ee0423ff77@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002232213.56455.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Alan Jenkins <sourcejedi.lkml@googlemail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 23 February 2010, Alan Jenkins wrote:
> On 2/22/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> > On Monday 22 February 2010, Alan Jenkins wrote:
> >> Rafael J. Wysocki wrote:
> >> > On Friday 19 February 2010, Alan Jenkins wrote:
> >> >
> >> >> On 2/18/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >> >>
> >> >>> On Thursday 18 February 2010, Alan Jenkins wrote:
> >> >>>
> >> >>>> On 2/17/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >> >>>>
> >> >>>>> On Wednesday 17 February 2010, Alan Jenkins wrote:
> >> >>>>>
> >> >>>>>> On 2/16/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >> >>>>>>
> >> >>>>>>> On Tuesday 16 February 2010, Alan Jenkins wrote:
> >> >>>>>>>
> >> >>>>>>>> On 2/16/10, Alan Jenkins <sourcejedi.lkml@googlemail.com> wrote:
> >> >>>>>>>>
> >> >>>>>>>>> On 2/15/10, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> >> >>>>>>>>>
> >> >>>>>>>>>> On Tuesday 09 February 2010, Alan Jenkins wrote:
> >> >>>>>>>>>>
> >> >>>>>>>>>>> Perhaps I spoke too soon.  I see the same hang if I run too
> >> >>>>>>>>>>> many
> >> >>>>>>>>>>> applications.  The first hibernation fails with "not enough
> >> >>>>>>>>>>> swap"
> >> >>>>>>>>>>> as
> >> >>>>>>>>>>> expected, but the second or third attempt hangs (with the same
> >> >>>>>>>>>>> backtrace
> >> >>>>>>>>>>> as before).
> >> >>>>>>>>>>>
> >> >>>>>>>>>>> The patch definitely helps though.  Without the patch, I see a
> >> >>>>>>>>>>> hang
> >> >>>>>>>>>>> the
> >> >>>>>>>>>>> first time I try to hibernate with too many applications
> >> >>>>>>>>>>> running.
> >> >>>>>>>>>>>
> >> >>>>>>>>>> Well, I have an idea.
> >> >>>>>>>>>>
> >> >>>>>>>>>> Can you try to apply the appended patch in addition and see if
> >> >>>>>>>>>> that
> >> >>>>>>>>>> helps?
> >> >>>>>>>>>>
> >> >>>>>>>>>> Rafael
> >> >>>>>>>>>>
> >> >>>>>>>>> It doesn't seem to help.
> >> >>>>>>>>>
> >> >>>>>>>> To be clear: It doesn't stop the hang when I hibernate with too
> >> >>>>>>>> many
> >> >>>>>>>> applications.
> >> >>>>>>>>
> >> >>>>>>>> It does stop the same hang in a different case though.
> >> >>>>>>>>
> >> >>>>>>>> 1. boot with init=/bin/bash
> >> >>>>>>>> 2. run s2disk
> >> >>>>>>>> 3. cancel the s2disk
> >> >>>>>>>> 4. repeat steps 2&3
> >> >>>>>>>>
> >> >>>>>>>> With the patch, I can run 10s of iterations, with no hang.
> >> >>>>>>>> Without the patch, it soon hangs, (in disable_nonboot_cpus(), as
> >> >>>>>>>> always).
> >> >>>>>>>>
> >> >>>>>>>> That's what happens on 2.6.33-rc7.  On 2.6.30, there is no
> >> >>>>>>>> problem.
> >> >>>>>>>> On 2.6.31 and 2.6.32 I don't get a hang, but dmesg shows an
> >> >>>>>>>> allocation
> >> >>>>>>>> failure after a couple of iterations ("kthreadd: page allocation
> >> >>>>>>>> failure. order:1, mode:0xd0").  It looks like it might be the
> >> >>>>>>>> same
> >> >>>>>>>> stop_machine thread allocation failure that causes the hang.
> >> >>>>>>>>
> >> >>>>>>> Have you tested it alone or on top of the previous one?  If you've
> >> >>>>>>> tested it
> >> >>>>>>> alone, please apply the appended one in addition to it and retest.
> >> >>>>>>>
> >> >>>>>>> Rafael
> >> >>>>>>>
> >> >>>>>> I did test with both patches applied together -
> >> >>>>>>
> >> >>>>>> 1. [Update] MM / PM: Force GFP_NOIO during suspend/hibernation and
> >> >>>>>> resume
> >> >>>>>> 2. "reducing the number of pages that we're going to keep
> >> >>>>>> preallocated
> >> >>>>>> by
> >> >>>>>> 20%"
> >> >>>>>>
> >> >>>>> In that case you can try to reduce the number of preallocated pages
> >> >>>>> even
> >> >>>>> more,
> >> >>>>> ie. change "/ 5" to "/ 2" (for example) in the second patch.
> >> >>>>>
> >> >>>> It still hangs if I try to hibernate a couple of times with too many
> >> >>>> applications.
> >> >>>>
> >> >>> Hmm.  I guess I asked that before, but is this a 32-bit or 64-bit
> >> >>> system and
> >> >>> how much RAM is there in the box?
> >> >>>
> >> >>> Rafael
> >> >>>
> >> >> EeePC 701.  32 bit.  512Mb RAM.  350Mb swap file, on a "first-gen" SSD.
> >> >>
> >> >
> >> > Hmm.  I'd try to make  free_unnecessary_pages() free all of the
> >> > preallocated
> >> > pages and see what happens.
> >> >
> >>
> >> It still hangs in hibernation_snapshot() / disable_nonboot_cpus().
> >> After apparently freeing over 400Mb / 100,000 pages of preallocated ram.
> >>
> >>
> >>
> >> There is a change which I missed before.  When I applied your first
> >> patch ("Force GFP_NOIO during suspend" etc.), it did change the hung
> >> task backtraces a bit.  I don't know if it tells us anything.
> >>
> >> Without the patch, there were two backtraces.  The first backtrace
> >> suggested a problem allocating pages for a kernel thread (at
> >> copy_process() / try_to_free_pages()).  The second showed that this
> >> problem was blocking s2disk (at hibernation_snapshot() /
> >> disable_nonboot_cpus() / stop_machine_create()).
> >>
> >> With the GFP_NOIO patch, I see only the s2disk backtrace.
> >
> > Can you please post this backtrace?
> 
> Sure.  It's rather like the one I posted before, except
> 
> a) it only shows the one hung task (s2disk)
> b) this time I had lockdep enabled
> c) this time most of the lines don't have question marks.

Well, it still looks like we're waiting for create_workqueue_thread() to
return, which probably is trying to allocate memory for the thread
structure.

My guess is that the preallocated memory pages freed by
free_unnecessary_pages() go into a place from where they cannot be taken for
subsequent NOIO allocations.  I have no idea why that happens though.

To test that theory you can try to change GFP_IOFS to GFP_KERNEL in the
calls to clear_gfp_allowed_mask() in kernel/power/hibernate.c (and in
kernel/power/suspend.c for completness).

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
