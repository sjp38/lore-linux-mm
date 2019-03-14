Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82781C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 19:55:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17AD12186A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 19:55:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UNqkYigR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17AD12186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7858C6B0003; Thu, 14 Mar 2019 15:55:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70DA36B0005; Thu, 14 Mar 2019 15:55:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AE776B0006; Thu, 14 Mar 2019 15:55:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 125E36B0003
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 15:55:00 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e5so7381933pgc.16
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 12:55:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=vZNuEUuNICS2Gm4IYHhAJQIWK7u5E9v+XO+j854JpXQ=;
        b=TKovtaLp/vSHKuAev0+u1Bozp4W2YHXkRdBS8gocFTyNF6ZBcJkKCurFp2NzzNud4B
         sXER0JvCw/vpRotVcyEOWj2iyr1AIqRIoo+0BrtKSzIHRlmnGbhyW4fuAThzNiKJ4fgw
         XHYPW2nQwyFEWa5kPXmadhJEtjTlY14QAWeoJKMlApT3wogBROIYyoynHT26Zs4G4Nwt
         pE/jDsxk9FAltR6VKB0Rf42fxFJzY2APQjuqNt+TQRtwCo5FxRnGwY14woQ8fcYidU49
         VsjY3+ZwNuPRvieMQ1xPwRV/BoOjaIBySnofEByzVQMJ2hxuPpZLhSkxKqHq/6BxwQ4y
         sU+g==
X-Gm-Message-State: APjAAAWk+AND/kStlpNqHn5llbQO4MYiPbHRwgcHEAnqRAqr41A8hRWJ
	MijhoYOmX0LfSffppeCIn5BUo+QMuk5X8NpOHQsxPOfAgUk+heFaffLIa2F+40rwLbntGoIcQhL
	8dq+S2QOQPwmnqCSaKu59nL4iTpBPKDB/qMFSakl0VpdFMtQlA2PRT/xVOYFEOz4PEg==
X-Received: by 2002:a62:b618:: with SMTP id j24mr50516pff.120.1552593299725;
        Thu, 14 Mar 2019 12:54:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy46aXbmdtUtEWayca5IEx1Bl2GniIkTVWfFIoDjNgwsdyr4+e++J8hiW401eUhsJDDPmDL
X-Received: by 2002:a62:b618:: with SMTP id j24mr50439pff.120.1552593298377;
        Thu, 14 Mar 2019 12:54:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552593298; cv=none;
        d=google.com; s=arc-20160816;
        b=drKxZ6hvesnw3QTj/lIfgVz0vswGFLcGFE9IYjF9pja28lw78urV15i+O7i5T6/AHV
         13kumelg5zQp1tEU0u8hifpHPhO3nzsCvRztpeAJeTiWni1QjjthCGGpm8ymnvFUrtjG
         dwKTo6ZwlQe3122C2zNtqOp+AU/vFI+7AkuGoUFU//+4PQKaRaMxTGIOXRfGw8DbBnIT
         qDXeCxz8q4kKu6tn3yi+0KmoQHPwyrhyUhfXWDGk52Y3UsV12hPFABdrN3n2dblTKJRr
         P7LVp1ujtxdT5cVboCO7zGikRupUj9BlgH8kX3EsQOc1zMJ2yFpUkdqvqx0F/E3khhdj
         SyzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=vZNuEUuNICS2Gm4IYHhAJQIWK7u5E9v+XO+j854JpXQ=;
        b=ES79puCHCQ5w/QL9Ty2Te9dwrjUhyWzM6crIMrmVhsSU+r4y0I3XjndKWD7506GuuD
         CW8c9LAg8dcXfDXrUye+A/hdIZeS4nnIH3fHdLaYge99zCLvHNXRFtccl9Y8O2t2sE4R
         ttee0BlhfChHB/HAoR0qgHSivOZtsr3l/vmYCy3fJvwrD74K2wOz7M06N90ErRBNxoCx
         moZ4HViwJ2wWansfX9ClEB6cBsUaxaHlCaDb6ZM0rXYd6uLZnAXmfToFAgkRm1VXr9jL
         0Amqt7YEdFmLeOqRhxdxGsLgBSByAKH+6fAkbYkjxVU4CJFAPw6vEl6M1M1m3+h89jVz
         sPpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UNqkYigR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q14si14166850pls.204.2019.03.14.12.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 12:54:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=UNqkYigR;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:To:From:Date:Sender:Reply-To:Cc:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=vZNuEUuNICS2Gm4IYHhAJQIWK7u5E9v+XO+j854JpXQ=; b=UNqkYigR6BhjUG18MHwP8Tf6F
	kU2VG2qa/+SyesqtMr0xGQB9u41ygBqO1zPVYNUekOxhl7+cEZ4EPgqAb9qWM0mwCbW4vRMWaCetP
	Vy80rI9ig35YtSHbGSHQJ5wLoHJvHbmleSYfKl/3hxhbtgSfiyWIjW6t0DCCUpmMJqdOBMCZZD+tD
	tJCxidpOD6jf7AD2XcjSpwOVU/Cvlwf0huU6pooNakTf6Z5MwM+xgWv+zHfhuWWU1nSpiDOv5ieR4
	Ejjj5NbCQLJKZuN7Qzy6ziYntoQWEk/WFym0+SDPzrILELTVNW/DGBkS/6LFTM7yPtOs72coSyjnO
	Xt/JQKlLg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h4WRI-0003kC-9H; Thu, 14 Mar 2019 19:54:52 +0000
