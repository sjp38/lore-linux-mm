Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7182C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:18:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95B56206A2
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:18:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="LpkupU1B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95B56206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 347068E0003; Tue, 30 Jul 2019 15:18:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2F68C8E0001; Tue, 30 Jul 2019 15:18:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1983C8E0003; Tue, 30 Jul 2019 15:18:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D96D68E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:18:25 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a20so41459274pfn.19
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:18:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i3BKULC4QHiYOuwIIbBmXCyIL/bqfs1gfXb2IB4yaHE=;
        b=TxTBI3ONpOjpcWYg8NIeLunVK6oZjCe5gB13Jp2CHQh8SDXdz+t4yCvO3/SLCD5Mtu
         Gzsq0zKRithzrGQLfaFn8Xx6HbzxLxI8/gZlCJ2O9mIiSLBGDFyTVuwP4+jxoJnjkeB2
         Yfps2SbKvdiAvILdf8Cw2ffvphgLydUhpVKDqrPGujsTd5uoweW27M59qVEvHM+oDqOb
         DLyAJqB1deSRC1DOYHobK5fZRLiR0eog90wGq2QoKtS+pbkH4bIJorgBwp27B/17w65/
         iDdnbZ43nK5/aOGm92UKc1DVvrKWDlR5ghJfmLRSkn5dnd5zv0DKndXsADMu3bRSJat2
         rqVw==
X-Gm-Message-State: APjAAAVdFjPcd/1m0GmCv3KwWmNZ2pBdSd0DNRZc5we54McaZsTYU7bj
	FhY7Up/xqPXVF6zQ5g+k421IIjcidWjH3tTnh5QG27lj6hESqPlSK5RzQoFhfjfadE6kuzVY8q+
	9Jgpcptygzsd+77rc5CCrnt4c7cajRT4Vw7reHdhL4CK0Cpt8Im46d5J4SNepFxmKdg==
X-Received: by 2002:a62:1ac8:: with SMTP id a191mr43410819pfa.164.1564514305384;
        Tue, 30 Jul 2019 12:18:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdDznqui1iN5EAIghW1FB9XqaDH6wJ2L+wwBTYuzM0Od8oO0ZWWfxO+he4SGzrsgUYnHlm
X-Received: by 2002:a62:1ac8:: with SMTP id a191mr43410776pfa.164.1564514304616;
        Tue, 30 Jul 2019 12:18:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564514304; cv=none;
        d=google.com; s=arc-20160816;
        b=e1zN2BnnNYmphihtu91m0EdfqUl8cU7xu7XF4s44720opBDVCbcEyy5X/6rbLV+qFJ
         DWrCuZFzXRx+FseJTZQRIjpL2TrxLmQAb/txozuze+rqKJPb3oZRzL1i+G7EwRuN4XVd
         kAAjX+OWwkYp2O8pgbsX9rq9M6Hp2ocp8Z5AW8FZPQMqtOEzcGqXqypsPy4EtDOIKWXu
         t59jZ/q6nCZhRWSjNZph3Gw48Jy+yP6V8dIQi3DKxzZUVTTTCbnmPAV0rRqk41N33Iye
         8PeXe59yzJg1SGW9pF8hod+x6SjAFQ6ybzsBj+SMcrJZY/N9PaSHj6toZg1l7VpElgcT
         fewQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i3BKULC4QHiYOuwIIbBmXCyIL/bqfs1gfXb2IB4yaHE=;
        b=xclHpBYdt6NNaJ4olvuSrh5pwkIc6dRoyZrftUMdJhANfPVVjJBGfdFVwpsfjwUQPv
         fBEG7Acw0OzsTXYYqyx1UfsmYJvHJklJThKBqWZ/WEMETOi0FC8f2FX1Gbn83llDJF/A
         Qpx9qNsa7GFSIpZz1+/YTh/WmALcySWMHFM6M9r5W5Re1B8S7XBBdDpOh8iR9CQ+5rdj
         MmZkw7iAhuRr70GZYVTzgmg2SzLDjbeDS//Qmr0m6M2Fc8P6ptLT8qv1WU8FcIKvPQcv
         Po6JTUO4zSLYVofz2fKwXfKIGavXAzFxDLPtM0I5YHG1FdtWq0kuz2Fmi9bpp4NzIXG6
         564A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LpkupU1B;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s17si27197923pjq.35.2019.07.30.12.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 12:18:24 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=LpkupU1B;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i3BKULC4QHiYOuwIIbBmXCyIL/bqfs1gfXb2IB4yaHE=; b=LpkupU1B1/edtUeXOX4BE998R
	iiyPTaT1+7TjKMI0uZzexYF4it5SKfmrRVElmhYA+AXsKJVRhjWEtGfcJHtKbBtWBY+zzpA3vDW8y
	Ne5EPeU8gBsU/awBk0bHWa20L+VXcg5mYL8uYPDpJtw71dfZM1TzOF2dTIUppmzlTCLaW1Fler+tz
	lHA4PHL0C5JADi+3DHRIAzZSveT/iNYCISmkB/7dzV5LsH06kndzZnvbtVY9ZxIJzXKDediZvZUnB
	mZrIAr1XJFQ2oyKNBeSl35kzKsknTWypTfSeYTEH+V6EtYe43fMtfwiItQpNQZDlP0wEBeb/72ygO
	x8lX8ZKNw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hsXdZ-0000za-I2; Tue, 30 Jul 2019 19:18:17 +0000
