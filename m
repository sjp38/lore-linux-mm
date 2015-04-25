Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id AE13C6B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 07:46:38 -0400 (EDT)
Received: by iejt8 with SMTP id t8so99987149iej.2
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 04:46:38 -0700 (PDT)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id iq3si1673897igb.15.2015.04.25.04.46.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Apr 2015 04:46:38 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sat, 25 Apr 2015 05:46:37 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 99C661FF001F
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 05:37:45 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3PBkVNf46333996
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 04:46:31 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3PBkYRt032761
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 05:46:34 -0600
Date: Sat, 25 Apr 2015 04:46:33 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150425114633.GI5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
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
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504241446560.11700@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

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

Would you have a URL or other pointer to this code?

> > Without modifying a single line of mm code, the only way to do this is to
> > either unmap from the cpu page table the range being migrated or to mprotect
> > it in some way. In both case the cpu access will trigger some kind of fault.
> 
> Yes that is how Linux migration works. If you can fix that then how about
> improving page migration in Linux between NUMA nodes first?

In principle, that also would be a good thing.  But why do that first?

> > This is not the behavior we want. What we want is same address space while
> > being able to migrate system memory to device memory (who make that decision
> > should not be part of that discussion) while still gracefully handling any
> > CPU access.
> 
> Well then there could be a situation where you have concurrent write
> access. How do you reconcile that then? Somehow you need to stall one or
> the other until the transaction is complete.

Or have store buffers on one or both sides.

> > This means if CPU access it we want to migrate memory back to system memory.
> > To achieve this there is no way around adding couple of if inside the mm
> > page fault code path. Now do you want each driver to add its own if branch
> > or do you want a common infrastructure to do just that ?
> 
> If you can improve the page migration in general then we certainly would
> love that. Having faultless migration is certain a good thing for a lot of
> functionality that depends on page migration.

We do have to start somewhere, though.  If we insist on perfection for
all situations before we agree to make a change, we won't be making very
many changes, now will we?

> > As i keep saying the solution you propose is what we have today, today we
> > have fake share address space through the trick of remapping system memory
> > at same address inside the GPU address space and also enforcing the use of
> > a special memory allocator that goes behind the back of mm code.
> 
> Hmmm... I'd like to know more details about that.

As I understand it, the trick (if you can call it that) is having the
device have the same memory-mapping capabilities as the CPUs.

> > As you pointed out, not using GPU memory is a waste and we want to be able
> > to use it. Now Paul have more sofisticated hardware that offer oportunities
> > to do thing in a more transparent and efficient way.
> 
> Does this also work between NUMA nodes in a Power8 system?

Heh!  At the rate we are going with this discussion, Power8 will be
obsolete before we have this in.  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
