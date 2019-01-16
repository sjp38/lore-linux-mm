Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E26D28E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:08:21 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n50so5597441qtb.9
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:08:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i14si2136074qvj.112.2019.01.16.05.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:08:20 -0800 (PST)
Date: Wed, 16 Jan 2019 08:08:14 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190116130813.GA3617@redhat.com>
References: <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz>
 <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190116113819.GD26069@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190116113819.GD26069@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Jan 16, 2019 at 12:38:19PM +0100, Jan Kara wrote:
> On Tue 15-01-19 09:07:59, Jan Kara wrote:
> > Agreed. So with page lock it would actually look like:
> > 
> > get_page_pin()
> > 	lock_page(page);
> > 	wait_for_stable_page();
> > 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
> > 	unlock_page(page);
> > 
> > And if we perform page_pinned() check under page lock, then if
> > page_pinned() returned false, we are sure page is not and will not be
> > pinned until we drop the page lock (and also until page writeback is
> > completed if needed).
> 
> After some more though, why do we even need wait_for_stable_page() and
> lock_page() in get_page_pin()?
> 
> During writepage page_mkclean() will write protect all page tables. So
> there can be no new writeable GUP pins until we unlock the page as all such
> GUPs will have to first go through fault and ->page_mkwrite() handler. And
> that will wait on page lock and do wait_for_stable_page() for us anyway.
> Am I just confused?

Yeah with page lock it should synchronize on the pte but you still
need to check for writeback iirc the page is unlocked after file
system has queue up the write and thus the page can be unlock with
write back pending (and PageWriteback() == trye) and i am not sure
that in that states we can safely let anyone write to that page. I
am assuming that in some case the block device also expect stable
page content (RAID stuff).

So the PageWriteback() test is not only for racing page_mkclean()/
test_set_page_writeback() and GUP but also for pending write back.


> That actually touches on another question I wanted to get opinions on. GUP
> can be for read and GUP can be for write (that is one of GUP flags).
> Filesystems with page cache generally have issues only with GUP for write
> as it can currently corrupt data, unexpectedly dirty page etc.. DAX & memory
> hotplug have issues with both (DAX cannot truncate page pinned in any way,
> memory hotplug will just loop in kernel until the page gets unpinned). So
> we probably want to track both types of GUP pins and page-cache based
> filesystems will take the hit even if they don't have to for read-pins?

Yes the distinction between read and write would be nice. With the map
count solution you can only increment the mapcount for GUP(write=true).
With pin bias the issue is that a big number of read pin can trigger
false positive ie you would do:
    GUP(vaddr, write)
        ...
        if (write)
            atomic_add(page->refcount, PAGE_PIN_BIAS)
        else
            atomic_inc(page->refcount)

    PUP(page, write)
        if (write)
            atomic_add(page->refcount, -PAGE_PIN_BIAS)
        else
            atomic_dec(page->refcount)

I am guessing false positive because of too many read GUP is ok as
it should be unlikely and when it happens then we take the hit.

Cheers,
Jérôme