Date: Thu, 14 Mar 2019 12:54:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Laurent Dufour <ldufour@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Using XArray to manage the VMA
Message-ID: <20190314195452.GN19508@bombadil.infradead.org>
References: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
 <20190313210603.fguuxu3otj5epk3q@linux-r8p5>
 <20190314023910.GL19508@bombadil.infradead.org>
 <20190314164343.owsgnldxk7qr363q@linux-r8p5>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190314164343.owsgnldxk7qr363q@linux-r8p5>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000013, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 14, 2019 at 09:43:43AM -0700, Davidlohr Bueso wrote:
> On Wed, 13 Mar 2019, Matthew Wilcox wrote:
> 
> > It's probably worth listing the advantages of the Maple Tree over the
> > rbtree.
> 
> I'm not familiar with maple trees, are they referred to by another name?
> (is this some sort of B-tree?). Google just shows me real trees.

It is a B-tree variant which supports ranges as a first-class citizen
(single elements are ranges of length 1).  It optimises for ranges which
are adjacent to each other, and does not support overlapping ranges.
It supports RCU lookup and embeds a spinlock which must be held for
modification.  There's a lot of detail I can go into, but let's leave
it at that for an introduction.

> > - Shallower tree.  A 1000-entry rbtree is 10 levels deep.  A 1000-entry
> >   Maple Tree is 5 levels deep (I did a more detailed analysis in an
> >   earlier email thread with Laurent and I can present it if needed).
> 
> I'd be interested in reading on that.

(see the last two paragraphs of the mail for that analysis)

