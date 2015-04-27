Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f51.google.com (mail-vn0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 37DAB6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 15:26:08 -0400 (EDT)
Received: by vnbf62 with SMTP id f62so13316434vnb.13
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:26:08 -0700 (PDT)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id g1si31214544vdj.104.2015.04.27.12.26.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 12:26:07 -0700 (PDT)
Date: Mon, 27 Apr 2015 14:26:04 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150427172143.GC26980@gmail.com>
Message-ID: <alpine.DEB.2.11.1504271411060.30615@gentwo.org>
References: <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org> <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org> <20150425114633.GI5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
 <20150427154728.GA26980@gmail.com> <alpine.DEB.2.11.1504271113480.29515@gentwo.org> <20150427164325.GB26980@gmail.com> <alpine.DEB.2.11.1504271148240.29735@gentwo.org> <20150427172143.GC26980@gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, 27 Apr 2015, Jerome Glisse wrote:

> > We can drop the DAX name and just talk about mapping to external memory if
> > that confuses the issue.
>
> DAX is for direct access block layer (X is for the cool name factor)
> there is zero code inside DAX that would be usefull to us. Because it
> is all about filesystem and short circuiting the pagecache. So DAX is
> _not_ about providing rw mappings to non regular memory, it is about
> allowing to directly map _filesystem backing storage_ into a process.

Its about directly mapping memory outside of regular kernel
management via a block device into user space. That you can put a
filesystem on top is one possible use case. You can provide a block
device to map the memory of the coprocessor and then configure the memory
space to have the same layout on the coprocessor as well as the linux
process.

> Moreover DAX is not about managing that persistent memory, all the
> management is done inside the fs (ext4, xfs, ...) in the same way as
> for non persistent memory. While in our case we want to manage the
> memory as a runtime resources that is allocated to process the same
> way regular system memory is managed.

I repeatedly said that. So you would have a block device that would be
used to mmap portions of the special memory into a process.

> So current DAX code have nothing of value for our usecase nor what we
> propose will have anyvalue for DAX. Unless they decide to go down the
> struct page road for persistent memory (which from last discussion i
> heard was not there plan, i am pretty sure they entirely dismissed
> that idea for now).

DAX is about directly accessing memory. It is made for the purpose of
serving as a block device for a filesystem right now but it can easily be
used as a way to map any external memory into a processes space using the
abstraction of a block device. But then you can do that with any device
driver using VM_PFNMAP or VM_MIXEDMAP. Maybe we better use that term
instead. Guess I have repeated myself 6 times or so now? I am stopping
with this one.

> My point is that this is 2 differents non overlapping problems, and
> thus mandate 2 differents solution.

Well confusion abounds since so much other stuff has ben attached to DAX
devices.

Lets drop the DAX term and use VM_PFNMAP or VM_MIXEDMAP instead. MIXEDMAP
is the mechanism that DAX relies on in the VM.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
