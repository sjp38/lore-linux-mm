Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EEA5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:43:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EA3A2146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 14:43:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EchB4eEV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EA3A2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 851AA8E001C; Wed, 20 Feb 2019 09:43:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 801B68E0002; Wed, 20 Feb 2019 09:43:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F02E8E001C; Wed, 20 Feb 2019 09:43:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 301CD8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 09:43:49 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f5so16938828pgh.14
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:43:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i98cd3xlCj3svhnpAqR71Miyup2egVRF9MfpNdGm1OQ=;
        b=g84jOChlewoHogDQ9OdivgMqroUfdnQVyRUy+XeWPFthh3aIfaUHPGxI9yYz86NI5S
         RTDjlx1juG2UCs+cJ9/tOpUER+OQqAzmC3fICAQI4ZMB2dTWWjXnSb+hp1myU5mFVEBT
         A/Ca66AuVpHwueIX6j6/jKkDCkGU0BY+oGAXlfE5VZi9706+/pchpmtMxQB3BewbnR4B
         Lbmb4vbBDk9NQrOtHQFENW4Pj5ztYWNPQSOwzDdZgg+wZ6X33bLgtKpzpTzQGhhHAYHZ
         +nhrqjC1Twc+YgWYt2Tl/DnKmhG9cD1tkbia1tWgtmJHOEhJl/QAQ8hjCcaF8huCpgO1
         O3DA==
X-Gm-Message-State: AHQUAubW0eCfY6HX4EGlJBEYVjEHu0/TVNFwfQ0jGgSvm7tzTYlAWF7q
	IrDEplBaTbOY+s3c5dSXEcgAdjI4MNN8+KLzds6xJZ0klffrXRiYvwOaaoe2xP7YA00dIMhWmWP
	vB9/bO3DSyzcOfQAeanbcOV86IrXUZqwravu6D+oT4gYO5N1geWAZUOJErMdhokWt3g==
X-Received: by 2002:a17:902:7608:: with SMTP id k8mr36363594pll.245.1550673828766;
        Wed, 20 Feb 2019 06:43:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYzmA1d+MhX9yt5VRdTRB77Y0/lj2v7OhchlySduIjjUTYXu/ZqpZLX7PYfodXIfJOlXquP
X-Received: by 2002:a17:902:7608:: with SMTP id k8mr36363544pll.245.1550673827894;
        Wed, 20 Feb 2019 06:43:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550673827; cv=none;
        d=google.com; s=arc-20160816;
        b=E5VdoKfqnhYqTLlc7QbwRZzwFtTP8MBoRwJkwZy+kaVfJasQEI8RI5loaWj49JMCkV
         K9PVlJiv+YUqtKg6q2k0tvtK76MIj0R5PbWmg4A93893QGEwYm3R0RGaJCVjRCqGeXP8
         Rw8PjdxU/sqyNMYhB1ol1P7+RF4m6kwKmg5Ij1evFZmSnOzZBgC/R3rQ8Sf2wVWxlD1Z
         AxFwDBwwMUrRF8saks6wBeg29WhA+EcBuGSOaADYWFSihIWrKdV0FQQLxQsGtvHL6MqV
         m+5ABNl9sCsmCrXRCwV4iOvXa6p5+RwBfuJNwgNJd8/BazjrqSxCML4gQilU51qvYkEg
         hy8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i98cd3xlCj3svhnpAqR71Miyup2egVRF9MfpNdGm1OQ=;
        b=Z809gJIe33aEOa1YEHCdmzuanyDqBFfkqZFyBWdbpfXKk1x4Mc+r1C0kLSuZ+SGB2x
         PoMxnt2/ZTWF764jkMH22dyL6WQhEcbQf7YjrXsIw5lpydEBDxyh7RmHAp9L3gFyyCOU
         lwTP1ouV9EvqmePZn+EQCMRC4ZkE36bRRCKixZsr3RA5vRJf725VpxoZF4s+W9FSgPJw
         EviTqydX6MPWxQu9P21k8ezhgtznkO9NDTDpx5dGk/BSW5R6AIDBTpcaAU2mpxULlcBK
         k8wfjcVQTxV59WiZ8G/8Y4PGKUYmFAYiHXr+9kc/0vBFzyYw4copCS2ev1suXcFyozOv
         9Qrw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EchB4eEV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d133si19593631pfd.163.2019.02.20.06.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Feb 2019 06:43:47 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EchB4eEV;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=i98cd3xlCj3svhnpAqR71Miyup2egVRF9MfpNdGm1OQ=; b=EchB4eEVC5NuPeSwZ351dtv4J
	l/kWZw3bmNT2Aj2FviPzD6eKtBLTOxpeDKzzDqQRvyDsi6kiugCoDWaIharWau4u/vX/Fl8DYUyB6
	AZBOnpwJRW5V49DzdjrlROS6NvOvGLP13qL4ufn88z5lB7J7iRabT7oPZDfAgb9maSXUbn/pef17W
	/iP7u7Wes12HdtLRMod3nKPcOX8Co+KR8lsgJ8PfWDNS11WlftR3eLt9v+GIC8xmtGmQOPdIl9jkn
	yNsyHTzg4HJPwKT4BdagaisDUmg34dY76aTv9MQfgDuHBr3fZHE6SktBNL2s+ArDKjMBFj6Wb5Y1E
	8ZNjTIaEw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gwT6A-0006me-9M; Wed, 20 Feb 2019 14:43:46 +0000
