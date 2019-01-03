Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8597C43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91BF5217D9
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 14:39:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="QeyuFHan"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91BF5217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D8A98E0078; Thu,  3 Jan 2019 09:39:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287B98E0002; Thu,  3 Jan 2019 09:39:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12A608E0078; Thu,  3 Jan 2019 09:39:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C22A98E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 09:39:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id r13so28819175pgb.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 06:39:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=cpyYqlHvB58KkTNoC4Cjl0Icxb9x69XoxiEczy+KqYM=;
        b=kBvhaV1bg0wZ4xzn0c9BAVIsGmBxJmPTiDtbnE2f5BJuBg80NOq8Jm565dpV8AYY7o
         QMe4FpgVeDcGavWbF1mAOwi1hcTz+z+HZNPoySen4fMdNqK5HUbpKgntndNX6RSMimwc
         6CAw5zYXyHVq+MULLi9PNCWW7CmRKuhWdORLBPsbILDucNeOiFTCjEOnL1hXDR94444v
         1RMgPeXcVwKt+jD779d+32PU6kRmDgujc7gyeWgJNeqm+14g4VNCLA9KCFhD74zZ5YSX
         020n/SXHxrpbTcs3X/r0aywU97VS+HfErg9dSfibQ+yYW/DNQzNg0SP0lMWO5gT4Ue8T
         VL9A==
X-Gm-Message-State: AJcUukfYJuGVk7vL/V9xC7ezMVouCtbHUNvwEgV71V33FEbZLPHCpeYK
	s628COKcXYFmxzPiaNi1bzzf57OkbdDa1UUY3beDwUevIPNfgfsJEOc6kCOa6ya9gU/pRlbqlAf
	fv4cpwIzjzqPpynkwLJ6MMJEINw4ePIwa9WVNctv9xw7jtPISFs8ylOUZH522DW6VQQ==
X-Received: by 2002:a17:902:8a91:: with SMTP id p17mr47244386plo.316.1546526351448;
        Thu, 03 Jan 2019 06:39:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5FsRvIKodYl+5CZUndjoNZJTO/9j2uSH1Mx+mdLEUDeA8C80DcbKsAKCZ7y4lW9flYMPF6
X-Received: by 2002:a17:902:8a91:: with SMTP id p17mr47244333plo.316.1546526350444;
        Thu, 03 Jan 2019 06:39:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546526350; cv=none;
        d=google.com; s=arc-20160816;
        b=UBX4SxgqPHZ/aTNqrGYriER6lH8CdB6L4Qrj9M0ABLJg+kcz+Tx8rWTMxhK4JLJnhs
         F+9OcXfxSqyZk0H3BS/s7gsVDJ5Ob4cLAbdRgE/5PLEug2ozxDK9HHcl8bfeY1HcjLXN
         Ho39eynr9nzTR9YUWAU3aDZzy5vFFy+hQG7xIFIrcKXZuVaVBhS/V3+TIur0CrI5oX/n
         D/B1Vaj6TB/xFpLbhd9/b2hKq8njUMIroFXGvwJSOSEQoez+ubDHXFar0n3b+2M57yhN
         QSIsKNgUFFCABngPnUdK6l5Sty8P8XeV5KS73uAf/GVSk9EHJF5LLBW46oVIDg8WUFfP
         8k5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=cpyYqlHvB58KkTNoC4Cjl0Icxb9x69XoxiEczy+KqYM=;
        b=doTakp4E4plxcUGD2fk2+v77Umzt60E0YPBPxaI5d1ysGwtV5YMAzw2YWEqZN3Ls0S
         bEIl+HXRYnLf9FMkSwQZSjuDRr/uxE4HA44ij/HiymgeenD+0wucm9YTt9uPzx5AIFyd
         kDGtwMTHkjmCetasLfT0J2CyFNKHjwrpdnNPMjS7/VUoNgyGd9xlkO79AHDObeFI6Qyw
         EjMM/RAsUTxo4i+V7MaJn5jpZjhU08k02zWAw6jLHRohYw0iblucN1zZCEgqshe/jkTc
         gaY4HOkueZ1k8JThgYf23J/uYrBFQQXvDp9XhlLt4kqefvtfsHkru/COpyiXO3PLMFdc
         fg4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QeyuFHan;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t23si46574147pgi.181.2019.01.03.06.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 Jan 2019 06:39:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=QeyuFHan;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=cpyYqlHvB58KkTNoC4Cjl0Icxb9x69XoxiEczy+KqYM=; b=QeyuFHanBW2Kzy081ggKqX4ggH
	/m7IpUxJmN7r/ckut+rupPEL+CmUISmVKcKsPzF3rdjPXdAlhLPhaDIHkPTfy3K+I0xG7M2fZoNzQ
	nKbMiMdqRF7I1Bc2ixOTX49RjW5PBwWON5MRRPTgSsY9rxCvV7jjBIEgZY41tsSPCrcX4TU6j5aVy
	vjzj3wd0oac0bB/muKz4HmcuzXGqMtsOh/z/uctUETDNmJ/y7kDoCVbYs+Rr6R+WPfHRNi7H9Fwuy
	i13FAUsfiP6y8irSP5MruWSXGbn1nRz29KptoYAHfJhcMd9UnSldtYSQiBBlU+7tkSQnCZxSYfeCr
	ytgjmakA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gf49N-0001F0-0s; Thu, 03 Jan 2019 14:39:09 +0000
