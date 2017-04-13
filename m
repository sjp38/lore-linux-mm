Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B30996B03B7
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 08:46:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q25so30626942pfg.6
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:46:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id k18si12087808pgn.22.2017.04.13.05.46.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 05:46:34 -0700 (PDT)
Date: Thu, 13 Apr 2017 05:46:33 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm,hugetlb: compute page_size_log properly
Message-ID: <20170413124633.GG784@bombadil.infradead.org>
References: <1488992761-9464-1-git-send-email-dave@stgolabs.net>
 <20170328165343.GB27446@linux-80c1.suse>
 <20170328165513.GC27446@linux-80c1.suse>
 <20170328175408.GD7838@bombadil.infradead.org>
 <87wpaoq1zy.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87wpaoq1zy.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, ak@linux.intel.com, mtk.manpages@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com

On Thu, Apr 13, 2017 at 11:32:09AM +0530, Aneesh Kumar K.V wrote:
> > +#define SHM_HUGE_SHIFT	26
> > +#define SHM_HUGE_MASK	0x3f
> > +#define SHM_HUGE_2MB	(21 << SHM_HUGE_SHIFT)
> > +#define SHM_HUGE_8MB	(23 << SHM_HUGE_SHIFT)
> > +#define SHM_HUGE_1GB	(30 << SHM_HUGE_SHIFT)
> > +#define SHM_HUGE_16GB	(34 << SHM_HUGE_SHIFT)
> 
> This should be in arch/uapi like MAP_HUGE_2M ? That will let arch add
> #defines based on the hugepae size supported by them.

Well, what do we want to happen if source code contains SHM_HUGE_2MB?
Do we want it to fail to compile on ppc, or do we want it to request 2MB
pages and get ... hmm, looks like it fails at runtime (size_to_hstate
ends up returning NULL).  So, yeah, looks like a compile-time failure
would be better.

But speaking of MAP_HUGE_, the only definitions so far are in arch/x86.
Are you going to add the ppc versions?

Also, which header file?  I'm reluctant to add a new header, but
asm/shmbuf.h doesn't seem like a great place to put it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
