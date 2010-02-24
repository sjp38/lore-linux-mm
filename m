Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DF0D06B0078
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 15:37:14 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: s2disk hang update
Date: Wed, 24 Feb 2010 21:36:19 +0100
References: <9b2b86521001020703v23152d0cy3ba2c08df88c0a79@mail.gmail.com> <201002232213.56455.rjw@sisk.pl> <20100224102037.2cca4f83.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100224102037.2cca4f83.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201002242136.19584.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Alan Jenkins <sourcejedi.lkml@googlemail.com>, Mel Gorman <mel@csn.ul.ie>, hugh.dickins@tiscali.co.uk, Pavel Machek <pavel@ucw.cz>, pm list <linux-pm@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Kernel Testers List <kernel-testers@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wednesday 24 February 2010, KAMEZAWA Hiroyuki wrote:
> On Tue, 23 Feb 2010 22:13:56 +0100
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > Well, it still looks like we're waiting for create_workqueue_thread() to
> > return, which probably is trying to allocate memory for the thread
> > structure.
> > 
> > My guess is that the preallocated memory pages freed by
> > free_unnecessary_pages() go into a place from where they cannot be taken for
> > subsequent NOIO allocations.  I have no idea why that happens though.
> > 
> > To test that theory you can try to change GFP_IOFS to GFP_KERNEL in the
> > calls to clear_gfp_allowed_mask() in kernel/power/hibernate.c (and in
> > kernel/power/suspend.c for completness).
> > 
> 
> If allocation of kernel threads for stop_machine_run() is the problem,
> 
> What happens when
> 1. use CONIFG_4KSTACK
> or
> 2. make use of stop_machine_create(), stop_machine_destroy().
>    A new interface added by this commit.
>   http://git.kernel.org/?p=linux/kernel/git/torvalds/  linux-2.6.git;a=commit;h=9ea09af3bd3090e8349ca2899ca2011bd94cda85
>    You can do no-fail stop_machine_run().

Well, that would probably help in this particular case, but the root cause
seems to be that the (theoretically) freed memory cannot be used for NOIO
allocations for some reason, which is shown by the Alan's testing.

Generally speaking, we use __free_page() to release some pages preallocated
for the hibernation image, but the memory subsystem refuses to use these
pages for NOIO allocations made later.  However, it evidently is able to use
them is __GFP_WAIT is unset in the mask.

Is this behavior intentional?

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
