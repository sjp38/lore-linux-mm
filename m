Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id EAA90900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 20:05:43 -0400 (EDT)
Received: by qcbii10 with SMTP id ii10so85091775qcb.2
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:05:43 -0700 (PDT)
Received: from mail-qk0-x231.google.com (mail-qk0-x231.google.com. [2607:f8b0:400d:c09::231])
        by mx.google.com with ESMTPS id dh6si3526821qcb.15.2015.04.21.17.05.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Apr 2015 17:05:42 -0700 (PDT)
Received: by qkx62 with SMTP id 62so217689942qkx.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:05:42 -0700 (PDT)
Date: Tue, 21 Apr 2015 20:05:39 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150422000538.GB6046@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, Apr 21, 2015 at 06:49:29PM -0500, Christoph Lameter wrote:
> On Tue, 21 Apr 2015, Paul E. McKenney wrote:
> 
> > Thoughts?
> 
> Use DAX for memory instead of the other approaches? That way it is
> explicitly clear what information is put on the CAPI device.
> 

Memory on this device should not be considered as something special
(even if it is). More below.

[...]
> 
> > 	3.	The device's memory is treated like normal system
> > 		memory by the Linux kernel, for example, each page has a
> > 		"struct page" associate with it.  (In contrast, the
> > 		traditional approach has used special-purpose OS mechanisms
> > 		to manage the device's memory, and this memory was treated
> > 		as MMIO space by the kernel.)
> 
> Why do we need a struct page? If so then maybe equip DAX with a struct
> page so that the contents of the device memory can be controlled via a
> filesystem? (may be custom to the needs of the device).

So big use case here, let say you have an application that rely on a
scientific library that do matrix computation. Your application simply
use malloc and give pointer to this scientific library. Now let say
the good folks working on this scientific library wants to leverage
the GPU, they could do it by allocating GPU memory through GPU specific
API and copy data in and out. For matrix that can be easy enough, but
still inefficient. What you really want is the GPU directly accessing
this malloced chunk of memory, eventualy migrating it to device memory
while performing the computation and migrating it back to system memory
once done. Which means that you do not want some kind of filesystem or
anything like that.

By allowing transparent migration you allow library to just start using
the GPU without the application being non the wiser about that. More
over when you start playing with data set that use more advance design
pattern (list, tree, vector, a mix of all the above) you do not want
to have to duplicate the list for the GPU address space and for the
regular CPU address space (which you would need to do in case of a
filesystem solution).

So the corner stone of HMM and Paul requirement are the same, we want
to be able to move normal anonymous memory as well as regular file
backed page to device memory for some period of time while at the same
time allowing the usual memory management to keep going as if nothing
was different.

Paul is working on a platform that is more advance that the one HMM try
to address and i believe the x86 platform will not have functionality
such a CAPI, at least it is not part of any roadmap i know about for
x86.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
