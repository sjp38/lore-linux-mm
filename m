Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id EBB696B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 05:02:53 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id n5so71002170wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 02:02:53 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id mp1si27407739wjc.177.2016.01.25.02.02.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 02:02:52 -0800 (PST)
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 25 Jan 2016 10:02:52 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 7574D219005E
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:02:37 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u0PA2ncL61538542
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 10:02:49 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u0PA2nRP015675
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 03:02:49 -0700
Date: Mon, 25 Jan 2016 11:02:48 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] mm/debug_pagealloc: Ask users for default setting of
 debug_pagealloc
Message-ID: <20160125100248.GB4298@osiris>
References: <1453713588-119602-1-git-send-email-borntraeger@de.ibm.com>
 <20160125094132.GA4298@osiris>
 <56A5EECE.90607@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A5EECE.90607@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Jan 25, 2016 at 10:45:50AM +0100, Christian Borntraeger wrote:
> >> +	  By default this option will be almost for free and can be activated
> >> +	  in distribution kernels. The overhead and the debugging can be enabled
> >> +	  by DEBUG_PAGEALLOC_ENABLE_DEFAULT or the debug_pagealloc command line
> >> +	  parameter.
> > 
> > Sorry, but it's not almost for free and should not be used by distribution
> > kernels. If we have DEBUG_PAGEALLOC enabled, at least on s390 we will not
> > make use of 2GB and 1MB pagetable entries for the identy mapping anymore.
> > Instead we will only use 4K mappings.
> 
> Hmmm, can we change these code areas to use debug_pagealloc_enabled? I guess
> this evaluated too late?

Yes, that should be possible. "debug_pagealloc" is an early_param, which
will be evaluated before we call paging_init() (both in
arch/s390/kernel/setup.c).

So it looks like this can be trivially changed. (replace the ifdefs in
arch/s390/mm/vmem.c with debug_pagealloc_enabled()).

> > I assume this is true for all architectures since freeing pages can happen
> > in any context and therefore we can't allocate memory in order to split
> > page tables.
> > 
> > So enabling this will cost memory and put more pressure on the TLB.
> 
> So I will change the description and drop the "if unsure" statement.

Well, given that we can change it like above... I don't care anymore ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
