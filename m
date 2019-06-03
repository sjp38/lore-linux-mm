Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FCA5C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 12:11:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E48A925613
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 12:11:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="JOdKZZJu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E48A925613
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A9C86B0008; Mon,  3 Jun 2019 08:11:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45A146B000D; Mon,  3 Jun 2019 08:11:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36FE76B000E; Mon,  3 Jun 2019 08:11:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 025306B0008
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 08:11:44 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id o12so11643590pll.17
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 05:11:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SGbTcqGFDN+LyXFpLeZdtp0cOKIRUWh//D+jhegqSZU=;
        b=PIiNYxWoYIbiQ7z8hFsDBDXBEraKAnUre0MBrv02LbKhVVVyQUgvR58T7B6c98hiou
         lmvVx41DChlRwUeNSzE2K1zKpXDm2NdopOTcAlERfvaO++mvMg6fYzNy2RLhKhpr17MI
         4GKb7df5h+Kjdm2UZ7XgXzyA4XaaA3K5zMqb72kcnLGRhh5a5eBMaaWm79BfmnhTaGbN
         zxVwn6YEa9cNGMfDkCn1OhhZzu00/AwpLoBzhclpB2IyohXkK2U9bOibN4KHSxVz2oeH
         Ebp5t8K13dcu3cHeHz2+0G17c38uwWEHmTK/KiDYZnnbP0sFgtXeUSS77p+8H86s3wfv
         fLGg==
X-Gm-Message-State: APjAAAVr9LO7qpvgdcMYSMta14AURh9MjP6lUNyJvv5Rm+dEjHeWuwwe
	jlSIXLs65tDbitGefhWX6lAF+SVxpshoDBw0mFd5Z+0K++6BUlLJBxGGxmq3bmTs6RuqQw9wAOW
	lLUCpNIEKiL3zyFLuCmXzwCODXJkuPU9DgwZA02NI4EFuMhEd9jww3do879UKuSY9Og==
X-Received: by 2002:a65:48c3:: with SMTP id o3mr28151302pgs.351.1559563903411;
        Mon, 03 Jun 2019 05:11:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWJZIFWOyewMAlaxf3Bgrxu6A0Xkh0x5XC/jeoItyrlrm8cGC0np9uf8cLTQi4xqYMxoy7
X-Received: by 2002:a65:48c3:: with SMTP id o3mr28151179pgs.351.1559563902320;
        Mon, 03 Jun 2019 05:11:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559563902; cv=none;
        d=google.com; s=arc-20160816;
        b=uFwdbgJivmxSFaJMDHPoW6kn4Sk9e9US8v9LkmMA8810FNKIEbFXNaQ7g1h4glFuKR
         JsBV8X3ljZBgauKEdMgAizrPbp4wGeEAqRCeSwC8ocy75FVdoXrvWYgbaD5LIDDQ6qYE
         pC5UYSQ9Fvf/4UCtT1vWLHliNgh5niXvdqvDvWOZ7lIOzGDfi6hopKvvfULA7jmwkrmu
         8l7PrMdpeBpuOJDF68gZLAI54ncz4g0d1ZgIOUX/lZ+E1cL5A/uA+mC0mlgQuXvYCyin
         zLbAf9ZpYLbMPjeKXz0Wa6WBAPIStsvSXoh5RhR0/JDAg7LHaT/PQbJiX5KaWgXDvV/P
         56iA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SGbTcqGFDN+LyXFpLeZdtp0cOKIRUWh//D+jhegqSZU=;
        b=Nu8+9UIjpGe5NTqqJGb9ECIW/kgrTRV0aFMZjkuzjp7s/FGaxxqSnQzDsSnvvTaAiP
         VDmbwSmwfIs/SRBeJ2uYLNbiJvxBLK2BWtoIC9yXfNcI3jqb6HWd9YRl/b0ks7IgaN/b
         8SdsK2Cdxo2yH302nnM6B4mZewekZPuYoUd97YAEcDudEXtAD8RIuRdAnAevcM7K9AYP
         M2JhDzZqKEDPpSphjzpl3o/w4MUlU/IHvJ8h+oxJwhJyww52U2W0GpR++Urk2xbGVEJP
         +8AsmuO9OBk6Lkf9VHS39kGMi37ERIGk8ge7rHZO/oWIqN7OzJE+IS/5C/Fs9fiDW47s
         5Bxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JOdKZZJu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h19si18186954pgg.125.2019.06.03.05.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 05:11:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=JOdKZZJu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SGbTcqGFDN+LyXFpLeZdtp0cOKIRUWh//D+jhegqSZU=; b=JOdKZZJuC3FdhIRlHcRig46fq
	4ACoGuCF3Pg3JULfWngphoLmAopBT4Nlv/pE2c5+wAfB/YrOBw2Y4pxRep4elrBAFusRlgyMV/3iY
	P6CfMZfQOeVDry00JlZx5SHAhwLR4UQhzxQ7N2Qn9qGlf8bvi6UpQJlPe1jh8YczHVT8UDYztq+Uy
	psqvRrwlBMUlu7wfokylIgOwtXxsUnZA3/dZYA7JfcaXQ916SeH21BaYpu/w3naMLEzTvVGa68QNF
	zzQHuQ017c30jTXnb8o52oxnjcRPzYB4m5W02jJT7fjAYboRFTgQ6cWBTxaFKKQck1m5G+AeZ/4VC
	6I/HQ1P8A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hXloR-0008Tw-02; Mon, 03 Jun 2019 12:11:39 +0000
