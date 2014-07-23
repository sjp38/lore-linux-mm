Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A51866B003A
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 10:56:08 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so1775642pdj.0
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:56:08 -0700 (PDT)
Received: from mail-qg0-x234.google.com (mail-qg0-x234.google.com [2607:f8b0:400d:c04::234])
        by mx.google.com with ESMTPS id c10si5170067qas.47.2014.07.23.07.56.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 07:56:07 -0700 (PDT)
Received: by mail-qg0-f52.google.com with SMTP id f51so1508911qge.11
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:56:07 -0700 (PDT)
Date: Wed, 23 Jul 2014 10:56:05 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140723145604.GA2956@gmail.com>
References: <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
 <53CD5ED9.2040600@amd.com>
 <20140721190306.GB5278@gmail.com>
 <20140722072851.GH15237@phenom.ffwll.local>
 <53CE1E9C.8020105@amd.com>
 <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
 <53CE346B.1080601@amd.com>
 <20140722111515.GJ15237@phenom.ffwll.local>
 <53CF5B30.50209@amd.com>
 <53CF5E78.8070208@vodafone.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <53CF5E78.8070208@vodafone.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>
Cc: Oded Gabbay <oded.gabbay@amd.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>

On Wed, Jul 23, 2014 at 09:04:24AM +0200, Christian Konig wrote:
> Am 23.07.2014 08:50, schrieb Oded Gabbay:
> >On 22/07/14 14:15, Daniel Vetter wrote:
> >>On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
> >>>On 22/07/14 12:21, Daniel Vetter wrote:
> >>>>On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com>
> >>>>wrote:
> >>>>>>Exactly, just prevent userspace from submitting more. And if you
> >>>>>>have
> >>>>>>misbehaving userspace that submits too much, reset the gpu and
> >>>>>>tell it
> >>>>>>that you're sorry but won't schedule any more work.
> >>>>>
> >>>>>I'm not sure how you intend to know if a userspace misbehaves or
> >>>>>not. Can
> >>>>>you elaborate ?
> >>>>
> >>>>Well that's mostly policy, currently in i915 we only have a check for
> >>>>hangs, and if userspace hangs a bit too often then we stop it. I guess
> >>>>you can do that with the queue unmapping you've describe in reply to
> >>>>Jerome's mail.
> >>>>-Daniel
> >>>>
> >>>What do you mean by hang ? Like the tdr mechanism in Windows (checks
> >>>if a
> >>>gpu job takes more than 2 seconds, I think, and if so, terminates the
> >>>job).
> >>
> >>Essentially yes. But we also have some hw features to kill jobs quicker,
> >>e.g. for media workloads.
> >>-Daniel
> >>
> >
> >Yeah, so this is what I'm talking about when I say that you and Jerome
> >come from a graphics POV and amdkfd come from a compute POV, no offense
> >intended.
> >
> >For compute jobs, we simply can't use this logic to terminate jobs.
> >Graphics are mostly Real-Time while compute jobs can take from a few ms to
> >a few hours!!! And I'm not talking about an entire application runtime but
> >on a single submission of jobs by the userspace app. We have tests with
> >jobs that take between 20-30 minutes to complete. In theory, we can even
> >imagine a compute job which takes 1 or 2 days (on larger APUs).
> >
> >Now, I understand the question of how do we prevent the compute job from
> >monopolizing the GPU, and internally here we have some ideas that we will
> >probably share in the next few days, but my point is that I don't think we
> >can terminate a compute job because it is running for more than x seconds.
> >It is like you would terminate a CPU process which runs more than x
> >seconds.
> 
> Yeah that's why one of the first things I've did was making the timeout
> configurable in the radeon module.
> 
> But it doesn't necessary needs be a timeout, we should also kill a running
> job submission if the CPU process associated with the job is killed.
> 
> >I think this is a *very* important discussion (detecting a misbehaved
> >compute process) and I would like to continue it, but I don't think moving
> >the job submission from userspace control to kernel control will solve
> >this core problem.
> 
> We need to get this topic solved, otherwise the driver won't make it
> upstream. Allowing userpsace to monopolizing resources either memory, CPU or
> GPU time or special things like counters etc... is a strict no go for a
> kernel module.
> 
> I agree that moving the job submission from userpsace to kernel wouldn't
> solve this problem. As Daniel and I pointed out now multiple times it's
> rather easily possible to prevent further job submissions from userspace, in
> the worst case by unmapping the doorbell page.
> 
> Moving it to an IOCTL would just make it a bit less complicated.
> 

It is not only complexity, my main concern is not really the amount of memory
pinned (well it would be if it was vram which by the way you need to remove
the api that allow to allocate vram just so that it clearly shows that vram is
not allowed).

Issue is with GPU address space fragmentation, new process hsa queue might be
allocated in middle of gtt space and stays there for so long that i will forbid
any big buffer to be bind to gtt. Thought with virtual address space for graphics
this is less of an issue and only the kernel suffer but still it might block the
kernel from evicting some VRAM because i can not bind a system buffer big enough
to GTT because some GTT space is taken by some HSA queue.

To mitigate this at very least, you need to implement special memory allocation
inside ttm and radeon to force this per queue to be allocate for instance from
top of GTT space. Like reserve top 8M of GTT and have it grow/shrink depending
on number of queue.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
