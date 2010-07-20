Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7D33D6B02A5
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:38:05 -0400 (EDT)
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
From: Daniel Walker <dwalker@codeaurora.org>
In-Reply-To: <op.vf5o28st7p4s8u@pikus>
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
	 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
	 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
	 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
	 <op.vf5o28st7p4s8u@pikus>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 20 Jul 2010 12:38:18 -0700
Message-ID: <1279654698.26765.31.camel@c-dwalke-linux.qualcomm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?Q?Micha=C5=82?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-20 at 21:14 +0200, MichaA? Nazarewicz wrote:
> On Tue, 20 Jul 2010 20:15:24 +0200, Daniel Walker <dwalker@codeaurora.org> wrote:
> 
> > On Tue, 2010-07-20 at 17:51 +0200, Michal Nazarewicz wrote:
> >> +** Use cases
> >> +
> >> +    Lets analyse some imaginary system that uses the CMA to see how
> >> +    the framework can be used and configured.
> >> +
> >> +
> >> +    We have a platform with a hardware video decoder and a camera
> >> each
> >> +    needing 20 MiB of memory in worst case.  Our system is written in
> >> +    such a way though that the two devices are never used at the same
> >> +    time and memory for them may be shared.  In such a system the
> >> +    following two command line arguments would be used:
> >> +
> >> +        cma=r=20M cma_map=video,camera=r
> >
> > This seems inelegant to me.. It seems like these should be connected
> > with the drivers themselves vs. doing it on the command like for
> > everything. You could have the video driver declare it needs 20megs, and
> > the the camera does the same but both indicate it's shared ..
> >
> > If you have this disconnected from the drivers it will just cause
> > confusion, since few will know what these parameters should be for a
> > given driver set. It needs to be embedded in the kernel.
> 
> I see your point but the problem is that devices drivers don't know the
> rest of the system neither they know what kind of use cases the system
> should support.
> 
> 
> Lets say, we have a camera, a JPEG encoder, a video decoder and
> scaler (ie. devices that scales raw image).  We want to support the
> following 3 use cases:
> 
> 1. Camera's output is scaled and displayed in real-time.
> 2. Single frame is taken from camera and saved as JPEG image.
> 3. A video file is decoded, scaled and displayed.
> 
> What is apparent is that camera and video decoder are never running
> at the same time.  The same situation is with JPEG encoder and scaler.
>  From this knowledge we can construct the following:
> 
>    cma=a=10M;b=10M cma_map=camera,video=a;jpeg,scaler=b

It should be implicit tho. If the video driver isn't using the memory
then it should tell your framework that the memory is not used. That way
something else can use it.

(btw, these strings your creating yikes, talk about confusing ..)

> One of the purposes of the CMA framework is to make it let device
> drivers completely forget about the memory management and enjoy
> a simple API.

The driver, and it's maintainer, are really the best people to know how
much memory they need and when it's used/unused. You don't really want
to architect them out.

Daniel

-- 
Sent by an consultant of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
