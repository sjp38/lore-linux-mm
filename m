Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id CAD7D6B0035
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 15:49:58 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so2054687qge.16
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:49:58 -0700 (PDT)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id g2si6519246qaf.52.2014.07.23.12.49.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 12:49:57 -0700 (PDT)
Received: by mail-qa0-f43.google.com with SMTP id w8so1798277qac.2
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 12:49:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140723145604.GA2956@gmail.com>
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
	<20140723145604.GA2956@gmail.com>
Date: Wed, 23 Jul 2014 15:49:57 -0400
Message-ID: <CADnq5_P9xWdJ22LViAFr1qMboc8UuP5PVAS0MFNJ0h_tr_n80g@mail.gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
From: Alex Deucher <alexdeucher@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: =?UTF-8?Q?Christian_K=C3=B6nig?= <deathsimple@vodafone.de>, Oded Gabbay <oded.gabbay@amd.com>, David Airlie <airlied@linux.ie>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>

On Wed, Jul 23, 2014 at 10:56 AM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Wed, Jul 23, 2014 at 09:04:24AM +0200, Christian K=C3=B6nig wrote:
>> Am 23.07.2014 08:50, schrieb Oded Gabbay:
>> >On 22/07/14 14:15, Daniel Vetter wrote:
>> >>On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
>> >>>On 22/07/14 12:21, Daniel Vetter wrote:
>> >>>>On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com>
>> >>>>wrote:
>> >>>>>>Exactly, just prevent userspace from submitting more. And if you
>> >>>>>>have
>> >>>>>>misbehaving userspace that submits too much, reset the gpu and
>> >>>>>>tell it
>> >>>>>>that you're sorry but won't schedule any more work.
>> >>>>>
>> >>>>>I'm not sure how you intend to know if a userspace misbehaves or
>> >>>>>not. Can
>> >>>>>you elaborate ?
>> >>>>
>> >>>>Well that's mostly policy, currently in i915 we only have a check fo=
r
>> >>>>hangs, and if userspace hangs a bit too often then we stop it. I gue=
ss
>> >>>>you can do that with the queue unmapping you've describe in reply to
>> >>>>Jerome's mail.
>> >>>>-Daniel
>> >>>>
>> >>>What do you mean by hang ? Like the tdr mechanism in Windows (checks
>> >>>if a
>> >>>gpu job takes more than 2 seconds, I think, and if so, terminates the
>> >>>job).
>> >>
>> >>Essentially yes. But we also have some hw features to kill jobs quicke=
r,
>> >>e.g. for media workloads.
>> >>-Daniel
>> >>
>> >
>> >Yeah, so this is what I'm talking about when I say that you and Jerome
>> >come from a graphics POV and amdkfd come from a compute POV, no offense
>> >intended.
>> >
>> >For compute jobs, we simply can't use this logic to terminate jobs.
>> >Graphics are mostly Real-Time while compute jobs can take from a few ms=
 to
>> >a few hours!!! And I'm not talking about an entire application runtime =
but
>> >on a single submission of jobs by the userspace app. We have tests with
>> >jobs that take between 20-30 minutes to complete. In theory, we can eve=
n
>> >imagine a compute job which takes 1 or 2 days (on larger APUs).
>> >
>> >Now, I understand the question of how do we prevent the compute job fro=
m
>> >monopolizing the GPU, and internally here we have some ideas that we wi=
ll
>> >probably share in the next few days, but my point is that I don't think=
 we
>> >can terminate a compute job because it is running for more than x secon=
ds.
>> >It is like you would terminate a CPU process which runs more than x
>> >seconds.
>>
>> Yeah that's why one of the first things I've did was making the timeout
>> configurable in the radeon module.
>>
>> But it doesn't necessary needs be a timeout, we should also kill a runni=
ng
>> job submission if the CPU process associated with the job is killed.
>>
>> >I think this is a *very* important discussion (detecting a misbehaved
>> >compute process) and I would like to continue it, but I don't think mov=
ing
>> >the job submission from userspace control to kernel control will solve
>> >this core problem.
>>
>> We need to get this topic solved, otherwise the driver won't make it
>> upstream. Allowing userpsace to monopolizing resources either memory, CP=
U or
>> GPU time or special things like counters etc... is a strict no go for a
>> kernel module.
>>
>> I agree that moving the job submission from userpsace to kernel wouldn't
>> solve this problem. As Daniel and I pointed out now multiple times it's
>> rather easily possible to prevent further job submissions from userspace=
, in
>> the worst case by unmapping the doorbell page.
>>
>> Moving it to an IOCTL would just make it a bit less complicated.
>>
>
> It is not only complexity, my main concern is not really the amount of me=
mory
> pinned (well it would be if it was vram which by the way you need to remo=
ve
> the api that allow to allocate vram just so that it clearly shows that vr=
am is
> not allowed).
>
> Issue is with GPU address space fragmentation, new process hsa queue migh=
t be
> allocated in middle of gtt space and stays there for so long that i will =
forbid
> any big buffer to be bind to gtt. Thought with virtual address space for =
graphics
> this is less of an issue and only the kernel suffer but still it might bl=
ock the
> kernel from evicting some VRAM because i can not bind a system buffer big=
 enough
> to GTT because some GTT space is taken by some HSA queue.
>
> To mitigate this at very least, you need to implement special memory allo=
cation
> inside ttm and radeon to force this per queue to be allocate for instance=
 from
> top of GTT space. Like reserve top 8M of GTT and have it grow/shrink depe=
nding
> on number of queue.

This same sort of thing can already happen with gfx, although it's
less likely since the workloads are usually shorter.  That said, we
can issue compute jobs right today with the current CS ioctl and we
may end up with a buffer pinned in an inopportune spot.  I'm not sure
reserving a static pool at init really helps that much.  If you aren't
using any HSA apps, it just wastes gtt space.  So you have a trade
off: waste memory for a possibly unused MQD descriptor pool or
allocate MQD descriptors on the fly, but possibly end up with a long
running one stuck in a bad location.  Additionally, we already have a
ttm flag for whether we want to allocate from the top or bottom of the
pool.  We use it today for gfx depending on the buffer (e.g., buffers
smaller than 512k are allocated from the bottom and buffers larger
than 512 are allocated from the top).  So we can't really re-size a
static buffer easily as there may already be other buffers pinned up
there.

If we add sysfs controls to limit the amount of hsa processes, and
queues per process so you could use this to dynamically limit the max
amount gtt memory that would be in use for MQD descriptors.

Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
