Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 766BFC04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:44:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29D5A2084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:44:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uCVDsA4d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29D5A2084E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B21BD6B0003; Wed, 15 May 2019 10:44:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD21D6B0006; Wed, 15 May 2019 10:44:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E8C56B0007; Wed, 15 May 2019 10:44:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67A906B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:44:00 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l16so1787070pfb.23
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:44:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=msiRUtVZ8HSn4DdePbxIYPVfN3e75W0NOasQGN4KIA4=;
        b=MUgBl0nVZpsjE8RTl26Eqb4ko3OgS8wHEHYUp6mzBqVHcsoLyb1yOzi5LGkgHesgPI
         7Jo96JNxfhXXNlvVI1076x/6F6pZc5zUiSlqd1Gng2ezrMNX+KokugWl++rzPGxtfHPB
         r331kel80KOgshFtbyNPpNVbYf5UgSkCob+oCyCXhq9kEmktysipL3W7o9rCmUBllnyc
         Mj9XhwjVGOpne4qr6dzLLndFKoJDR/CAbxW2ZSHKzrEHLDL5uhTQxsY9Xk9HNyF5ehJY
         aUGVJmBwk7Zzzxc4AFYGZFwnPM30BWKMuG46VEbHK5c0DYfjXwWxbzTZNU54B098Ju9d
         08TQ==
X-Gm-Message-State: APjAAAVOW4y19DdT8+iOCohi52IiDCQLV+b5TIT8WBIokqTxZijDPeBE
	I8Rx2jgBIQ9Tah/ESHal5RdQozo1iCB0r+Gr2souNm5jd1yX2WNhMNLG+H/T0EP702MM0bSWTPv
	2HBq8pqu02POCFGPm4HK8l/+E53SAT/8fMvNEvrlO5OHcR1AzyC3ifEwoWmTcqx1DuA==
X-Received: by 2002:a63:6a4a:: with SMTP id f71mr43825661pgc.44.1557931439807;
        Wed, 15 May 2019 07:43:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwifBMpJsl/NTCg4vzu8dnfrNS58UXOISPPqQaDYU3UafZ85DLgPjnu1uhpiGVf5cIS4Q6+
X-Received: by 2002:a63:6a4a:: with SMTP id f71mr43825610pgc.44.1557931438959;
        Wed, 15 May 2019 07:43:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557931438; cv=none;
        d=google.com; s=arc-20160816;
        b=XsNrKlYdzlZJZWqpRMpHe+CIeZKB2ERD2Zfmz/cAmqMxrdVpoWE5VPrJKdMksUaqsj
         dEzaHqKSbm4XBPJY3nmKlvEQdknK+VGO61THyPcxq2rmYDNEOAfqhI4mdBTiCfJc4wNN
         8NPUvIaiLQ2TdMGwU18wf16tywkm+hgaENY1nMbhLoW1CrUfPZzYlPzmM9/smTM4KCDy
         OIMDuEftEctS0uKT7Q2eWVXgZRfJ/dUknv+xwtVf+sPbCy8XhTNu8VQ7hlq1txouC5aS
         0C/OiKzq9U9Uhc8mCdp/6bG06GbpUK0RLB7E7V9h3IXeCj7IJqPfFVsJh1L/RcOG0P7R
         GqUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=msiRUtVZ8HSn4DdePbxIYPVfN3e75W0NOasQGN4KIA4=;
        b=QRftcsHm7aikuBs/E+ergpHAu4vxrYvpdIsS8G1WJndYJ+pDFU/2u6YveQaQNjWDE/
         IegUdwlUB/O2RPGat/HGJd3yxVx4oOqLY4RVwT6bcE329mIiMwGOSXkiL8Hzl/W5EFvp
         LKkhUWUnNTfxD4Wygb2BERaHjJKNmDVLwLOHileBsz7W5n1mGi+zncgk6ZwcQ94hsNqp
         WEkCB/p6yPn7u6cmOPjlgORt8fOggVOlasTUVYojaRNayV+Hl8FqGHy5IKjvDTNMAbbm
         t9T1yt0rjC1HKT0/bBYNu655zhKccpMqBqDHeyicKOoaNLHF14kDVtaKqx7kQZ7DLJdA
         +mnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uCVDsA4d;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r4si1972828pgv.195.2019.05.15.07.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 15 May 2019 07:43:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uCVDsA4d;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=msiRUtVZ8HSn4DdePbxIYPVfN3e75W0NOasQGN4KIA4=; b=uCVDsA4d940++i/x0z86awqY8K
	10/9BCM/Z2Mr0+jfdFAvIZQ4drczdD3cJM+hemK6nb+JfJXaTqwxb0gGKHFpfGsTvCMsUJTVWLOqt
	kTf9wmMtnOPMinxGJ+hKQ1cekn6o7hZxCTGnqq43/5e009Lcr9KYZqFqHeejj+WL/2gNniCr+IT/R
	xmvRstEmckj37vMCYFbw+sL9rOJk749p9X9qdx9gwByu10InW7Vz2azwPG37Ie5NnbtWk/M7C3B3E
	AKkKCe/4Qu7sAQkWJFIzAEME8T6aQjyKTQe2R6ZpdVHQXiPBPwItazGv8RDsdZLdhKqJOO78WvqX1
	ytPC6/6Q==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQv8K-0006cq-SW; Wed, 15 May 2019 14:43:52 +0000
Date: Wed, 15 May 2019 07:43:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Lech Perczak <l.perczak@camlintechnologies.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Eric Dumazet <edumazet@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Piotr Figiel <p.figiel@camlintechnologies.com>,
	Krzysztof =?utf-8?Q?Drobi=C5=84ski?= <k.drobinski@camlintechnologies.com>,
	Pawel Lenkow <p.lenkow@camlintechnologies.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: Recurring warning in page_copy_sane (inside copy_page_to_iter)
 when running stress tests involving drop_caches
Message-ID: <20190515144352.GC31704@bombadil.infradead.org>
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > W dniu 25.04.2019 o 11:25, Lech Perczak pisze:
> >> Some time ago, after upgrading the Kernel on our i.MX6Q-based boards to mainline 4.18, and now to LTS 4.19 line, during stress tests we started noticing strange warnings coming from 'read' syscall, when page_copy_sane() check failed. Typical reproducibility is up to ~4 events per 24h. Warnings origin from different processes, mostly involved with the stress tests, but not necessarily with block devices we're stressing. If the warning appeared in process relating to block device stress test, it would be accompanied by corrupted data, as the read operation gets aborted. 
> >>
> >> When I started debugging the issue, I noticed that in all cases we're dealing with highmem zero-order pages. In this case, page_head(page) == page, so page_address(page) should be equal to page_address(head).
> >> However, it isn't the case, as page_address(head) in each case returns zero, causing the value of "v" to explode, and the check to fail.

You're seeing a race between page_address(page) being called twice.
Between those two calls, something has caused the page to be removed from
the page_address_map() list.  Eric's patch avoids calling page_address(),
so apply it and be happy.

Greg, can you consider 6daef95b8c914866a46247232a048447fff97279 for
backporting to stable?  Nobody realised it was a bugfix at the time it
went in.  I suspect there aren't too many of us running HIGHMEM kernels
any more.

