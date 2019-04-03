Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3850EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:27:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4F402084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 15:27:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FnGJ92n/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4F402084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84E666B0007; Wed,  3 Apr 2019 11:27:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FCC56B027A; Wed,  3 Apr 2019 11:27:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 712286B027B; Wed,  3 Apr 2019 11:27:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5656B0007
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 11:27:23 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f67so12624248pfh.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 08:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=S6NYoJrZ/veLL2w7VR6EZsl0qg+PNL9w8W7cjvQvY6Q=;
        b=Ii9dcaIks6qfGcuOfSVlwB6F1ngjxVx1ctMCdnmA5utpcP1i8KfzP7pcxD4mwCuJ3z
         Fwg5lM32d71YKBPabwbldcYzY37NChx8AyUDUbZ5RwFaSoSZbAb7gwNttYuVZnROzvYh
         ouvNPxh78BDyiAe/NWNBSHH7109KONtrcxbcRsQlUpda6NO6++BjQtxSTs9PCtnCoiqM
         eoFAyS8+UR30zTevg7/mliYRf/8qVvwv9d7lLZuZ6izpGqmVL8UylokG4PeUHLu5f9ZH
         jnE8IHBnTzgR7Bg8FM4UGBh67YR6j8XXiLTJcfcqAdxwvn9T1KJsjyDTQdUaBsEILbjp
         bGLQ==
X-Gm-Message-State: APjAAAVSKo+YmfdiHaMZUhSkMb+bMuB6lzvCnqUy5mfFl3WD4LC6AnaS
	ndiEjn3PdpxCgIpBuT6wf7JAYrrRlmNVokG/7OEuhuUUqvkMlfr1C5U6mmXMTewpD5ZC0jpj9EO
	4VKndGaOOk8R/jgQxLZ/5pd4lncrfRhWVNd3wL/Ugbb7MU1mUkpDlGXQDaX8RhB/FSQ==
X-Received: by 2002:aa7:8083:: with SMTP id v3mr59744724pff.135.1554305242809;
        Wed, 03 Apr 2019 08:27:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrjLxUIXeTCIss0dpgPh1whE+w4bVJNZvymDpLSNbJPdQwQLR9ki9QOYO0lvG9NzNaNxK7
X-Received: by 2002:aa7:8083:: with SMTP id v3mr59744621pff.135.1554305241861;
        Wed, 03 Apr 2019 08:27:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554305241; cv=none;
        d=google.com; s=arc-20160816;
        b=IqFbroTyMw8uE3NmVxbZDkiOepr2mmH9JKhijlQhVKQQnTBC27IOeeu0uhE9Pvhu8E
         sStU2cbHz24Z1wztDkzMGWLPyExi5tZPKKyVv4jaZhnOFPbIQrRfUxAYpuL7/PdjHJiu
         VpBHLbF4dklG9StuHYCr1gFVw5oN00Jb1WG3FtD3X7hDbeWTJaPI8hsMj2f5FDzqaOh6
         v//oqrfa8WTxL2SMRG1PtjMQ6hmYwbOxSA00ZNJwIiQB6H2UC8bvZEGofExvjsZw6IqP
         P+IIFIWrL4/MK5b6UZTkxYk1vkYBCzZrZcVMEVXQmHp7MKfvXM8r7s1nqQvWGcUDbA0T
         etdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=S6NYoJrZ/veLL2w7VR6EZsl0qg+PNL9w8W7cjvQvY6Q=;
        b=yo3hMikibwyIL+MiTwKUro5d4eZZsY1yuwwE4e5piX5pIASajjsiOB52slQMh/9HjO
         /cbn4sgG51qHSOWgtQbsD6UFFEOXt5L/Bp7587E/q4x9jV0s/o3FXB+Ia1pC5MYS4tNh
         90apnccnqrjzGF4jIZeXvUBWAm3ObVULmwh69G4b1UaFBpjgOBmpyFkKA/kDKGId/L6V
         JbzerjEguXNmPPtQ70/Hfl7S5S1pIgfwtuOJ/2vcCjzQyMgkvXyxDpVZA1SDwrcfe8Lc
         PqjRmqn6val4olw7Cp6T1icErddRx2AzxyaVxtBDO/cy3NtHoo52wI9Dr5zkgBuHi8SL
         gSOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="FnGJ92n/";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r6si13666049pfn.165.2019.04.03.08.27.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 08:27:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="FnGJ92n/";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=S6NYoJrZ/veLL2w7VR6EZsl0qg+PNL9w8W7cjvQvY6Q=; b=FnGJ92n/3MH+49wCKz493YBAj
	cZzxZoKEF/Vxv3SSxwUUS4nmmTIj9KouBb17sJllgaFCVqSzlOFt6+yOKgD34OlozgiNfDZOTNFYs
	Hrvcvii4cOYLLKNi94P/7bHznuhNChihDoWaPDOaGe2Aj3Ys1yOF1NBFTUH0XEbQ2HGfBiBM3/V4i
	fWT3drdY57OrIRucCxUNm/nzP81Q1+wluKlK4Vyuew1VKjyNATjRBYkaM0vNMASnFlZnGIRPcsTsB
	mT0TOIraxW01HkCTCL7Va4nvn2bJaMPtLmfmyFQJKQTGpGlz/bxe5B8vEJpmMRho7Ad+tHrBQXqxl
	ywWZhavWA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hBhnL-0002Eg-7L; Wed, 03 Apr 2019 15:27:19 +0000
Date: Wed, 3 Apr 2019 08:27:19 -0700
From: Matthew Wilcox <willy@infradead.org>
To: trong@android.com
Cc: oberpar@linux.ibm.com, akpm@linux-foundation.org,
	ndesaulniers@google.com, ghackmann@android.com, linux-mm@kvack.org,
	kbuild-all@01.org, rdunlap@infradead.org, lkp@intel.com,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] gcov: fix when CONFIG_MODULES is not set
Message-ID: <20190403152719.GH22763@bombadil.infradead.org>
References: <20190402030956.48166-1-trong@android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402030956.48166-1-trong@android.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 10:09:56AM +0700, trong@android.com wrote:
> From: Tri Vo <trong@android.com>
> 
> Fixes: 8c3d220cb6b5 ("gcov: clang support")

I think this is the wrong fix.  Why not simply:

+++ b/include/linux/module.h
@@ -709,6 +709,11 @@ static inline bool is_module_text_address(unsigned long addr)
        return false;
 }
 
+static inline bool within_module(unsigned long addr, const struct module *mod)
+{
+       return false;
+}
+
 /* Get/put a kernel symbol (calls should be symmetric) */
 #define symbol_get(x) ({ extern typeof(x) x __attribute__((weak)); &(x); })
 #define symbol_put(x) do { } while (0)

