Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id AA22A6B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 03:05:51 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id hn18so4907906igb.9
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 00:05:51 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id w8si3464037icp.6.2014.07.23.00.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Jul 2014 00:05:50 -0700 (PDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so1115513iga.13
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 00:05:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53CF5B30.50209@amd.com>
References: <20140721155851.GB4519@gmail.com>
	<20140721170546.GB15237@phenom.ffwll.local>
	<53CD4DD2.10906@amd.com>
	<CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
	<53CD5ED9.2040600@amd.com>
	<20140721190306.GB5278@gmail.com>
	<20140722072851.GH15237@phenom.ffwll.local>
	<53CE1E9C.8020105@amd.com>
	<CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
	<53CE346B.1080601@amd.com>
	<20140722111515.GJ15237@phenom.ffwll.local>
	<53CF5B30.50209@amd.com>
Date: Wed, 23 Jul 2014 09:05:50 +0200
Message-ID: <CAKMK7uFtSStEewVivbXAT1VC4t2Y+suTaEmQA4=UptK1UBLSmg@mail.gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?Q?Michel_D=C3=A4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>

On Wed, Jul 23, 2014 at 8:50 AM, Oded Gabbay <oded.gabbay@amd.com> wrote:
> On 22/07/14 14:15, Daniel Vetter wrote:
>>
>> On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
>>>
>>> On 22/07/14 12:21, Daniel Vetter wrote:
>>>>
>>>> On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com>
>>>> wrote:
>>>>>>
>>>>>> Exactly, just prevent userspace from submitting more. And if you have
>>>>>> misbehaving userspace that submits too much, reset the gpu and tell it
>>>>>> that you're sorry but won't schedule any more work.
>>>>>
>>>>>
>>>>> I'm not sure how you intend to know if a userspace misbehaves or not.
>>>>> Can
>>>>> you elaborate ?
>>>>
>>>>
>>>> Well that's mostly policy, currently in i915 we only have a check for
>>>> hangs, and if userspace hangs a bit too often then we stop it. I guess
>>>> you can do that with the queue unmapping you've describe in reply to
>>>> Jerome's mail.
>>>> -Daniel
>>>>
>>> What do you mean by hang ? Like the tdr mechanism in Windows (checks if a
>>> gpu job takes more than 2 seconds, I think, and if so, terminates the
>>> job).
>>
>>
>> Essentially yes. But we also have some hw features to kill jobs quicker,
>> e.g. for media workloads.
>> -Daniel
>>
>
> Yeah, so this is what I'm talking about when I say that you and Jerome come
> from a graphics POV and amdkfd come from a compute POV, no offense intended.
>
> For compute jobs, we simply can't use this logic to terminate jobs. Graphics
> are mostly Real-Time while compute jobs can take from a few ms to a few
> hours!!! And I'm not talking about an entire application runtime but on a
> single submission of jobs by the userspace app. We have tests with jobs that
> take between 20-30 minutes to complete. In theory, we can even imagine a
> compute job which takes 1 or 2 days (on larger APUs).
>
> Now, I understand the question of how do we prevent the compute job from
> monopolizing the GPU, and internally here we have some ideas that we will
> probably share in the next few days, but my point is that I don't think we
> can terminate a compute job because it is running for more than x seconds.
> It is like you would terminate a CPU process which runs more than x seconds.
>
> I think this is a *very* important discussion (detecting a misbehaved
> compute process) and I would like to continue it, but I don't think moving
> the job submission from userspace control to kernel control will solve this
> core problem.

Well graphics gets away with cooperative scheduling since usually
people want to see stuff within a few frames, so we can legitimately
kill jobs after a fairly short timeout. Imo if you want to allow
userspace to submit compute jobs that are atomic and take a few
minutes to hours with no break-up in between and no hw means to
preempt then that design is screwed up. We really can't tell the core
vm that "sorry we will hold onto these gobloads of memory you really
need now for another few hours". Pinning memory like that essentially
without a time limit is restricted to root.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
