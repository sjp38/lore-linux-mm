Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f54.google.com (mail-bk0-f54.google.com [209.85.214.54])
	by kanga.kvack.org (Postfix) with ESMTP id 83B696B0098
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 07:43:35 -0400 (EDT)
Received: by mail-bk0-f54.google.com with SMTP id 6so404086bkj.13
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 04:43:34 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id nr7si6181606bkb.159.2014.03.17.04.43.33
        for <linux-mm@kvack.org>;
        Mon, 17 Mar 2014 04:43:33 -0700 (PDT)
Date: Mon, 17 Mar 2014 13:43:21 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] Support map_pages() for DAX
Message-ID: <20140317114321.GA30191@node.dhcp.inet.fi>
References: <1394838199-29102-1-git-send-email-toshi.kani@hp.com>
 <20140314233233.GA8310@node.dhcp.inet.fi>
 <20140316024613.GF6091@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140316024613.GF6091@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>, kirill.shutemov@linux.intel.com, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Mar 15, 2014 at 10:46:13PM -0400, Matthew Wilcox wrote:
> On Sat, Mar 15, 2014 at 01:32:33AM +0200, Kirill A. Shutemov wrote:
> > Side note: I'm sceptical about whole idea to use i_mmap_mutux to protect
> > against truncate. It will not scale good enough comparing lock_page()
> > with its granularity.
> 
> I'm actually working on this now.  The basic idea is to put an entry in
> the radix tree for each page.  For zero pages, that's a pagecache page.
> For pages that map to the media, it's an exceptional entry.  Radix tree
> exceptional entries take two bits, leaving us with 30 or 62 bits depending
> on sizeof(void *).  We can then take two more bits for Dirty and Lock,
> leaving 28 or 60 bits that we can use to cache the PFN on the page,
> meaning that we won't have to call the filesystem's get_block as often.

Sound reasonable to me. Implementation of ->map_pages should be trivial
with this.

Few questions:
 - why would you need Dirty for DAX?
 - are you sure that 28 bits is enough for PFN everywhere?
   ARM with LPAE can have up to 40 physical address lines. Is there any
   32-bit machine with more address lines?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
