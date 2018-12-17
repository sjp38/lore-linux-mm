Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9648E0033
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 14:59:28 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b17so12778546pfc.11
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 11:59:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k38si11472133pgi.235.2018.12.17.11.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 17 Dec 2018 11:59:27 -0800 (PST)
Date: Mon, 17 Dec 2018 11:59:22 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181217195922.GQ10600@bombadil.infradead.org>
References: <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181214154321.GF8896@quack2.suse.cz>
 <20181216215819.GC10644@dastard>
 <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181217194759.GB3341@redhat.com>
 <20181217195150.GP10600@bombadil.infradead.org>
 <20181217195408.GC3341@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181217195408.GC3341@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Mon, Dec 17, 2018 at 02:54:08PM -0500, Jerome Glisse wrote:
> On Mon, Dec 17, 2018 at 11:51:51AM -0800, Matthew Wilcox wrote:
> > On Mon, Dec 17, 2018 at 02:48:00PM -0500, Jerome Glisse wrote:
> > > On Mon, Dec 17, 2018 at 10:34:43AM -0800, Matthew Wilcox wrote:
> > > > No.  The solution John, Dan & I have been looking at is to take the
> > > > dirty page off the LRU while it is pinned by GUP.  It will never be
> > > > found for writeback.
> > > 
> > > With the solution you are proposing we loose GUP fast and we have to
> > > allocate a structure for each page that is under GUP, and the LRU
> > > changes too. Moreover by not writing back there is a greater chance
> > > of data loss.
> > 
> > Why can't you store the hmm_data in a side data structure?  Why does it
> > have to be in struct page?
> 
> hmm_data is not even the issue here, we can have a pincount without
> moving things around. So i do not see the need to complexify any of
> the existing code to add new structure and consume more memory for
> no good reasons. I do not see any benefit in that.

You said "we have to allocate a structure for each page that is under
GUP".  The only reason to do that is if we want to keep hmm_data in
struct page.  If we ditch hmm_data, there's no need to allocate a
structure, and we don't lose GUP fast either.