Date: Tue, 30 Jul 2019 12:18:17 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: William Kucharski <william.kucharski@oracle.com>,
	ceph-devel@vger.kernel.org, linux-afs@lists.infradead.org,
	linux-btrfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, Netdev <netdev@vger.kernel.org>,
	Chris Mason <clm@fb.com>, "David S. Miller" <davem@davemloft.net>,
	David Sterba <dsterba@suse.com>, Josef Bacik <josef@toxicpanda.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Song Liu <songliubraving@fb.com>,
	Bob Kasten <robert.a.kasten@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Chad Mynhier <chad.mynhier@oracle.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Johannes Weiner <jweiner@fb.com>, Dave Airlie <airlied@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Keith Busch <keith.busch@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Steve Capper <steve.capper@arm.com>,
	Dave Chinner <dchinner@redhat.com>,
	Sean Christopherson <sean.j.christopherson@intel.com>,
	Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Amir Goldstein <amir73il@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Michal Hocko <mhocko@suse.com>, Jann Horn <jannh@google.com>,
	David Howells <dhowells@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>,
	Jan Kara <jack@suse.cz>, Andrey Konovalov <andreyknvl@google.com>,
	Arun KS <arunks@codeaurora.org>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Jeff Layton <jlayton@kernel.org>,
	Yangtao Li <tiny.windzz@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	David Rientjes <rientjes@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Yafang Shao <laoar.shao@gmail.com>,
	Huang Shijie <sjhuang@iluvatar.ai>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
	Ira Weiny <ira.weiny@intel.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Gao Xiang <hsiangkao@aol.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Ross Zwisler <zwisler@google.com>
Subject: Re: [PATCH v2 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
Message-ID: <20190730191817.GB4700@bombadil.infradead.org>
References: <20190729210933.18674-1-william.kucharski@oracle.com>
 <20190729210933.18674-3-william.kucharski@oracle.com>
 <CAPcyv4ixiBOXz97iZV2ARp8Uqwk2BbEW+5Q6e3vfAjv8LToPfw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ixiBOXz97iZV2ARp8Uqwk2BbEW+5Q6e3vfAjv8LToPfw@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 03:47:18PM -0700, Dan Williams wrote:
> On Mon, Jul 29, 2019 at 2:10 PM William Kucharski
> <william.kucharski@oracle.com> wrote:
> >
> > Add filemap_huge_fault() to attempt to satisfy page faults on
> > memory-mapped read-only text pages using THP when possible.
> >
> > Signed-off-by: William Kucharski <william.kucharski@oracle.com>
> [..]
> > +/**
> > + * filemap_huge_fault - read in file data for page fault handling to THP
> > + * @vmf:       struct vm_fault containing details of the fault
> > + * @pe_size:   large page size to map, currently this must be PE_SIZE_PMD
> > + *
> > + * filemap_huge_fault() is invoked via the vma operations vector for a
> > + * mapped memory region to read in file data to a transparent huge page during
> > + * a page fault.
> > + *
> > + * If for any reason we can't allocate a THP, map it or add it to the page
> > + * cache, VM_FAULT_FALLBACK will be returned which will cause the fault
> > + * handler to try mapping the page using a PAGESIZE page, usually via
> > + * filemap_fault() if so speicifed in the vma operations vector.
> > + *
> > + * Returns either VM_FAULT_FALLBACK or the result of calling allcc_set_pte()
> > + * to map the new THP.
> > + *
> > + * NOTE: This routine depends upon the file system's readpage routine as
> > + *       specified in the address space operations vector to recognize when it
> > + *      is being passed a large page and to read the approprate amount of data
> > + *      in full and without polluting the page cache for the large page itself
> > + *      with PAGESIZE pages to perform a buffered read or to pollute what
> > + *      would be the page cache space for any succeeding pages with PAGESIZE
> > + *      pages due to readahead.
> > + *
> > + *      It is VITAL that this routine not be enabled without such filesystem
> > + *      support.
> 
> Rather than a hopeful comment, this wants an explicit mechanism to
> prevent inadvertent mismatched ->readpage() assumptions.

Filesystems have to opt in to this.  If they add a ->huge_fault entry to
their vm_operations_struct without updating their ->readpage implementation,
they only have themselves to blame.

