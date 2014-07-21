Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DCC646B003B
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 14:41:42 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so9525264pdj.8
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 11:41:42 -0700 (PDT)
Received: from na01-by2-obe.outbound.protection.outlook.com (mail-by2lp0236.outbound.protection.outlook.com. [207.46.163.236])
        by mx.google.com with ESMTPS id cc10si7551922pdb.230.2014.07.21.11.41.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 21 Jul 2014 11:41:42 -0700 (PDT)
Message-ID: <53CD5ED9.2040600@amd.com>
Date: Mon, 21 Jul 2014 21:41:29 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
References: <53C7D645.3070607@amd.com>	<20140720174652.GE3068@gmail.com>
	<53CD0961.4070505@amd.com>	<53CD17FD.3000908@vodafone.de>
	<20140721152511.GW15237@phenom.ffwll.local>	<20140721155851.GB4519@gmail.com>
	<20140721170546.GB15237@phenom.ffwll.local>	<53CD4DD2.10906@amd.com>
 <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
In-Reply-To: <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Jerome Glisse <j.glisse@gmail.com>, =?UTF-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John
 Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew
 Lewycky <Andrew.Lewycky@amd.com>, =?UTF-8?B?TWljaGVsIETDpG56ZXI=?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On 21/07/14 21:22, Daniel Vetter wrote:
> On Mon, Jul 21, 2014 at 7:28 PM, Oded Gabbay <oded.gabbay@amd.com> wrote:
>>> I'm not sure whether we can do the same trick with the hw scheduler. But
>>> then unpinning hw contexts will drain the pipeline anyway, so I guess we
>>> can just stop feeding the hw scheduler until it runs dry. And then unpin
>>> and evict.
>> So, I'm afraid but we can't do this for AMD Kaveri because:
> 
> Well as long as you can drain the hw scheduler queue (and you can do
> that, worst case you have to unmap all the doorbells and other stuff
> to intercept further submission from userspace) you can evict stuff.

I can't drain the hw scheduler queue, as I can't do mid-wave preemption.
Moreover, if I use the dequeue request register to preempt a queue
during a dispatch it may be that some waves (wave groups actually) of
the dispatch have not yet been created, and when I reactivate the mqd,
they should be created but are not. However, this works fine if you use
the HIQ. the CP ucode correctly saves and restores the state of an
outstanding dispatch. I don't think we have access to the state from
software at all, so it's not a bug, it is "as designed".

> And if we don't want compute to be a denial of service on the display
> side of the driver we need this ability. Now if you go through an
> ioctl instead of the doorbell (I agree with Jerome here, the doorbell
> should be supported by benchmarks on linux) this gets a bit easier,
> but it's not a requirement really.
> -Daniel
> 
On KV, we have the theoretical option of DOS on the display side as we
can't do a mid-wave preemption. On CZ, we won't have this problem.

	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
