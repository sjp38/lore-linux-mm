Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id D62856B006C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 12:15:11 -0400 (EDT)
Received: by vnbf129 with SMTP id f129so12500982vnb.9
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:15:11 -0700 (PDT)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id mq18si30655393vdb.57.2015.04.27.09.15.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 09:15:10 -0700 (PDT)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 27 Apr 2015 10:15:10 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 27BA23E4004C
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:15:08 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3RGF4Pj47972582
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 09:15:04 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3RGF6Kc021650
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 10:15:06 -0600
Date: Mon, 27 Apr 2015 09:15:04 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150427161504.GV5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Mon, Apr 27, 2015 at 10:08:29AM -0500, Christoph Lameter wrote:
> On Sat, 25 Apr 2015, Paul E. McKenney wrote:
> 
> > Would you have a URL or other pointer to this code?
> 
> linux/mm/migrate.c

Ah, I thought you were calling out something not yet in mainline.

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

I would instead look on this as a way to try out use of hardware migration
hints, which could lead to hardware vendors providing similar hints for
node-to-node migrations.  At that time, the benefits could be provided
all the functionality relying on such migrations.

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

Fair enough.

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

All else being equal, I agree that generality is preferred.  But here,
as is often the case, all else is not necessarily equal.

> > As I understand it, the trick (if you can call it that) is having the
> > device have the same memory-mapping capabilities as the CPUs.
> 
> Well yes that works with read-only mappings. Maybe we can special case
> that in the page migration code? We do not need migration entries if
> access is read-only actually.

So you are talking about the situation only during the migration itself,
then?  If there is no migration in progress, then of course there is
no problem with concurrent writes because the cache-coherence protocol
takes care of things.  During migration of a given page, I agree that
marking that page read-only on both sides makes sense.

And I agree that latency-sensitive applications might not tolerate
the page being read-only, and thus would want to avoid migration.
Such applications would of course instead rely on placing the memory.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
