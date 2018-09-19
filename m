Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED4DD8E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 18:26:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l65-v6so3043018pge.17
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 15:26:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id r14-v6si22808275pfa.44.2018.09.19.15.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Sep 2018 15:26:06 -0700 (PDT)
Date: Wed, 19 Sep 2018 16:26:22 -0600
From: Keith Busch <keith.busch@intel.com>
Subject: Re: [PATCH 0/7] mm: faster get user pages
Message-ID: <20180919222621.GA29003@localhost.localdomain>
References: <20180919210250.28858-1-keith.busch@intel.com>
 <40b392d0-0642-2d9b-5325-664a328ff677@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <40b392d0-0642-2d9b-5325-664a328ff677@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Sep 19, 2018 at 02:15:28PM -0700, Dave Hansen wrote:
> On 09/19/2018 02:02 PM, Keith Busch wrote:
> > Pinning user pages out of nvdimm dax memory is significantly slower
> > compared to system ram. Analysis points to software overhead incurred
> > from a radix tree lookup. This patch series fixes that by removing the
> > relatively costly dev_pagemap lookup that was repeated for each page,
> > significantly increasing gup time.
> 
> Could you also remind us why DAX pages are such special snowflakes and
> *require* radix tree lookups in the first place?

Yeah, ZONE_DEVICE memory is special. It has struct page mappings, but
not for online general use. The dev_pagemap is the metadata to the zone
device memory, and that metadata is stashed in a radix tree.

We're looking up the dev_pagemap in this path to take a reference so
the zone device can't be unmapped.
