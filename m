Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8A686B027D
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 12:16:47 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id 50so17535913uae.7
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 09:16:47 -0700 (PDT)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id 65si6579088uab.205.2016.10.28.09.16.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Oct 2016 09:16:47 -0700 (PDT)
Received: by mail-qt0-x243.google.com with SMTP id p53so1038226qtp.1
        for <linux-mm@kvack.org>; Fri, 28 Oct 2016 09:16:47 -0700 (PDT)
Date: Fri, 28 Oct 2016 12:16:44 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
Message-ID: <20161028161644.GB11920@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <20161024170902.GA5521@gmail.com>
 <87a8dtawas.fsf@linux.vnet.ibm.com>
 <20161025151637.GA6072@gmail.com>
 <87y41bcqow.fsf@linux.vnet.ibm.com>
 <20161026160721.GA13638@gmail.com>
 <878tt96nxr.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <878tt96nxr.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On Fri, Oct 28, 2016 at 10:59:52AM +0530, Aneesh Kumar K.V wrote:
> Jerome Glisse <j.glisse@gmail.com> writes:
> 
> > On Wed, Oct 26, 2016 at 04:39:19PM +0530, Aneesh Kumar K.V wrote:
> >> Jerome Glisse <j.glisse@gmail.com> writes:
> >> 
> >> > On Tue, Oct 25, 2016 at 09:56:35AM +0530, Aneesh Kumar K.V wrote:
> >> >> Jerome Glisse <j.glisse@gmail.com> writes:
> >> >> 
> >> >> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
> >> >> >
> >> >> I looked at the hmm-v13 w.r.t migration and I guess some form of device
> >> >> callback/acceleration during migration is something we should definitely
> >> >> have. I still haven't figured out how non addressable and coherent device
> >> >> memory can fit together there. I was waiting for the page cache
> >> >> migration support to be pushed to the repository before I start looking
> >> >> at this closely.
> >> >> 
> >> >
> >> > The page cache migration does not touch the migrate code path. My issue with
> >> > page cache is writeback. The only difference with existing migrate code is
> >> > refcount check for ZONE_DEVICE page. Everything else is the same.
> >> 
> >> What about the radix tree ? does file system migrate_page callback handle
> >> replacing normal page with ZONE_DEVICE page/exceptional entries ?
> >> 
> >
> > It use the exact same existing code (from mm/migrate.c) so yes the radix tree
> > is updated and buffer_head are migrated.
> >
> 
> I looked at the the page cache migration patches shared and I find that
> you are not using exceptional entries when we migrate a page cache page to
> device memory. But I am now not sure how a read from page cache will
> work with that.
> 
> ie, a file system read will now find the page in page cache. But we
> cannot do a copy_to_user of that page because that is now backed by an
> unaddressable memory right ?
> 
> do_generic_file_read() does
>       page = find_get_page(mapping, index);
>       ....
>       ret = copy_page_to_iter(page, offset, nr, iter);
> 
> which does
> 	void *kaddr = kmap_atomic(page);
> 	size_t wanted = copy_to_iter(kaddr + offset, bytes, i);
> 	kunmap_atomic(kaddr);

Like i said right now for un-addressable memory my patches are mostly broken.
For read and write. I am focusing on page write back for now as it seemed to
be the more problematic case. For read/write the intention is to trigger a
migration back to system memory inside read/write of filesystem. This is also
why i will need a flag to indicate if a filesystem support migration to
un-addressable memory.

But in your case where the device memory is accessible then it should just work,
or do you need to do special thing when kmaping  device page ?

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
