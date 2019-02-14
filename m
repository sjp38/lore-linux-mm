Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82424C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:18:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40DAC21B68
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 21:18:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="OblGoiEo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40DAC21B68
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA8948E0002; Thu, 14 Feb 2019 16:17:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A58708E0001; Thu, 14 Feb 2019 16:17:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9979A8E0003; Thu, 14 Feb 2019 16:17:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3658E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 16:17:59 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id k14so5249896pls.2
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 13:17:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1yL8YCNTyPRDZJHx8ppA3BOOOrsNcEeL/DDCwGQrYXE=;
        b=npPC6RRTklsAm5TH2OmhCUR7QfkmC6mCpS7BYEdTcscnZZ3dvMpXQkjNxySdh3uHQY
         vLgm6fMsPeWWXnGcH520St6NdXw5Y2sKnyVZAQY3CiL2411GlHhOgQl9ZuzRvphsGDyd
         nMbhpns+bhs1c05zmYRpMqpqyYxt9b8fj/ERu5TsNKpgmhct/DLcveOs6x25RHI4lYcN
         SMITy4F03zlxwST428cIEsVS0Vo28JIQxFKDkNH6ZnFNHErGZPoiimlyEpxoRCsTPE2U
         KNsA7xBjUcdbYylzx/FxP2AZA4fZDza4upYsGmt0ZXgcoHe7CwYlUyrP2mCE6zQGncdA
         fYGQ==
X-Gm-Message-State: AHQUAuZAf/L0CHCIvY9xM1KxC7G5zKQ+XdL7F229brbyvkqEUx4USCUS
	Z2nEzJ2P84yitvrS9EVsw+VfY7Ss9/HZ1IO1x8cu8d5MUs/Hlx6sF7zGxVrApZPE7Iiaz3Jo/a1
	x7XuVvjDUsdjdnWSVQBGmlA69mk2rSR6DEarEbCOQET9iyoBJzwNg4empxoTYGnKL5w==
X-Received: by 2002:a17:902:988b:: with SMTP id s11mr6403027plp.162.1550179079070;
        Thu, 14 Feb 2019 13:17:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBitP9+0zSVU4xraD+DNq+N8MnbjYSwdZQ3Ae6C5VF7DEuTJZuP2U3GO13HTZqBY49hpeF
X-Received: by 2002:a17:902:988b:: with SMTP id s11mr6402986plp.162.1550179078430;
        Thu, 14 Feb 2019 13:17:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550179078; cv=none;
        d=google.com; s=arc-20160816;
        b=fQsbCPcx0LFbgSSwqVo0SSkHhpq7tbS0hXtaFj7DcyhPlR+4uLlkmxiSrF4rXaKChe
         wjIkrR5BoHHlDYm5/dhJ+DbSmTUlhkVEadfLektAz2nxMqtZ+DpiQ2aBpK4b0/7/9bbS
         sW0lKLDr4SiBeRKliHz4IAdT+2+oiof8RExo8vPSvz/GSFJXEkMNC7fZKw0iSBayfV10
         ESWVu5joNt1Q4RtrmyDYlQt2oiCaVaGbyQpoYQeu5jNKtc9WRP7i2PQXdzZegAA91DPh
         aCDmrxCPJFmNsBqOk5cTdsII0OUug26Ve0h+2+MKKk6xNbNdxQAXuqKGZrH24RHgZzTj
         eBMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1yL8YCNTyPRDZJHx8ppA3BOOOrsNcEeL/DDCwGQrYXE=;
        b=o+KTJjdE39Q9brpQXr7uVUZkEQo8TPDSYBx68UyoqK9du5vhF9JViJovJ1l/J91TFh
         Q2BWZNmikm8noqKbM/WHJG+X5T2OCYVjfA8PtujW87I6gv/aDYNG9Re8F384MgghIqxI
         Jw65SqCNnzi4sZHH+JsfrtRTUbncmq9+Q4Fdc5RO7b6GH/JyZ0otEbT67/1++U7gVA4V
         JrVejGQEmBet8by2JQYeGTdsZq1sFqfYnybF+cp/hKe98lqNhfYD3UvBVnRRTowxFMQY
         gzsSaYHl9lbX6woJMJVydWj1ryWXJPfXONRbdOmICKrwP1IWSUee/AGGLytsPUzSjuPF
         QBgA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OblGoiEo;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 97si3587767ple.389.2019.02.14.13.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 13:17:58 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=OblGoiEo;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=1yL8YCNTyPRDZJHx8ppA3BOOOrsNcEeL/DDCwGQrYXE=; b=OblGoiEoqNUCx7iifqcOT3krK
	r8c5Z+drdTpWgHR50kG0PnEHRAy9TeIXu0EiLwvA7OVY2LFXNXVaF8Qo7cFDyA0G7Xa+0Ol1531F+
	0bt4sHrt0HFgCu8tRHyUp79MfqISuOfO4kR72LO7t4JeTZ7W1zVmdxcWNVqaT7t5xUzKb/Vl7YjEP
	CEcFf++SqdUdxGRroRdV51r/tRH2uLX75J5jcqMJB79kVSp6pi0XxIGTkyWYK97zTsUOR3ikPWZQB
	qH7qDT0PsQI6rhKhdeJDNmFnvIRd0CJ+8nRpGX/A//iDGEvLUs1XDa1PjllyY+PqPQAeIXQwNuYqi
	evZ1+vQUw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1guOOL-0001kd-Qx; Thu, 14 Feb 2019 21:17:57 +0000
Date: Thu, 14 Feb 2019 13:17:57 -0800
From: Matthew Wilcox <willy@infradead.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	William Kucharski <william.kucharski@oracle.com>
Subject: Re: [PATCH v2] page cache: Store only head pages in i_pages
Message-ID: <20190214211757.GE12668@bombadil.infradead.org>
References: <20190212183454.26062-1-willy@infradead.org>
 <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214133004.js7s42igiqc5pgwf@kshutemo-mobl1>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:30:04PM +0300, Kirill A. Shutemov wrote:
>  - migrate_page_move_mapping() has to be converted too.

I think that's as simple as:

+++ b/mm/migrate.c
@@ -465,7 +465,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
 
                for (i = 1; i < HPAGE_PMD_NR; i++) {
                        xas_next(&xas);
-                       xas_store(&xas, newpage + i);
+                       xas_store(&xas, newpage);
                }
        }
 

or do you see something else I missed?

