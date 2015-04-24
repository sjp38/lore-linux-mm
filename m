Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 08D536B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 16:32:33 -0400 (EDT)
Received: by qgej70 with SMTP id j70so28269995qge.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 13:32:32 -0700 (PDT)
Received: from mail-qc0-x22b.google.com (mail-qc0-x22b.google.com. [2607:f8b0:400d:c01::22b])
        by mx.google.com with ESMTPS id l135si12431188qhl.16.2015.04.24.13.32.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 13:32:31 -0700 (PDT)
Received: by qcpm10 with SMTP id m10so32095422qcp.3
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 13:32:31 -0700 (PDT)
Date: Fri, 24 Apr 2015 16:32:28 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424203227.GG3840@gmail.com>
References: <20150423161105.GB2399@gmail.com>
 <alpine.DEB.2.11.1504240912560.7582@gentwo.org>
 <20150424150829.GA3840@gmail.com>
 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
 <20150424164325.GD3840@gmail.com>
 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
 <20150424171957.GE3840@gmail.com>
 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
 <20150424192859.GF3840@gmail.com>
 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 03:00:18PM -0500, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Jerome Glisse wrote:
> 
> > > Still no answer as to why is that not possible with the current scheme?
> > > You keep on talking about pointers and I keep on responding that this is a
> > > matter of making the address space compatible on both sides.
> >
> > So if do that in a naive way, how can we migrate a chunk of memory to video
> > memory while still handling properly the case where CPU try to access that
> > same memory while it is migrated to the GPU memory.
> 
> Well that the same issue that the migration code is handling which I
> submitted a long time ago to the kernel.

Yes so you had to modify the kernel for that ! So do we, and no, page migration
as it exist is not sufficience and does not cover all use case we have.

> 
> > Without modifying a single line of mm code, the only way to do this is to
> > either unmap from the cpu page table the range being migrated or to mprotect
> > it in some way. In both case the cpu access will trigger some kind of fault.
> 
> Yes that is how Linux migration works. If you can fix that then how about
> improving page migration in Linux between NUMA nodes first?

In my case i can not use the page migration because there is no where to hook
to explain how to migrate thing back and forth with a device. The page migration
code is all on CPU and enjoy the benefit of being able to do thing atomicaly,
i do not have such luxury.

More over the core mm code assume that cpu pte migration entry is a short lived
state. In case of migration to device memory we are talking about time span of
several minutes. So obviously the page migration is not what we want, we want
something similar but with different properties. That exactly what my HMM patchset
does provide.

What Paul wants to do however should be able to leverage the page migration that
does exist. But again he has a far more advance platform.

> 
> > This is not the behavior we want. What we want is same address space while
> > being able to migrate system memory to device memory (who make that decision
> > should not be part of that discussion) while still gracefully handling any
> > CPU access.
> 
> Well then there could be a situation where you have concurrent write
> access. How do you reconcile that then? Somehow you need to stall one or
> the other until the transaction is complete.

No, it is exactly like thread on a CPU, if you have 2 threads that write to
same address without having anykind of synchronization btw them, you can not
predict what will be the end result. Same will happen here, either the GPU
write goes last or the CPU one. Anyway this is not the use case we have in
mind. We are thinking about concurrent access to same page but in a non
conflicting way. Any conflicting access is a software bug like it is in the
case of CPU threads.

> 
> > This means if CPU access it we want to migrate memory back to system memory.
> > To achieve this there is no way around adding couple of if inside the mm
> > page fault code path. Now do you want each driver to add its own if branch
> > or do you want a common infrastructure to do just that ?
> 
> If you can improve the page migration in general then we certainly would
> love that. Having faultless migration is certain a good thing for a lot of
> functionality that depends on page migration.

Faultless migration i am talking about is only on GPU side, but this is just
an extra feature where you keep something mapped read only while migrating
it to device memory and updating the GPU page table once done. So GPU will
keep accessing system memory without interruption, this assume read only
access. Otherwise you need a faulty migration thought you can cooperate with
the thread scheduler to schedule other thread while migration is on going.

> 
> > As i keep saying the solution you propose is what we have today, today we
> > have fake share address space through the trick of remapping system memory
> > at same address inside the GPU address space and also enforcing the use of
> > a special memory allocator that goes behind the back of mm code.
> 
> Hmmm... I'd like to know more details about that.

Well there is no open source OpenCL 2.0 stack for discret GPU. But the idea is
that you need special allocator because the GPU driver need to know about all
the possible pages that might be use ie there is no page fault so all object
need to be mapped and thus all page are pinned down. Well this is a little more
complex as the special allocator keep track of each allocation creating an
object for each of them and trying to only pin object that are use by current
shader.

Anyway bottom line is that it needs a special allocator, you can not use mmaped
file directly or shared memory directly or anonymous memory allocated outside
the special allocator. It require pinning memory. It can not migrate memory to
device memory. We want to fix all that.

> 
> > As you pointed out, not using GPU memory is a waste and we want to be able
> > to use it. Now Paul have more sofisticated hardware that offer oportunities
> > to do thing in a more transparent and efficient way.
> 
> Does this also work between NUMA nodes in a Power8 system?

My guess is that it just improve the device exchange with CPU, like trying to
make the device memory access cost as much as would remote CPU memory access.
I do not think it improve the regular NUMA nodes.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
