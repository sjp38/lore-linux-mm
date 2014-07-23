Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id AD7816B0036
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 02:50:44 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so1064385pdb.13
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 23:50:44 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0237.outbound.protection.outlook.com. [207.46.163.237])
        by mx.google.com with ESMTPS id py9si1442470pac.70.2014.07.22.23.50.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Jul 2014 23:50:43 -0700 (PDT)
Message-ID: <53CF5B30.50209@amd.com>
Date: Wed, 23 Jul 2014 09:50:24 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <20140721155851.GB4519@gmail.com>
 <20140721170546.GB15237@phenom.ffwll.local> <53CD4DD2.10906@amd.com>
 <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
 <53CD5ED9.2040600@amd.com> <20140721190306.GB5278@gmail.com>
 <20140722072851.GH15237@phenom.ffwll.local> <53CE1E9C.8020105@amd.com>
 <CAKMK7uH+okhn4YGOzrXZ1LM3S2myxdu=_63LGMduwV-WZn06CA@mail.gmail.com>
 <53CE346B.1080601@amd.com> <20140722111515.GJ15237@phenom.ffwll.local>
In-Reply-To: <20140722111515.GJ15237@phenom.ffwll.local>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, =?windows-1252?Q?Christian_K=F6?= =?windows-1252?Q?nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg
 Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?windows-1252?Q?Michel_D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>, "Sellek, Tom" <Tom.Sellek@amd.com>

On 22/07/14 14:15, Daniel Vetter wrote:
> On Tue, Jul 22, 2014 at 12:52:43PM +0300, Oded Gabbay wrote:
>> On 22/07/14 12:21, Daniel Vetter wrote:
>>> On Tue, Jul 22, 2014 at 10:19 AM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>>>>> Exactly, just prevent userspace from submitting more. And if you have
>>>>> misbehaving userspace that submits too much, reset the gpu and tell it
>>>>> that you're sorry but won't schedule any more work.
>>>>
>>>> I'm not sure how you intend to know if a userspace misbehaves or not. Can
>>>> you elaborate ?
>>>
>>> Well that's mostly policy, currently in i915 we only have a check for
>>> hangs, and if userspace hangs a bit too often then we stop it. I guess
>>> you can do that with the queue unmapping you've describe in reply to
>>> Jerome's mail.
>>> -Daniel
>>>
>> What do you mean by hang ? Like the tdr mechanism in Windows (checks if a
>> gpu job takes more than 2 seconds, I think, and if so, terminates the job).
>
> Essentially yes. But we also have some hw features to kill jobs quicker,
> e.g. for media workloads.
> -Daniel
>

Yeah, so this is what I'm talking about when I say that you and Jerome come from 
a graphics POV and amdkfd come from a compute POV, no offense intended.

For compute jobs, we simply can't use this logic to terminate jobs. Graphics are 
mostly Real-Time while compute jobs can take from a few ms to a few hours!!! And 
I'm not talking about an entire application runtime but on a single submission 
of jobs by the userspace app. We have tests with jobs that take between 20-30 
minutes to complete. In theory, we can even imagine a compute job which takes 1 
or 2 days (on larger APUs).

Now, I understand the question of how do we prevent the compute job from 
monopolizing the GPU, and internally here we have some ideas that we will 
probably share in the next few days, but my point is that I don't think we can 
terminate a compute job because it is running for more than x seconds. It is 
like you would terminate a CPU process which runs more than x seconds.

I think this is a *very* important discussion (detecting a misbehaved compute 
process) and I would like to continue it, but I don't think moving the job 
submission from userspace control to kernel control will solve this core problem.

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