> > - O(1) prev/next
> > - Lookups under the RCU lock
> > 
> > There're some second-order effects too; by using externally allocated
> > nodes, we avoid disturbing other VMAs when inserting/deleting, and we
> > avoid bouncing cachelines around (eg the VMA which happens to end up
> > at the head of the tree is accessed by every lookup in the tree because
> > it's on the way to every other node).
> 
> How would maple trees deal with the augmented vma tree (vma gaps) trick
> we use to optimize get_unmapped_area?

The fundamental unit of the Maple Tree is a 128-byte node.  A leaf node
is laid out like this:

struct maple_range_64 {
        struct maple_node *parent;
        void __rcu *slot[8];
        u64 pivot[7];
};

The pivots are stored in ascending order; if the search index is less
than pivot[i], then the value (ie the vma pointer) you are searching
for is stored in slot[i].

Non-leaf nodes (for trees which support range allocations) are laid out
like this:

struct maple_arange_64 {
        struct maple_node *parent;
	u64 gaps[5];
        void __rcu *slot[5];
        u64 pivot[4];
};

gaps[i] stores the largest run of NULL pointers in the subtree rooted at
slot[i].  When searching for an empty range of at least N, you can skip
any subtree which has gaps[i] < N.

Here's a simple case:

$ ldd `which cat`
	linux-vdso.so.1 (0x00007ffc867fc000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f2c8cc6e000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f2c8ce69000)

'cat /proc/self/maps | wc' gives me 25 mappings.  They look like this:

$ cat /proc/self/maps |cut -f 1 -d ' '
55c414785000-55c414787000
55c414787000-55c41478c000
55c41478c000-55c41478e000
55c41478f000-55c414790000
55c414790000-55c414791000
55c4159dd000-55c4159fe000
7fa5f6527000-7fa5f680c000
7fa5f680c000-7fa5f682e000
7fa5f682e000-7fa5f6976000
7fa5f6976000-7fa5f69c2000
7fa5f69c2000-7fa5f69c3000
7fa5f69c3000-7fa5f69c7000
7fa5f69c7000-7fa5f69c9000
7fa5f69c9000-7fa5f69cd000
7fa5f69cd000-7fa5f69cf000
7fa5f69d9000-7fa5f69fb000
7fa5f69fb000-7fa5f69fc000
7fa5f69fc000-7fa5f6a1a000
7fa5f6a1a000-7fa5f6a22000
7fa5f6a22000-7fa5f6a23000
7fa5f6a23000-7fa5f6a24000
7fa5f6a24000-7fa5f6a25000
7ffe54a3c000-7ffe54a5d000
7ffe54a7b000-7ffe54a7e000
7ffe54a7e000-7ffe54a80000

We'd represent this in the Maple Tree as:

0-55c414785000 -> NULL
55c414785000-55c414787000 -> vma
55c414787000-55c41478c000 -> vma
...
55c414790000-55c414791000 -> vma
55c414791000-7fa5f6527000 -> NULL
7fa5f6527000-7fa5f680c000 -> vma
...
7fa5f69cd000-7fa5f69cf000 -> vma
7fa5f69cf000-7fa5f69d9000 -> NULL
7fa5f69d9000-7fa5f69fb000 -> vma
...
7fa5f6a24000-7fa5f6a25000 -> vma
7fa5f6a25000-7ffe54a3c000 -> NULL
7ffe54a3c000-7ffe54a5d000 -> vma
7ffe54a5d000-7ffe54a7b000 -> NULL
7ffe54a7b000-7ffe54a7e000 -> vma
7ffe54a7e000-7ffe54a80000 -> vma
7ffe54a80000-ffffffffffff -> NULL

so the maple tree stores 6 ranges that point to NULL in addition to the
25 that're stored by the rbtree.  Because they're allocated sequentially,
there won't be any wastage in the maple tree caused by items shifting
around.  That means we'll get 8 per leaf node, so just 4 leaf nodes
needed to store 31 ranges, all stored in a single root node.  That means
to get from root to an arbitrary VMA is just 3 pointer dereferences,
versus 3.96 pointer dereferences for an optimally balanced rbtree.


For a process with 1000 VMAs, we'll have approximately 167 leaf nodes
(assuming approximately 6 of the 8 pointers are used per node) arranged
into a tree of height 5, with about 44 non-leaf nodes needed to manage
those 166 leaf-nodes.  That'll be 6 pointers to follow per walk of the
tree (if it were optimally arranged, it'd be 125 leaf nodes plus 25 +
5 + 1 non-leaf nodes and 5 pointers to follow, but it's unrealistic to
assume it'll be optimally arranged, and this neglects the NULL ranges
which will also need to be stored).

The rbtree has a 1/1000 chance of 1 pointer dereference, a 2/1000 chance
of 2 pointers, 4/1000 chance of 3 pointers, 8/1000 4 pointers, 16/1000 5
pointers, 32/1000 6 pointers, 64/1000 7 pointers, 128/1000 8 pointers,
256/1000 9 pointers, 489/1000 10 pointers.  Amortised, that's 8.987
pointers to look up a random VMA (assuming the rbtree is fully balanced;
I haven't checked how unbalanced the rbtree can actually become).

