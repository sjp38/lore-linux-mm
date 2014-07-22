Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3236B0035
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 04:20:01 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id f51so6416756qge.25
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 01:20:01 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1blp0186.outbound.protection.outlook.com. [207.46.163.186])
        by mx.google.com with ESMTPS id o11si33467881qay.79.2014.07.22.01.20.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Jul 2014 01:20:01 -0700 (PDT)
Message-ID: <53CE1E9C.8020105@amd.com>
Date: Tue, 22 Jul 2014 11:19:40 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <20140720174652.GE3068@gmail.com> <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de> <20140721152511.GW15237@phenom.ffwll.local>
 <20140721155851.GB4519@gmail.com> <20140721170546.GB15237@phenom.ffwll.local>
 <53CD4DD2.10906@amd.com>
 <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
 <53CD5ED9.2040600@amd.com> <20140721190306.GB5278@gmail.com>
 <20140722072851.GH15237@phenom.ffwll.local>
In-Reply-To: <20140722072851.GH15237@phenom.ffwll.local>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, =?ISO-8859-1?Q?Christian_K=F6ni?= =?ISO-8859-1?Q?g?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg
 Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?ISO-8859-1?Q?Michel_D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On 22/07/14 10:28, Daniel Vetter wrote:
> On Mon, Jul 21, 2014 at 03:03:07PM -0400, Jerome Glisse wrote:
>> On Mon, Jul 21, 2014 at 09:41:29PM +0300, Oded Gabbay wrote:
>>> On 21/07/14 21:22, Daniel Vetter wrote:
>>>> On Mon, Jul 21, 2014 at 7:28 PM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>>>>>> I'm not sure whether we can do the same trick with the hw scheduler. But
>>>>>> then unpinning hw contexts will drain the pipeline anyway, so I guess we
>>>>>> can just stop feeding the hw scheduler until it runs dry. And then unpin
>>>>>> and evict.
>>>>> So, I'm afraid but we can't do this for AMD Kaveri because:
>>>>
>>>> Well as long as you can drain the hw scheduler queue (and you can do
>>>> that, worst case you have to unmap all the doorbells and other stuff
>>>> to intercept further submission from userspace) you can evict stuff.
>>>
>>> I can't drain the hw scheduler queue, as I can't do mid-wave preemption.
>>> Moreover, if I use the dequeue request register to preempt a queue
>>> during a dispatch it may be that some waves (wave groups actually) of
>>> the dispatch have not yet been created, and when I reactivate the mqd,
>>> they should be created but are not. However, this works fine if you use
>>> the HIQ. the CP ucode correctly saves and restores the state of an
>>> outstanding dispatch. I don't think we have access to the state from
>>> software at all, so it's not a bug, it is "as designed".
>>>
>>
>> I think here Daniel is suggesting to unmapp the doorbell page, and track
>> each write made by userspace to it and while unmapped wait for the gpu to
>> drain or use some kind of fence on a special queue. Once GPU is drain we
>> can move pinned buffer, then remap the doorbell and update it to the last
>> value written by userspace which will resume execution to the next job.
>
> Exactly, just prevent userspace from submitting more. And if you have
> misbehaving userspace that submits too much, reset the gpu and tell it
> that you're sorry but won't schedule any more work.

I'm not sure how you intend to know if a userspace misbehaves or not. Can you 
elaborate ?

	Oded
>
> We have this already in i915 (since like all other gpus we're not
> preempting right now) and it works. There's some code floating around to
> even restrict the reset to _just_ the offending submission context, with
> nothing else getting corrupted.
>
> You can do all this with the doorbells and unmapping them, but it's a
> pain. Much easier if you have a real ioctl, and I haven't seen anyone with
> perf data indicating that an ioctl would be too much overhead on linux.
> Neither in this thread nor internally here at intel.
> -Daniel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
