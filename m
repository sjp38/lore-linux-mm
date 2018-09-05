Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBB596B74DB
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 15:58:48 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d132-v6so4156533pgc.22
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:58:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p66-v6si2948635pfp.237.2018.09.05.12.58.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 12:58:47 -0700 (PDT)
Date: Wed, 5 Sep 2018 12:58:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
Message-Id: <20180905125846.eb0a9ed907b293c1b4c23c23@linux-foundation.org>
In-Reply-To: <20180905134848.GB3729@bombadil.infradead.org>
References: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
	<20180905130440.GA3729@bombadil.infradead.org>
	<d76771e6-1664-5d38-a5a0-e98f1120494c@linux.ibm.com>
	<20180905134848.GB3729@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 5 Sep 2018 06:48:48 -0700 Matthew Wilcox <willy@infradead.org> wrote:

> > I didn't. The reason I looked at current patch is to enable the usage of
> > put_page() from irq context. We do allow that for non hugetlb pages. So was
> > not sure adding that additional restriction for hugetlb
> > is really needed. Further the conversion to irqsave/irqrestore was
> > straightforward.
> 
> straightforward, sure.  but is it the right thing to do?  do we want to
> be able to put_page() a hugetlb page from hardirq context?

Calling put_page() against a huge page from hardirq seems like the
right thing to do - even if it's rare now, it will presumably become
more common as the hugepage virus spreads further across the kernel. 
And the present asymmetry is quite a wart.

That being said, arch/powerpc/mm/mmu_context_iommu.c:mm_iommu_free() is
the only known site which does this (yes?) so perhaps we could put some
stopgap workaround into that site and add a runtime warning into the
put_page() code somewhere to detect puttage of huge pages from hardirq
and softirq contexts.

And attention will need to be paid to -stable backporting.  How long
has mm_iommu_free() existed, and been doing this?
