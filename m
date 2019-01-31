Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 078DAC282DA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD660218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:16:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="szvNF0ZA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD660218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 594F58E0002; Wed, 30 Jan 2019 22:16:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 543F48E0001; Wed, 30 Jan 2019 22:16:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 459E68E0002; Wed, 30 Jan 2019 22:16:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 056C78E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:16:03 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id q63so1405469pfi.19
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:16:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=q96h4kwm/Sqf8bu8ayha5fRp1IMmzbqLQ+Npe+fUrCQ=;
        b=ChtBDwH1nH/kQFswMsFVFVbYLOnl+xdp85X47VCk5fzWKXhcaEppRC4M0KDOXkckF1
         YLQpzEm0aylggBgCXUef3KD+l+cVFfs+5c6bOH02axjc6vSIYZjhbD28JqqFxR1oRWzs
         y84DobJJSQ6FT0jbav93ZrPGH8nu61vwldAJY5RuGCKt81s3aidc0TSAvih5BYhbuMHU
         0+6HLSaf3BHDSE3BHmWAh/SfQhYpkRKG7U7MhnyeECkUj8dq9JvMderAU0CW9kLk4YnA
         p5jvopNAws6ohPjcmh0TF7aWo3IQJGX+ik3EmWeCOw4zbf4utxm6L7ba2zgDcv8PTxSZ
         8M5Q==
X-Gm-Message-State: AJcUukdsXHBjbnYlcwJWyPLu0Mkxx7iz2fB8eEa5+djI/FzssGhaa8Q5
	RpGv2ZN0fkGKwT58TciV+0ErL6RechmjSySrd09oRBf7iPRJMDyFurmyDD7vkq73RVULcU/+Ukt
	LhodoLg2RCStbpz0P4rbEw5lgjEyWQEwpVcQ226RkF+lY0vE+NcgeT2wta3f+9PEj1w==
X-Received: by 2002:a17:902:7402:: with SMTP id g2mr32187106pll.198.1548904562688;
        Wed, 30 Jan 2019 19:16:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN46fKJ558CK1h/o1Nio9LGYdeTbLe1NdXNhsOxisjiUPs/v5ZTlxqZgFc99bBb7W0SNv/06
X-Received: by 2002:a17:902:7402:: with SMTP id g2mr32187066pll.198.1548904561924;
        Wed, 30 Jan 2019 19:16:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548904561; cv=none;
        d=google.com; s=arc-20160816;
        b=Gr18Ry+81Ny3o5ySn3xpJaOJ+scXMeYjy9NiuRRIkfBL0SnrtYXbCinyRu5wEo00Dp
         3KW5tEs5npthn97DwWLCYQuq6JnlaSp9PDvCi4rbVWanHdlZf5t3kl27wDpTfGQ0bP3v
         IKs7FcYYqO+De/ED7KOW0jL8OoSQAP7Sk91EkrwlSstzvlyqLhQS9J8HPyFj8IOpjlWv
         xMGVwibMaDdhSem1T3hkLq1KepqpBzQRHNR7g0dgqD8KMVYItiocH5Jd0qUBIUFkJmNN
         ELqVJDqKUp8bYNfUyG7QPpvelsR/1Ku/XfbW+szPChT1WrOqGAjQa+6QZ/5grwljZImc
         BnfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject
         :dkim-signature;
        bh=q96h4kwm/Sqf8bu8ayha5fRp1IMmzbqLQ+Npe+fUrCQ=;
        b=cXFlnPtz8EqZjwiUcSHJ1on+An4dr9T5Nir/KtR9YiagPiAb34ikqS/wz71iEW/eJl
         uzRwXmrL+BJDzaNSbuPKzB0iqEyhemXOc81+hTBBA8nZP2mzLVClzb+KPsSjjU3jfPNB
         ecCOv7lZrRPGhF+9CxeoxftIA6TQwpAULlURsEXdLzDIInsjzPE0rWZXmbFhSUwhERpB
         YlRwKY1YVNImkDjEHJDnquQXLSYivmcdXWGYpXegcpOqeMcNyXsqf03dPPInSZQSh28V
         o6cunNAHqNP7Pv8kCNNkLdYU7NBwMhEdXEgQna/x1fnVclw1TjeDdw/2dWH3/b9wNKE3
         I/9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=szvNF0ZA;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b3si3320473pld.282.2019.01.30.19.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 19:16:01 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=szvNF0ZA;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=q96h4kwm/Sqf8bu8ayha5fRp1IMmzbqLQ+Npe+fUrCQ=; b=szvNF0ZAzF8z863pERl37/9db
	/G4dicJMIRSlqSBsXLYsIkdrEhGNeCwYCWD8TJtfiSw/buV2PSWJQTuiwYuYNQIOymd+OyNYCMsNQ
	aybW6jDalNusiF3E4BEyal+2LtyaZGlUAJKGmi51D9XTfPHVtvGhm1z2TCQMGFXYJpR5nBB8VG/XI
	BSoRXKF2vuYSM32nbSnXg3u8BH9KMqYNrG3gWmaW1eMIwWB6/GybKGfkTvGxaQm+FR/qU4npeAZj2
	XpnN6aBXzhqAti1+5c70p8N75k8UGyf+fMlSbFDRW8kUL7zzQy2jSkkuj2oNDIFiYl8GUdohKmjIG
	lNDbWQJQw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gp2pa-0000dB-Te; Thu, 31 Jan 2019 03:15:58 +0000
Subject: Re: mmotm 2019-01-30-15-02 uploaded (i386 build summary)
To: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 sfr@canb.auug.org.au, linux-next@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
References: <20190130230305.d7osZ%akpm@linux-foundation.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <c19c92ac-2490-4342-4cc1-276b5bf5ea8f@infradead.org>
Date: Wed, 30 Jan 2019 19:15:27 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190130230305.d7osZ%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/30/19 3:03 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-01-30-15-02 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
> 

argghh.  I guess nobody builds on i386 any more.

Summary from 8 i386 builds:
(ignoring "missing braces" in drm)

../kernel/dma/swiotlb.c:211:9: warning: format ‘%lu’ expects argument of type ‘long unsigned int’, but argument 3 has type ‘size_t’ [-Wformat=]
../kernel/dma/swiotlb.c:217:9: warning: format ‘%lu’ expects argument of type ‘long unsigned int’, but argument 3 has type ‘size_t’ [-Wformat=]

ld: drivers/mtd/nand/raw/meson_nand.o: in function `meson_nfc_setup_data_interface':
meson_nand.c:(.text+0x1f9): undefined reference to `__udivdi3'

../arch/x86/platform/olpc/olpc_dt.c:146:10: warning: format ‘%lu’ expects argument of type ‘long unsigned int’, but argument 3 has type ‘size_t’ [-Wformat=]

../mm/memcontrol.c:5629:52: error: ‘THP_FAULT_ALLOC’ undeclared (first use in this function)
../mm/memcontrol.c:5631:17: error: ‘THP_COLLAPSE_ALLOC’ undeclared (first use in this function)
../mm/memcontrol.c:5629:52: error: ‘THP_FAULT_ALLOC’ undeclared (first use in this function)
../mm/memcontrol.c:5631:17: error: ‘THP_COLLAPSE_ALLOC’ undeclared (first use in this function)


-- 
~Randy

