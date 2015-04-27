Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f41.google.com (mail-vn0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 35B5F6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 16:52:12 -0400 (EDT)
Received: by vnbg7 with SMTP id g7so13693502vnb.10
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 13:52:12 -0700 (PDT)
Received: from mail-vn0-x233.google.com (mail-vn0-x233.google.com. [2607:f8b0:400c:c0f::233])
        by mx.google.com with ESMTPS id ez9si31595184vdb.40.2015.04.27.13.52.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 13:52:11 -0700 (PDT)
Received: by vnbf1 with SMTP id f1so13670194vnb.5
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 13:52:10 -0700 (PDT)
Date: Mon, 27 Apr 2015 16:52:07 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150427205206.GD26980@gmail.com>
References: <20150424192859.GF3840@gmail.com>
 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
 <20150425114633.GI5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
 <20150427154728.GA26980@gmail.com>
 <alpine.DEB.2.11.1504271113480.29515@gentwo.org>
 <20150427164325.GB26980@gmail.com>
 <alpine.DEB.2.11.1504271148240.29735@gentwo.org>
 <20150427172143.GC26980@gmail.com>
 <alpine.DEB.2.11.1504271411060.30615@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504271411060.30615@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, Apr 27, 2015 at 02:26:04PM -0500, Christoph Lameter wrote:
> On Mon, 27 Apr 2015, Jerome Glisse wrote:
> 
> > > We can drop the DAX name and just talk about mapping to external memory if
> > > that confuses the issue.
> >
> > DAX is for direct access block layer (X is for the cool name factor)
> > there is zero code inside DAX that would be usefull to us. Because it
> > is all about filesystem and short circuiting the pagecache. So DAX is
> > _not_ about providing rw mappings to non regular memory, it is about
> > allowing to directly map _filesystem backing storage_ into a process.
> 
> Its about directly mapping memory outside of regular kernel
> management via a block device into user space. That you can put a
> filesystem on top is one possible use case. You can provide a block
> device to map the memory of the coprocessor and then configure the memory
> space to have the same layout on the coprocessor as well as the linux
> process.

_Block device_ not what we want, the API of block device does not match
anything remotely usefull for our usecase. Most of the block device api
deals with disk and scheduling io on them, none of which is interesting
to us. So we would need to carefully create various noop functions and
insert ourself as some kind of fake block device while also making sure
no userspace could actually use ourself as a regular block device. So
we would be pretending being something we are not.

> 
> > Moreover DAX is not about managing that persistent memory, all the
> > management is done inside the fs (ext4, xfs, ...) in the same way as
> > for non persistent memory. While in our case we want to manage the
> > memory as a runtime resources that is allocated to process the same
> > way regular system memory is managed.
> 
> I repeatedly said that. So you would have a block device that would be
> used to mmap portions of the special memory into a process.
> 
> > So current DAX code have nothing of value for our usecase nor what we
> > propose will have anyvalue for DAX. Unless they decide to go down the
> > struct page road for persistent memory (which from last discussion i
> > heard was not there plan, i am pretty sure they entirely dismissed
> > that idea for now).
> 
> DAX is about directly accessing memory. It is made for the purpose of
> serving as a block device for a filesystem right now but it can easily be
> used as a way to map any external memory into a processes space using the
> abstraction of a block device. But then you can do that with any device
> driver using VM_PFNMAP or VM_MIXEDMAP. Maybe we better use that term
> instead. Guess I have repeated myself 6 times or so now? I am stopping
> with this one.
> 
> > My point is that this is 2 differents non overlapping problems, and
> > thus mandate 2 differents solution.
> 
> Well confusion abounds since so much other stuff has ben attached to DAX
> devices.
> 
> Lets drop the DAX term and use VM_PFNMAP or VM_MIXEDMAP instead. MIXEDMAP
> is the mechanism that DAX relies on in the VM.

Which would require fare more changes than you seem to think. First using
MIXED|PFNMAP means we loose any kind of memory accounting and forget about
memcg too. Seconds it means we would need to set those flags on all vma,
which kind of point out that something must be wrong here. You will also
need to have vm_ops for all those vma (including for anonymous private vma
which sounds like it will break quite few place that test for that). Then
you have to think about vma that already have vm_ops but you would need
to override it to handle case where its device memory and then forward
other case to the existing vm_ops, extra layering, extra complexity.

All in all, this points me to believe that any such approach would be
vastly more complex, involve changing many places and try to force shoe
horning something into the block device model that is clearly not a
block device.

Paul solution or mine, are far smaller, i think Paul can even get away
from adding/changing ZONE by putting the device pages onto a different
list that is not use by kernel memory allocator. Only few code place
would need a new if() (when freeing a page and when initializing device
memory struct page, you could keep the lru code intact here).

I think at this point there is nothing more to discuss here. It is pretty
clear to me that any solution using block device/MIXEDMAP would be far
more complex and far more intrusive. I do not mind being prove wrong but
i will certainly not waste my time trying to implement such solution.

Btw as a data point, if you ignore my patches to mmu_notifier (which are
mostly about passing down more context information to the callback),
i touch less then 50 lines of mm common code. Every thing else is helpers
that are only use by the device driver.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
