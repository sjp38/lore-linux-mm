Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 843E56B0005
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 14:07:50 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 31-v6so14431532plf.19
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 11:07:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id x14-v6si579071pgq.242.2018.06.12.11.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jun 2018 11:07:49 -0700 (PDT)
Date: Tue, 12 Jun 2018 12:07:47 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v4 10/12] filesystem-dax: Introduce dax_lock_page()
Message-ID: <20180612180747.GA28436@linux.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
 <152850187437.38390.2257981090761438811.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180611154146.jc5xt4gyaihq64lm@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180611154146.jc5xt4gyaihq64lm@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, hch@lst.de, linux-nvdimm@lists.01.org

On Mon, Jun 11, 2018 at 05:41:46PM +0200, Jan Kara wrote:
> On Fri 08-06-18 16:51:14, Dan Williams wrote:
> > In preparation for implementing support for memory poison (media error)
> > handling via dax mappings, implement a lock_page() equivalent. Poison
> > error handling requires rmap and needs guarantees that the page->mapping
> > association is maintained / valid (inode not freed) for the duration of
> > the lookup.
> > 
> > In the device-dax case it is sufficient to simply hold a dev_pagemap
> > reference. In the filesystem-dax case we need to use the entry lock.
> > 
> > Export the entry lock via dax_lock_page() that uses rcu_read_lock() to
> > protect against the inode being freed, and revalidates the page->mapping
> > association under xa_lock().
> > 
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> 
> Some comments below...
> 
> > diff --git a/fs/dax.c b/fs/dax.c
> > index cccf6cad1a7a..b7e71b108fcf 100644
> > --- a/fs/dax.c
> > +++ b/fs/dax.c
> > @@ -361,6 +361,82 @@ static void dax_disassociate_entry(void *entry, struct address_space *mapping,
> >  	}
> >  }
> >  
> > +struct page *dax_lock_page(unsigned long pfn)
> > +{
> 
> Why do you return struct page here? Any reason behind that? Because struct
> page exists and can be accessed through pfn_to_page() regardless of result
> of this function so it looks a bit confusing. Also dax_lock_page() name
> seems a bit confusing. Maybe dax_lock_pfn_mapping_entry()?

It's also a bit awkward that the functions are asymmetric in their arguments:
dax_lock_page(pfn) vs dax_unlock_page(struct page)

Looking at dax_lock_page(), we only use 'pfn' to get 'page', so maybe it would
be cleaner to just always deal with struct page, i.e.:

void dax_lock_page(struct page *page);
void dax_unlock_page(struct page *page);
