Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 43B846B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:13:28 -0400 (EDT)
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0L5V00ED7EQNVB50@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 20 Jul 2010 20:13:35 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L5V004LWEQMB2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 20 Jul 2010 20:13:35 +0100 (BST)
Date: Tue, 20 Jul 2010 21:14:58 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
Message-id: <op.vf5o28st7p4s8u@pikus>
Content-transfer-encoding: Quoted-Printable
References: <cover.1279639238.git.m.nazarewicz@samsung.com>
 <d6d104950c1391eaf3614d56615617cee5722fb4.1279639238.git.m.nazarewicz@samsung.com>
 <adceebd371e8a66a2c153f429b38068eca99e99f.1279639238.git.m.nazarewicz@samsung.com>
 <1279649724.26765.23.camel@c-dwalke-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
To: Daniel Walker <dwalker@codeaurora.org>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Pawel Osciak <p.osciak@samsung.com>, Xiaolin Zhang <xiaolin.zhang@intel.com>, Hiremath Vaibhav <hvaibhav@ti.com>, Robert Fekete <robert.fekete@stericsson.com>, Marcus Lorentzon <marcus.xm.lorentzon@stericsson.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-msm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jul 2010 20:15:24 +0200, Daniel Walker <dwalker@codeaurora.or=
g> wrote:

> On Tue, 2010-07-20 at 17:51 +0200, Michal Nazarewicz wrote:
>> +** Use cases
>> +
>> +    Lets analyse some imaginary system that uses the CMA to see how
>> +    the framework can be used and configured.
>> +
>> +
>> +    We have a platform with a hardware video decoder and a camera
>> each
>> +    needing 20 MiB of memory in worst case.  Our system is written i=
n
>> +    such a way though that the two devices are never used at the sam=
e
>> +    time and memory for them may be shared.  In such a system the
>> +    following two command line arguments would be used:
>> +
>> +        cma=3Dr=3D20M cma_map=3Dvideo,camera=3Dr
>
> This seems inelegant to me.. It seems like these should be connected
> with the drivers themselves vs. doing it on the command like for
> everything. You could have the video driver declare it needs 20megs, a=
nd
> the the camera does the same but both indicate it's shared ..
>
> If you have this disconnected from the drivers it will just cause
> confusion, since few will know what these parameters should be for a
> given driver set. It needs to be embedded in the kernel.

I see your point but the problem is that devices drivers don't know the
rest of the system neither they know what kind of use cases the system
should support.


Lets say, we have a camera, a JPEG encoder, a video decoder and
scaler (ie. devices that scales raw image).  We want to support the
following 3 use cases:

1. Camera's output is scaled and displayed in real-time.
2. Single frame is taken from camera and saved as JPEG image.
3. A video file is decoded, scaled and displayed.

What is apparent is that camera and video decoder are never running
at the same time.  The same situation is with JPEG encoder and scaler.
 From this knowledge we can construct the following:

   cma=3Da=3D10M;b=3D10M cma_map=3Dcamera,video=3Da;jpeg,scaler=3Db

This may be a silly example but it shows that the configuration of
memory regions and device->regions mapping should be done after
some investigation rather then from devices which may have not enough
knowledge.


One of the purposes of the CMA framework is to make it let device
drivers completely forget about the memory management and enjoy
a simple API.


CMA core has a cma_defaults() function which can be called from
platform initialisation code.  It makes it easy to provide default
values for the cma and cma_map parameters.  This makes it possible
to provide a default which will work in many/most cases even if
user does not provide custom cma and/or cma_map parameters.


Having said that, some way of letting device drivers request
a region if one has not been defined for them may be a good idea.
I'll have to think about it...

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