Date: Mon, 3 Jun 2019 05:11:38 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Nagal, Amit               UTC CCS" <Amit.Nagal@utc.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"CHAWLA, RITU              UTC CCS" <RITU.CHAWLA@utc.com>,
	"Netter, Christian M       UTC CCS" <christian.Netter@fs.UTC.COM>
Subject: Re: [External] Re: linux kernel page allocation failure and tuning
 of page cache
Message-ID: <20190603121138.GC23346@bombadil.infradead.org>
References: <09c5d10e9d6b4c258b22db23e7a17513@UUSALE1A.utcmail.com>
 <CAKgT0UfoLDxL_8QkF_fuUK-2-6KGFr5y=2_nRZCNc_u+d+LCrg@mail.gmail.com>
 <6ec47a90f5b047dabe4028ca90bb74ab@UUSALE1A.utcmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6ec47a90f5b047dabe4028ca90bb74ab@UUSALE1A.utcmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 05:30:57AM +0000, Nagal, Amit               UTC CCS wrote:
> > [  776.174308] Mem-Info:
> > [  776.176650] active_anon:2037 inactive_anon:23 isolated_anon:0 [  
> > 776.176650]  active_file:2636 inactive_file:7391 isolated_file:32 [  
> > 776.176650]  unevictable:0 dirty:1366 writeback:1281 unstable:0 [  
> > 776.176650]  slab_reclaimable:719 slab_unreclaimable:724 [  
> > 776.176650]  mapped:1990 shmem:26 pagetables:159 bounce:0 [  
> > 776.176650]  free:373 free_pcp:6 free_cma:0 [  776.209062] Node 0 
> > active_anon:8148kB inactive_anon:92kB active_file:10544kB 
> > inactive_file:29564kB unevictable:0kB isolated(anon):0kB 
> > isolated(file):128kB mapped:7960kB dirty:5464kB writeback:5124kB 
> > shmem:104kB writeback_tmp:0kB unstable:0kB pages_scanned:0 
> > all_unreclaimable? no [  776.233602] Normal free:1492kB min:964kB 
> > low:1204kB high:1444kB active_anon:8148kB inactive_anon:92kB 
> > active_file:10544kB inactive_file:29564kB unevictable:0kB 
> > writepending:10588kB present:65536kB managed:59304kB mlocked:0kB 
> > slab_reclaimable:2876kB slab_unreclaimable:2896kB kernel_stack:1152kB 
> > pagetables:636kB bounce:0kB free_pcp:24kB local_pcp:24kB free_cma:0kB 
> > [  776.265406] lowmem_reserve[]: 0 0 [  776.268761] Normal: 7*4kB (H) 
> > 5*8kB (H) 7*16kB (H) 5*32kB (H) 6*64kB (H) 2*128kB (H) 2*256kB (H) 
> > 0*512kB 0*1024kB 0*2048kB 0*4096kB = 1492kB
> > 10071 total pagecache pages
> > [  776.284124] 0 pages in swap cache
> > [  776.287446] Swap cache stats: add 0, delete 0, find 0/0 [  
> > 776.292645] Free swap  = 0kB [  776.295532] Total swap = 0kB [  
> > 776.298421] 16384 pages RAM [  776.301224] 0 pages HighMem/MovableOnly 
> > [  776.305052] 1558 pages reserved
> >
> > 6) we have certain questions as below :
> > a) how the kernel memory got exhausted ? at the time of low memory conditions in kernel , are the kernel page flusher threads , which should have written dirty pages from page cache to flash disk , not > >executing at right time ? is the kernel page reclaim mechanism not executing at right time ?
> 
> >I suspect the pages are likely stuck in a state of buffering. In the case of sockets the packets will get queued up until either they can be serviced or the maximum size of the receive buffer as been exceeded >and they are dropped.
> 
> My concern here is that why the reclaim procedure has not triggered ?

It has triggered.  1281 pages are under writeback.

