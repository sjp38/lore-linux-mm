Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f179.google.com (mail-qk0-f179.google.com [209.85.220.179])
	by kanga.kvack.org (Postfix) with ESMTP id 621396B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:41:53 -0400 (EDT)
Received: by qkgx75 with SMTP id x75so35556052qkg.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:41:53 -0700 (PDT)
Received: from na01-bl2-obe.outbound.protection.outlook.com (mail-bl2on0148.outbound.protection.outlook.com. [65.55.169.148])
        by mx.google.com with ESMTPS id o2si12186307qci.22.2015.04.24.11.41.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 24 Apr 2015 11:41:52 -0700 (PDT)
Message-ID: <553A8E62.4060802@amd.com>
Date: Fri, 24 Apr 2015 21:41:38 +0300
From: Oded Gabbay <oded.gabbay@amd.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <1429756070.4915.17.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230914060.32297@gentwo.org>
 <20150423162245.GC2399@gmail.com>
In-Reply-To: <20150423162245.GC2399@gmail.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey
 Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org, "Bridgman, John" <John.Bridgman@amd.com>



On 04/23/2015 07:22 PM, Jerome Glisse wrote:
> On Thu, Apr 23, 2015 at 09:20:55AM -0500, Christoph Lameter wrote:
>> On Thu, 23 Apr 2015, Benjamin Herrenschmidt wrote:
>>
>>>> There are hooks in glibc where you can replace the memory
>>>> management of the apps if you want that.
>>>
>>> We don't control the app. Let's say we are doing a plugin for libfoo
>>> which accelerates "foo" using GPUs.
>>
>> There are numerous examples of malloc implementation that can be used =
for
>> apps without modifying the app.
>
> What about share memory pass btw process ? Or mmaped file ? Or
> a library that is loaded through dlopen and thus had no way to
> control any allocation that happen before it became active ?
>
>>>
>>> Now some other app we have no control on uses libfoo. So pointers
>>> already allocated/mapped, possibly a long time ago, will hit libfoo (=
or
>>> the plugin) and we need GPUs to churn on the data.
>>
>> IF the GPU would need to suspend one of its computation thread to wait=
 on
>> a mapping to be established on demand or so then it looks like the
>> performance of the parallel threads on a GPU will be significantly
>> compromised. You would want to do the transfer explicitly in some fash=
ion
>> that meshes with the concurrent calculation in the GPU. You do not wan=
t
>> stalls while GPU number crunching is ongoing.
>
> You do not understand how GPU works. GPU have a pools of thread, and th=
ey
> always try to have the pool as big as possible so that when a group of
> thread is waiting for some memory access, there are others thread ready
> to perform some operation. GPU are about hidding memory latency that's
> what they are good at. But they only achieve that when they have more
> thread in flight than compute unit. The whole thread scheduling is done
> by hardware and barely control by the device driver.
>
> So no having the GPU wait for a page fault is not as dramatic as you
> think. If you use GPU as they are intended to use you might even never
> notice the pagefault and reach close to the theoritical throughput of
> the GPU nonetheless.
>
>
>>
>>> The point I'm making is you are arguing against a usage model which h=
as
>>> been repeatedly asked for by large amounts of customer (after all tha=
t's
>>> also why HMM exists).
>>
>> I am still not clear what is the use case for this would be. Who is as=
king
>> for this?
>
> Everyone but you ? OpenCL 2.0 specific request it and have several leve=
l
> of support about transparent address space. The lowest one is the one
> implemented today in which application needs to use a special memory
> allocator.
>
> The most advance one imply integration with the kernel in which any
> memory (mmaped file, share memory or anonymous memory) can be use by
> the GPU and does not need to come from a special allocator.
>
> Everyone in the industry is moving toward the most advance one. That
> is the raison d'=EAtre of HMM, to provide this functionality on hw
> platform that do not have things such as CAPI. Which is x86/arm.
>
> So use case is all application using OpenCL or Cuda. So pretty much
> everyone doing GPGPU wants this. I dunno how you can't see that.
> Share address space is so much easier. Believe it or not most coders
> do not have deep knowledge of how things work and if you can remove
> the complexity of different memory allocation and different address
> space from them they will be happy.
>
> Cheers,
> J=E9r=F4me
I second what Jerome said, and add that one of the key features of HSA=20
is the ptr-is-a-ptr scheme, where the applications do *not* need to=20
handle different address spaces. Instead, all the memory is seen as a=20
unified address space.

See slide 6 on the following presentation:
http://www.slideshare.net/hsafoundation/hsa-overview

Thanks,
	Oded
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
