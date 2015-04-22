Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4886B006C
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 15:07:36 -0400 (EDT)
Received: by qcyk17 with SMTP id k17so98879938qcy.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:07:36 -0700 (PDT)
Received: from mail-qc0-x22a.google.com (mail-qc0-x22a.google.com. [2607:f8b0:400d:c01::22a])
        by mx.google.com with ESMTPS id g88si5925780qgf.66.2015.04.22.12.07.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 12:07:35 -0700 (PDT)
Received: by qcbii10 with SMTP id ii10so98872505qcb.2
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:07:35 -0700 (PDT)
Date: Wed, 22 Apr 2015 15:07:31 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422190730.GC4062@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <1429663372.27410.75.camel@kernel.crashing.org>
 <20150422005757.GP5561@linux.vnet.ibm.com>
 <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org>
 <20150422163135.GA4062@gmail.com>
 <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, Apr 22, 2015 at 12:14:50PM -0500, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Jerome Glisse wrote:
> 
> > Glibc hooks will not work, this is about having same address space on
> > CPU and GPU/accelerator while allowing backing memory to be regular
> > system memory or device memory all this in a transparent manner to
> > userspace program and library.
> 
> If you control the address space used by malloc and provide your own
> implementation then I do not see why this would not work.

mmaped file, shared memory, anonymous memory allocated outside the control
of the library that want to use the GPU. I keep repeating myself i dunno
what words are wrong.

> 
> > You also have to think at things like mmaped file, let say you have a
> > big file on disk and you want to crunch number from its data, you do
> > not want to copy it, instead you want to to the usual mmap and just
> > have device driver do migration to device memory (how device driver
> > make the decision is a different problem and this can be entirely
> > leave to the userspace application or their can be heuristic or both).
> 
> If the data is on disk then you cannot access it. If its in the page cache
> or in the device then you can mmap it. Not sure how you could avoid a copy
> unless the device can direct read from disk via another controller.
> 

Page cache page are allocated by the kernel how do you propose we map
them to the device transparently without touching a single line of
kernel code ?

Moreover yes there are disk where you can directly map each disk page to
the device without ever allocating a page and copying the data (some ssd
on pcie device allows that).


> > Glibc hooks do not work with share memory either and again this is
> > a usecase we care about. You really have to think of let's have today
> > applications start using those accelerators without the application
> > even knowing about it.
> 
> Applications always have to be reworked. This does not look like a high
> performance solution but some sort way of emulation for legacy code? HPC
> codes are mostly written to the hardware and they will be modified as
> needed to use maximum performance that the hardware will permit.

No, application do not need to be rewritten and that is the point i am
trying to get accross and you keep denying. Many applications use library
to perform scientific computation, this is very common, and you only need
to port the library. In today world if you want to leverage the GPU you
will have to perform copy of all data the application submit to the library.
Only people writting the library would need to know about efficient algo
for GPU and the application can be left alone ignoring all the gory
details.

Now with solution we are proposing there will be no copy, the malloced
memory of the application will be accessible to the GPU transparently.
This is not the case today. Today you need to use specialize allocator
if you want to use same kind of address space. We want to move away from
that model. What is it you do not understand here ?

> 
> > So you would not know before hand what will end up being use by the
> > GPU/accelerator and would need to be allocated from special memory.
> > We do not want today model of using GPU, we want to provide tomorrow
> > infrastructure for using GPU in a transparent way.
> 
> Urm... Then provide hardware that actually givse you a performance
> benefit instead of proposing some weird software solution that
> makes old software work? Transparency with the random varying latencies
> that you propose will kill performance of MPI jobs as well as make the
> system unusable for financial applications. This seems be wrong all
> around.

I have repeated numerous time what is propose here will not imped in any
way your precious low latencies workload on contrary it will benefit you.

Is it be easier to debug an application where you do not need different
interpretation for pointer value depending if an object is allocated for
GPU or if it is allocated for CPU ? Don't you think that avoinding
different address space is not a benefit ?

That you will not benefit from automatic memory migration is a given, i
repeatly acknownlegded that point but you just seems to ignore that. I
also repeatedly said that what we propose will in noway forbid total
control by application that want such control. So yes you will not
benefit from numa migration but you are not alone and thousand of others
application will benefit from it. Please stop seeing the world through
the only use case you know and care about.


> 
> > I understand that the application you care about wants to be clever
> > and can make better decission and we intend to support that, but this
> > does not need to be at the expense of all the others applications.
> > Like i said numerous time the decission to migrate memory is a device
> > driver decission and how the device driver make that decission can
> > be entirely control by userspace through proper device driver API.
> 
> What application would be using this? HPC probably not given the
> sensitivity to random latencies. Hadoop style stuff?

Again think any application that link against some library that can
benefit from GPU like https://www.gnu.org/software/gsl/ and countless
others. There is a whole word of application that do not run on HPC and
that can benefit from that. Even a standard office suite or even your
mail client to search string inside your mail database.

It is a matter of enabling those application to transparently use the
GPU in a way that does not need each of their programmer to deal with
separate address space or details of each GPU to know when to migrate
or not memory. Like i said for those proper heuristic will give good
results and again and again your application can stay in total control
if it believes it will make better decission.

> 
> > Bottom line is we want today anonymous, share or file mapped memory
> > to stay the only kind of memory that exist and we want to choose the
> > backing store of each of those kind for better placement depending
> > on how memory is use (again which can be in the total control of
> > the application). But we do not want to introduce a third kind of
> > disjoint memory to userspace, this is today situation and we want
> > to move forward to tomorrow solution.
> 
> Frankly, I do not see any benefit here, nor a use case and I wonder who
> would adopt this. The future requires higher performance and not more band
> aid.

Well all i can tell you is that if you go to any conference where there are
people doing GPGPU they will  almost all tells you they would love unified
address space. Why in hell do you think the OpenCL 2.0 specification makes
that a corner stone, with different level of support, the lowest level being
what we have today using special allocator.

There is a whole industry out there spending billions of dollars on what
you call a band aid. Don't you think they have a market for it ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
