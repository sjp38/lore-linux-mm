Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 41BA56B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 03:04:45 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so7033694wiv.4
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 00:04:43 -0700 (PDT)
Received: from pegasos-out.vodafone.de (pegasos-out.vodafone.de. [80.84.1.38])
        by mx.google.com with ESMTP id ga9si2923729wjb.9.2014.07.23.00.04.41
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 00:04:42 -0700 (PDT)
Message-ID: <53CF5E78.8070208@vodafone.de>
Date: Wed, 23 Jul 2014 09:04:24 +0200
From: =?windows-1252?Q?Christian_K=F6nig?= <deathsimple@vodafone.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <20140721155851.GB4519@gmail.com> <20140721170546.GB15237@phenom.ffwll.local> <53CD4DD2.10906@amd.com> <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com> <53CD5ED9.2040600@amd.com> <20140721190306.GB5278@gmail.com> <20140722072851.GH15237@phenom.ffwll.local> <53CE1E9C.8020105@amd.com> <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com> <53CE346B.1080601@amd.com> <20140722111515.GJ15237@phenom.ffwll.local> <53CF5B30.50209@amd.com>
In-Reply-To: <53CF5B30.50209@amd.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>, Jerome Glisse <j.glisse@gmail.com>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?windows-1252?Q?Michel_D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>

Am 23.07.2014 08:50, schrieb Oded Gabbay:
> On 22/07/14 14:15, Daniel Vetter wrote:
>> On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
>>> On 22/07/14 12:21, Daniel Vetter wrote:
>>>> On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com> 
>>>> wrote:
>>>>>> Exactly, just prevent userspace from submitting more. And if you 
>>>>>> have
>>>>>> misbehaving userspace that submits too much, reset the gpu and 
>>>>>> tell it
>>>>>> that you're sorry but won't schedule any more work.
>>>>>
>>>>> I'm not sure how you intend to know if a userspace misbehaves or 
>>>>> not. Can
>>>>> you elaborate ?
>>>>
>>>> Well that's mostly policy, currently in i915 we only have a check for
>>>> hangs, and if userspace hangs a bit too often then we stop it. I guess
>>>> you can do that with the queue unmapping you've describe in reply to
>>>> Jerome's mail.
>>>> -Daniel
>>>>
>>> What do you mean by hang ? Like the tdr mechanism in Windows (checks 
>>> if a
>>> gpu job takes more than 2 seconds, I think, and if so, terminates 
>>> the job).
>>
>> Essentially yes. But we also have some hw features to kill jobs quicker,
>> e.g. for media workloads.
>> -Daniel
>>
>
> Yeah, so this is what I'm talking about when I say that you and Jerome 
> come from a graphics POV and amdkfd come from a compute POV, no 
> offense intended.
>
> For compute jobs, we simply can't use this logic to terminate jobs. 
> Graphics are mostly Real-Time while compute jobs can take from a few 
> ms to a few hours!!! And I'm not talking about an entire application 
> runtime but on a single submission of jobs by the userspace app. We 
> have tests with jobs that take between 20-30 minutes to complete. In 
> theory, we can even imagine a compute job which takes 1 or 2 days (on 
> larger APUs).
>
> Now, I understand the question of how do we prevent the compute job 
> from monopolizing the GPU, and internally here we have some ideas that 
> we will probably share in the next few days, but my point is that I 
> don't think we can terminate a compute job because it is running for 
> more than x seconds. It is like you would terminate a CPU process 
> which runs more than x seconds.

Yeah that's why one of the first things I've did was making the timeout 
configurable in the radeon module.

But it doesn't necessary needs be a timeout, we should also kill a 
running job submission if the CPU process associated with the job is killed.

> I think this is a *very* important discussion (detecting a misbehaved 
> compute process) and I would like to continue it, but I don't think 
> moving the job submission from userspace control to kernel control 
> will solve this core problem.

We need to get this topic solved, otherwise the driver won't make it 
upstream. Allowing userpsace to monopolizing resources either memory, 
CPU or GPU time or special things like counters etc... is a strict no go 
for a kernel module.

I agree that moving the job submission from userpsace to kernel wouldn't 
solve this problem. As Daniel and I pointed out now multiple times it's 
rather easily possible to prevent further job submissions from 
userspace, in the worst case by unmapping the doorbell page.

Moving it to an IOCTL would just make it a bit less complicated.

Christian.

>
>     Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
