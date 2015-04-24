Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0AA3D6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 15:29:05 -0400 (EDT)
Received: by qcpm10 with SMTP id m10so31198380qcp.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:29:04 -0700 (PDT)
Received: from mail-qc0-x235.google.com (mail-qc0-x235.google.com. [2607:f8b0:400d:c01::235])
        by mx.google.com with ESMTPS id m83si12236612qhb.96.2015.04.24.12.29.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 12:29:03 -0700 (PDT)
Received: by qcbii10 with SMTP id ii10so31199828qcb.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:29:03 -0700 (PDT)
Date: Fri, 24 Apr 2015 15:29:00 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424192859.GF3840@gmail.com>
References: <1429756456.4915.22.camel@kernel.crashing.org>
 <alpine.DEB.2.11.1504230925250.32297@gentwo.org>
 <20150423161105.GB2399@gmail.com>
 <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
 <20150424150829.GA3840@gmail.com>
 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
 <20150424164325.GD3840@gmail.com>
 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
 <20150424171957.GE3840@gmail.com>
 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 01:56:45PM -0500, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Jerome Glisse wrote:
> 
> > > Right this is how things work and you could improve on that. Stay with the
> > > scheme. Why would that not work if you map things the same way in both
> > > environments if both accellerator and host processor can acceess each
> > > others memory?
> >
> > Again and again share address space, having a pointer means the same thing
> > for the GPU than it means for the CPU ie having a random pointer point to
> > the same memory whether it is accessed by the GPU or the CPU. While also
> > keeping the property of the backing memory. It can be share memory from
> > other process, a file mmaped from disk or simply anonymous memory and
> > thus we have no control whatsoever on how such memory is allocated.
> 
> Still no answer as to why is that not possible with the current scheme?
> You keep on talking about pointers and I keep on responding that this is a
> matter of making the address space compatible on both sides.

So if do that in a naive way, how can we migrate a chunk of memory to video
memory while still handling properly the case where CPU try to access that
same memory while it is migrated to the GPU memory.

Without modifying a single line of mm code, the only way to do this is to
either unmap from the cpu page table the range being migrated or to mprotect
it in some way. In both case the cpu access will trigger some kind of fault.

This is not the behavior we want. What we want is same address space while
being able to migrate system memory to device memory (who make that decision
should not be part of that discussion) while still gracefully handling any
CPU access.

This means if CPU access it we want to migrate memory back to system memory.
To achieve this there is no way around adding couple of if inside the mm
page fault code path. Now do you want each driver to add its own if branch
or do you want a common infrastructure to do just that ?

As i keep saying the solution you propose is what we have today, today we
have fake share address space through the trick of remapping system memory
at same address inside the GPU address space and also enforcing the use of
a special memory allocator that goes behind the back of mm code.

But this limit to only using system memory, you can not use video memory
transparently through such scheme. Some trick use today is to copy memory
to device memory and to not bother with CPU access pretend it can not happen
and as such the GPU and CPU can diverge in what they see for same address.
We want to avoid trick like this that just lead to some weird and unexpected
behavior.

As you pointed out, not using GPU memory is a waste and we want to be able
to use it. Now Paul have more sofisticated hardware that offer oportunities
to do thing in a more transparent and efficient way.

> 
> > Then you had transparent migration (transparent in the sense that we can
> > handle CPU page fault on migrated memory) and you will see that you need
> > to modify the kernel to become aware of this and provide a common code
> > to deal with all this.
> 
> If the GPU works like a CPU (which I keep hearing) then you should also be
> able to run a linu8x kernel on it and make it a regular NUMA node. Hey why
> dont we make the host cpu a GPU (hello Xeon Phi).

I am not saying it works like a CPU, i am saying it should face the same kind
of pattern when it comes to page fault, ie page fault are not the end of the
world for the GPU and you should not assume that all GPU threads will wait
for a pagefault because this is not the common case on CPU. Yes we prefer when
page fault never happen, so does the CPU.

No, you can not run the linux kernel on the GPU unless you are willing to allow
having the kernel runs on heterogneous architecture with different instruction
set. Not even going into the problematic of ring level/system level. We might
one day go down that road but i see no compeling point today.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
