Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f41.google.com (mail-vn0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id AD35C6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 11:48:35 -0400 (EDT)
Received: by vnbg62 with SMTP id g62so12396667vnb.6
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 08:48:35 -0700 (PDT)
Received: from mail-vn0-x22d.google.com (mail-vn0-x22d.google.com. [2607:f8b0:400c:c0f::22d])
        by mx.google.com with ESMTPS id sd6si30602814vdc.17.2015.04.27.08.48.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 08:48:34 -0700 (PDT)
Received: by vnbf129 with SMTP id f129so12384255vnb.9
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 08:48:34 -0700 (PDT)
Date: Mon, 27 Apr 2015 11:47:29 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150427154728.GA26980@gmail.com>
References: <20150424150829.GA3840@gmail.com>
 <alpine.DEB.2.11.1504241052240.9889@gentwo.org>
 <20150424164325.GD3840@gmail.com>
 <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
 <20150424171957.GE3840@gmail.com>
 <alpine.DEB.2.11.1504241353280.11285@gentwo.org>
 <20150424192859.GF3840@gmail.com>
 <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
 <20150425114633.GI5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, Apr 27, 2015 at 10:08:29AM -0500, Christoph Lameter wrote:
> On Sat, 25 Apr 2015, Paul E. McKenney wrote:
> 
> > Would you have a URL or other pointer to this code?
> 
> linux/mm/migrate.c
> 
> > > > Without modifying a single line of mm code, the only way to do this is to
> > > > either unmap from the cpu page table the range being migrated or to mprotect
> > > > it in some way. In both case the cpu access will trigger some kind of fault.
> > >
> > > Yes that is how Linux migration works. If you can fix that then how about
> > > improving page migration in Linux between NUMA nodes first?
> >
> > In principle, that also would be a good thing.  But why do that first?
> 
> Because it would benefit a lot of functionality that today relies on page
> migration to have a faster more reliable way of moving pages around.

I do no think in the CAPI case there is anyway to improve on current low
leve page migration. I am talking about :
  - write protect & tlb flush
  - copy
  - update page table tlb flush

The upper level that have the logic for the migration would however need
some change. Like Paul said some kind of new metric and also new way to
gather statistics from device instead from CPU. I think the device can
provide better informations that the actual logic where page are unmap
and the kernel look which CPU fault on page first. Also a way to allow
hint provide by userspace through the device driver into the numa
decision process.

So i do not think that anything in this work would benefit any other work
load then the one Paul is interested in. Still i am sure Paul want to
build on top of existing infrastructure.


> 
> > > > This is not the behavior we want. What we want is same address space while
> > > > being able to migrate system memory to device memory (who make that decision
> > > > should not be part of that discussion) while still gracefully handling any
> > > > CPU access.
> > >
> > > Well then there could be a situation where you have concurrent write
> > > access. How do you reconcile that then? Somehow you need to stall one or
> > > the other until the transaction is complete.
> >
> > Or have store buffers on one or both sides.
> 
> Well if those store buffers end up with divergent contents then you have
> the problem of not being able to decide which version should survive. But
> from Jerome's response I deduce that this is avoided by only allow
> read-only access during migration. That is actually similar to what page
> migration does.

Yes, as said above no change to the logic there, we do not want divergent
content at all. The thing is, autonuma is a better fit for Paul because
Paul platform being more advance he can allocate struct page for the device
memory. While in my case it would be pointless as the memory is not CPU
accessible. This is why the HMM patchset do not build on top of autonuma
and current page migration but still use the same kind of logic.

> 
> > > > This means if CPU access it we want to migrate memory back to system memory.
> > > > To achieve this there is no way around adding couple of if inside the mm
> > > > page fault code path. Now do you want each driver to add its own if branch
> > > > or do you want a common infrastructure to do just that ?
> > >
> > > If you can improve the page migration in general then we certainly would
> > > love that. Having faultless migration is certain a good thing for a lot of
> > > functionality that depends on page migration.
> >
> > We do have to start somewhere, though.  If we insist on perfection for
> > all situations before we agree to make a change, we won't be making very
> > many changes, now will we?
> 
> Improvements to the general code would be preferred instead of
> having specialized solutions for a particular hardware alone.  If the
> general code can then handle the special coprocessor situation then we
> avoid a lot of code development.

I think Paul only big change would be the memory ZONE changes. Having a
way to add the device memory as struct page while blocking the kernel
allocation from using this memory. Beside that i think the autonuma changes
he would need would really be specific to his usecase but would still
reuse all of the low level logic.

> 
> > As I understand it, the trick (if you can call it that) is having the
> > device have the same memory-mapping capabilities as the CPUs.
> 
> Well yes that works with read-only mappings. Maybe we can special case
> that in the page migration code? We do not need migration entries if
> access is read-only actually.

The duplicate read only memory on device, is really an optimization that
is not critical to the whole. The common use case remain the migration of
read & write memory to device memory when the memory is mostly/only
accessed by the device.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
