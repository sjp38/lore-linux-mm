Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0DD2B6B0037
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:03:08 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so5458464qaj.35
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:03:07 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id j4si11741028qao.126.2014.07.21.12.03.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 12:03:07 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id f51so5826150qge.18
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:03:07 -0700 (PDT)
Date: Mon, 21 Jul 2014 15:03:07 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH v2 00/25] AMDKFD kernel driver
Message-ID: <20140721190306.GB5278@gmail.com>
References: <53C7D645.3070607@amd.com>
 <20140720174652.GE3068@gmail.com>
 <53CD0961.4070505@amd.com>
 <53CD17FD.3000908@vodafone.de>
 <20140721152511.GW15237@phenom.ffwll.local>
 <20140721155851.GB4519@gmail.com>
 <20140721170546.GB15237@phenom.ffwll.local>
 <53CD4DD2.10906@amd.com>
 <CAKMK7uFhvGtxj_d6X=4OBdVSm6cT1-Z-DiTE-FTWMnFjY2uqMQ@mail.gmail.com>
 <53CD5ED9.2040600@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53CD5ED9.2040600@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oded Gabbay <oded.gabbay@amd.com>
Cc: Daniel Vetter <daniel@ffwll.ch>, Christian =?iso-8859-1?Q?K=F6nig?= <deathsimple@vodafone.de>, David Airlie <airlied@linux.ie>, Alex Deucher <alexdeucher@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, John Bridgman <John.Bridgman@amd.com>, Joerg Roedel <joro@8bytes.org>, Andrew Lewycky <Andrew.Lewycky@amd.com>, Michel =?iso-8859-1?Q?D=E4nzer?= <michel.daenzer@amd.com>, Ben Goz <Ben.Goz@amd.com>, Alexey Skidanov <Alexey.Skidanov@amd.com>, Evgeny Pinchuk <Evgeny.Pinchuk@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, linux-mm <linux-mm@kvack.org>

On Mon, Jul 21, 2014 at 09:41:29PM +0300, Oded Gabbay wrote:
> On 21/07/14 21:22, Daniel Vetter wrote:
> > On Mon, Jul 21, 2014 at 7:28 PM, Oded Gabbay <oded.gabbay@amd.com> wrote:
> >>> I'm not sure whether we can do the same trick with the hw scheduler. But
> >>> then unpinning hw contexts will drain the pipeline anyway, so I guess we
> >>> can just stop feeding the hw scheduler until it runs dry. And then unpin
> >>> and evict.
> >> So, I'm afraid but we can't do this for AMD Kaveri because:
> > 
> > Well as long as you can drain the hw scheduler queue (and you can do
> > that, worst case you have to unmap all the doorbells and other stuff
> > to intercept further submission from userspace) you can evict stuff.
> 
> I can't drain the hw scheduler queue, as I can't do mid-wave preemption.
> Moreover, if I use the dequeue request register to preempt a queue
> during a dispatch it may be that some waves (wave groups actually) of
> the dispatch have not yet been created, and when I reactivate the mqd,
> they should be created but are not. However, this works fine if you use
> the HIQ. the CP ucode correctly saves and restores the state of an
> outstanding dispatch. I don't think we have access to the state from
> software at all, so it's not a bug, it is "as designed".
> 

I think here Daniel is suggesting to unmapp the doorbell page, and track
each write made by userspace to it and while unmapped wait for the gpu to
drain or use some kind of fence on a special queue. Once GPU is drain we
can move pinned buffer, then remap the doorbell and update it to the last
value written by userspace which will resume execution to the next job.

> > And if we don't want compute to be a denial of service on the display
> > side of the driver we need this ability. Now if you go through an
> > ioctl instead of the doorbell (I agree with Jerome here, the doorbell
> > should be supported by benchmarks on linux) this gets a bit easier,
> > but it's not a requirement really.
> > -Daniel
> > 
> On KV, we have the theoretical option of DOS on the display side as we
> can't do a mid-wave preemption. On CZ, we won't have this problem.
> 
> 	Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
