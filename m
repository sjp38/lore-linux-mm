Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDEB8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:38:22 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so2291473edq.4
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 03:38:22 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si2841194edh.289.2019.01.16.03.38.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 03:38:21 -0800 (PST)
Date: Wed, 16 Jan 2019 12:38:19 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190116113819.GD26069@quack2.suse.cz>
References: <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
 <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com>
 <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz>
 <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115080759.GC29524@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue 15-01-19 09:07:59, Jan Kara wrote:
> Agreed. So with page lock it would actually look like:
> 
> get_page_pin()
> 	lock_page(page);
> 	wait_for_stable_page();
> 	atomic_add(&page->_refcount, PAGE_PIN_BIAS);
> 	unlock_page(page);
> 
> And if we perform page_pinned() check under page lock, then if
> page_pinned() returned false, we are sure page is not and will not be
> pinned until we drop the page lock (and also until page writeback is
> completed if needed).

After some more though, why do we even need wait_for_stable_page() and
lock_page() in get_page_pin()?

During writepage page_mkclean() will write protect all page tables. So
there can be no new writeable GUP pins until we unlock the page as all such
GUPs will have to first go through fault and ->page_mkwrite() handler. And
that will wait on page lock and do wait_for_stable_page() for us anyway.
Am I just confused?

That actually touches on another question I wanted to get opinions on. GUP
can be for read and GUP can be for write (that is one of GUP flags).
Filesystems with page cache generally have issues only with GUP for write
as it can currently corrupt data, unexpectedly dirty page etc.. DAX & memory
hotplug have issues with both (DAX cannot truncate page pinned in any way,
memory hotplug will just loop in kernel until the page gets unpinned). So
we probably want to track both types of GUP pins and page-cache based
filesystems will take the hit even if they don't have to for read-pins?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
