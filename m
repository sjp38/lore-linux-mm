Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 383F96B008C
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 13:14:53 -0400 (EDT)
Received: by qgdy78 with SMTP id y78so86752819qgd.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 10:14:53 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id u35si5582293qge.81.2015.04.22.10.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 10:14:51 -0700 (PDT)
Date: Wed, 22 Apr 2015 12:14:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150422163135.GA4062@gmail.com>
Message-ID: <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 22 Apr 2015, Jerome Glisse wrote:

> Glibc hooks will not work, this is about having same address space on
> CPU and GPU/accelerator while allowing backing memory to be regular
> system memory or device memory all this in a transparent manner to
> userspace program and library.

If you control the address space used by malloc and provide your own
implementation then I do not see why this would not work.

> You also have to think at things like mmaped file, let say you have a
> big file on disk and you want to crunch number from its data, you do
> not want to copy it, instead you want to to the usual mmap and just
> have device driver do migration to device memory (how device driver
> make the decision is a different problem and this can be entirely
> leave to the userspace application or their can be heuristic or both).

If the data is on disk then you cannot access it. If its in the page cache
or in the device then you can mmap it. Not sure how you could avoid a copy
unless the device can direct read from disk via another controller.

> Glibc hooks do not work with share memory either and again this is
> a usecase we care about. You really have to think of let's have today
> applications start using those accelerators without the application
> even knowing about it.

Applications always have to be reworked. This does not look like a high
performance solution but some sort way of emulation for legacy code? HPC
codes are mostly written to the hardware and they will be modified as
needed to use maximum performance that the hardware will permit.

> So you would not know before hand what will end up being use by the
> GPU/accelerator and would need to be allocated from special memory.
> We do not want today model of using GPU, we want to provide tomorrow
> infrastructure for using GPU in a transparent way.

Urm... Then provide hardware that actually givse you a performance
benefit instead of proposing some weird software solution that
makes old software work? Transparency with the random varying latencies
that you propose will kill performance of MPI jobs as well as make the
system unusable for financial applications. This seems be wrong all
around.

> I understand that the application you care about wants to be clever
> and can make better decission and we intend to support that, but this
> does not need to be at the expense of all the others applications.
> Like i said numerous time the decission to migrate memory is a device
> driver decission and how the device driver make that decission can
> be entirely control by userspace through proper device driver API.

What application would be using this? HPC probably not given the
sensitivity to random latencies. Hadoop style stuff?

> Bottom line is we want today anonymous, share or file mapped memory
> to stay the only kind of memory that exist and we want to choose the
> backing store of each of those kind for better placement depending
> on how memory is use (again which can be in the total control of
> the application). But we do not want to introduce a third kind of
> disjoint memory to userspace, this is today situation and we want
> to move forward to tomorrow solution.

Frankly, I do not see any benefit here, nor a use case and I wonder who
would adopt this. The future requires higher performance and not more band
aid.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