Date: Thu, 3 Jan 2019 06:39:08 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-xfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] Initialise mmu_notifier_range correctly
Message-ID: <20190103143908.GQ6310@bombadil.infradead.org>
References: <20190103002126.GM6310@bombadil.infradead.org>
 <20190103015654.GB15619@redhat.com>
 <785af237-eb67-c304-595d-9080a2f48102@nvidia.com>
 <20190103041833.GN6310@bombadil.infradead.org>
 <20190103142959.GA3395@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190103142959.GA3395@redhat.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103143908.7mrCVUg8zHZtKQkrW_6ZOx4v3nGPMVaJ7UKN88o_Nzw@z>

On Thu, Jan 03, 2019 at 09:29:59AM -0500, Jerome Glisse wrote:
> On Wed, Jan 02, 2019 at 08:18:33PM -0800, Matthew Wilcox wrote:
> > On Wed, Jan 02, 2019 at 07:32:08PM -0800, John Hubbard wrote:
> > > Having the range struct declared in separate places from the mmu_notifier_range_init()
> > > calls is not great. But I'm not sure I see a way to make it significantly cleaner, given
> > > that __follow_pte_pmd uses the range pointer as a way to decide to issue the mmn calls.
> > 
> > Yeah, I don't think there's anything we can do.  But I started reviewing
> > the comments, and they don't make sense together:
> > 
> >                 /*
> >                  * Note because we provide range to follow_pte_pmd it will
> >                  * call mmu_notifier_invalidate_range_start() on our behalf
> >                  * before taking any lock.
> >                  */
> >                 if (follow_pte_pmd(vma->vm_mm, address, &range,
> >                                    &ptep, &pmdp, &ptl))
> >                         continue;
> > 
> >                 /*
> >                  * No need to call mmu_notifier_invalidate_range() as we are
> >                  * downgrading page table protection not changing it to point
> >                  * to a new page.
> >                  *
> >                  * See Documentation/vm/mmu_notifier.rst
> >                  */
> > 
> > So if we don't call mmu_notifier_invalidate_range, why are we calling
> > mmu_notifier_invalidate_range_start and mmu_notifier_invalidate_range_end?
> > ie, why not this ...
> 
> Thus comments looks wrong to me ... we need to call
> mmu_notifier_invalidate_range() those are use by
> IOMMU. I might be to blame for those comments thought.

Yes, you're to blame for both of them.

a4d1a88525138 (Jérôme Glisse     2017-08-31 17:17:26 -0400  791)                 * Note because we provide start/end to follow_pte_pmd it will
a4d1a88525138 (Jérôme Glisse     2017-08-31 17:17:26 -0400  792)                 * call mmu_notifier_invalidate_range_start() on our behalf
a4d1a88525138 (Jérôme Glisse     2017-08-31 17:17:26 -0400  793)                 * before taking any lock.

0f10851ea475e (Jérôme Glisse     2017-11-15 17:34:07 -0800  794)                 * No need to call mmu_notifier_invalidate_range() as we are
0f10851ea475e (Jérôme Glisse     2017-11-15 17:34:07 -0800  795)                 * downgrading page table protection not changing it to point
0f10851ea475e (Jérôme Glisse     2017-11-15 17:34:07 -0800  796)                 * to a new page.

