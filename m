Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D08F6B02D1
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:36:47 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id j19so1593413pll.8
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 05:36:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n59-v6si58009plb.690.2018.02.22.05.36.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Feb 2018 05:36:46 -0800 (PST)
Date: Thu, 22 Feb 2018 14:36:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Use higher-order pages in vmalloc
Message-ID: <20180222133643.GJ30681@dhcp22.suse.cz>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz>
 <20180221154214.GA4167@bombadil.infradead.org>
 <fff58819-d39d-3a8a-f314-690bcb2f95d7@intel.com>
 <20180221170129.GB27687@bombadil.infradead.org>
 <20180222065943.GA30681@dhcp22.suse.cz>
 <20180222122254.GA22703@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180222122254.GA22703@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Thu 22-02-18 04:22:54, Matthew Wilcox wrote:
> On Thu, Feb 22, 2018 at 07:59:43AM +0100, Michal Hocko wrote:
> > On Wed 21-02-18 09:01:29, Matthew Wilcox wrote:
> > > Right.  It helps with fragmentation if we can keep higher-order
> > > allocations together.
> > 
> > Hmm, wouldn't it help if we made vmalloc pages migrateable instead? That
> > would help the compaction and get us to a lower fragmentation longterm
> > without playing tricks in the allocation path.
> 
> I was wondering about that possibility.  If we want to migrate a page
> then we have to shoot down the PTE across all CPUs, copy the data to the
> new page, and insert the new PTE.  Copying 4kB doesn't take long; if you
> have 12GB/s (current example on Wikipedia: dual-channel memory and one
> DDR2-800 module per channel gives a theoretical bandwidth of 12.8GB/s)
> then we should be able to copy a page in 666ns).  So there's no problem
> holding a spinlock for it.
> 
> But we can't handle a fault in vmalloc space today.  It's handled in
> arch-specific code, see vmalloc_fault() in arch/x86/mm/fault.c
> If we're going to do this, it'll have to be something arches opt into
> because I'm not taking on the job of fixing every architecture!

yes.

> > Maybe we should consider kvmalloc for the kernel stack?
> 
> We'd lose the guard page, so it'd have to be something we let the
> sysadmin decide to do.

ohh, right, I forgot about the guard page.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