Date: Wed, 20 Feb 2019 06:43:46 -0800
From: Matthew Wilcox <willy@infradead.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-fsdevel@vger.kernel.org, linux-nvme@lists.infradead.org,
	linux-block@vger.kernel.org
Subject: Re: Read-only Mapping of Program Text using Large THP Pages
Message-ID: <20190220144345.GG12668@bombadil.infradead.org>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org>
 <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


[adding linux-nvme and linux-block for opinions on the critical-page-first
idea in the second and third paragraphs below]

On Wed, Feb 20, 2019 at 07:07:29AM -0700, William Kucharski wrote:
> > On Feb 20, 2019, at 6:44 AM, Matthew Wilcox <willy@infradead.org> wrote:
> > That interface would need to have some hint from the VFS as to what
> > range of file offsets it's looking for, and which page is the critical
> > one.  Maybe that's as simple as passing in pgoff and order, where pgoff is
> > not necessarily aligned to 1<<order.  Or maybe we want to explicitly
> > pass in start, end, critical.
> 
> The order is especially important, as I think it's vital that the FS can
> tell the difference between a caller wanting 2M in PAGESIZE pages
> (something that could be satisfied by taking multiple trips through the
> existing readahead) or needing to transfer ALL the content for a 2M page
> as the fault can't be satisfied until the operation is complete.

There's an open question here (at least in my mind) whether it's worth
transferring the critical page first and creating a temporary PTE mapping
for just that one page, then filling in the other 511 pages around it
and replacing it with a PMD-sized mapping.  We've had similar discussions
around this with zeroing freshly-allocated PMD pages, but I'm not aware
of anyone showing any numbers.  The only reason this might be a win
is that we wouldn't have to flush remote CPUs when replacing the PTE
mapping with a PMD mapping because they would both map to the same page.

It might be a complete loss because IO systems are generally set up for
working well with large contiguous IOs rather than returning a page here,
12 pages there and then 499 pages there.  To a certain extent we fixed
that in NVMe; where SCSI required transferring bytes in order across the
wire, an NVMe device is provided with a list of pages and can transfer
bytes in whatever way makes most sense for it.  What NVMe doesn't have
is a way for the host to tell the controller "Here's a 2MB sized I/O;
bytes 40960 to 45056 are most important to me; please give me a completion
event once those bytes are valid and then another completion event once
the entire I/O is finished".

I have no idea if hardware designers would be interested in adding that
kind of complexity, but this is why we also have I/O people at the same
meeting, so we can get these kinds of whole-stack discussions going.

> It also
> won't be long before reading 1G at a time to map PUD-sized pages becomes
> more important, plus the need to support various sizes in-between for
> architectures like ARM that support them (see the non-standard size THP
> discussion for more on that.)

The critical-page-first notion becomes even more interesting at these
larger sizes.  If a memory system is capable of, say, 40GB/s, it can
only handle 40 1GB page faults per second, and each individual page
fault takes 25ms.  That's rotating rust latencies ;-)

> I'm also hoping the conference would have enough "mixer" time that MM folks
> can have a nice discussion with the FS folks to get their input - or at the
> very least these mail threads will get that ball rolling.

Yes, there are both joint sessions (sometimes plenary with all three
streams, sometimes two streams) and plenty of time allocated to
inter-session discussions.  There's usually substantial on-site meal
and coffee breaks during which many important unscheduled discussions
take place.

