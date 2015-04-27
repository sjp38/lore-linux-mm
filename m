Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFA0A6B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 11:08:31 -0400 (EDT)
Received: by iejt8 with SMTP id t8so128321356iej.2
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 08:08:31 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 15si15929117iop.43.2015.04.27.08.08.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 27 Apr 2015 08:08:30 -0700 (PDT)
Date: Mon, 27 Apr 2015 10:08:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150425114633.GI5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504271004240.28895@gentwo.org>
References: <20150423161105.GB2399@gmail.com> <alpine.DEB.2.11.1504240912560.7582@gentwo.org> <20150424150829.GA3840@gmail.com> <alpine.DEB.2.11.1504241052240.9889@gentwo.org> <20150424164325.GD3840@gmail.com> <alpine.DEB.2.11.1504241148420.10475@gentwo.org>
 <20150424171957.GE3840@gmail.com> <alpine.DEB.2.11.1504241353280.11285@gentwo.org> <20150424192859.GF3840@gmail.com> <alpine.DEB.2.11.1504241446560.11700@gentwo.org> <20150425114633.GI5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Sat, 25 Apr 2015, Paul E. McKenney wrote:

> Would you have a URL or other pointer to this code?

linux/mm/migrate.c

> > > Without modifying a single line of mm code, the only way to do this is to
> > > either unmap from the cpu page table the range being migrated or to mprotect
> > > it in some way. In both case the cpu access will trigger some kind of fault.
> >
> > Yes that is how Linux migration works. If you can fix that then how about
> > improving page migration in Linux between NUMA nodes first?
>
> In principle, that also would be a good thing.  But why do that first?

Because it would benefit a lot of functionality that today relies on page
migration to have a faster more reliable way of moving pages around.

> > > This is not the behavior we want. What we want is same address space while
> > > being able to migrate system memory to device memory (who make that decision
> > > should not be part of that discussion) while still gracefully handling any
> > > CPU access.
> >
> > Well then there could be a situation where you have concurrent write
> > access. How do you reconcile that then? Somehow you need to stall one or
> > the other until the transaction is complete.
>
> Or have store buffers on one or both sides.

Well if those store buffers end up with divergent contents then you have
the problem of not being able to decide which version should survive. But
from Jerome's response I deduce that this is avoided by only allow
read-only access during migration. That is actually similar to what page
migration does.

> > > This means if CPU access it we want to migrate memory back to system memory.
> > > To achieve this there is no way around adding couple of if inside the mm
> > > page fault code path. Now do you want each driver to add its own if branch
> > > or do you want a common infrastructure to do just that ?
> >
> > If you can improve the page migration in general then we certainly would
> > love that. Having faultless migration is certain a good thing for a lot of
> > functionality that depends on page migration.
>
> We do have to start somewhere, though.  If we insist on perfection for
> all situations before we agree to make a change, we won't be making very
> many changes, now will we?

Improvements to the general code would be preferred instead of
having specialized solutions for a particular hardware alone.  If the
general code can then handle the special coprocessor situation then we
avoid a lot of code development.

> As I understand it, the trick (if you can call it that) is having the
> device have the same memory-mapping capabilities as the CPUs.

Well yes that works with read-only mappings. Maybe we can special case
that in the page migration code? We do not need migration entries if
access is read-only actually.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
