Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2C44C4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 18:17:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27994206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 18:17:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="a2ZfRHVi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27994206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 046FF6B0003; Thu, 25 Apr 2019 14:17:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01D956B0005; Thu, 25 Apr 2019 14:17:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E60136B0006; Thu, 25 Apr 2019 14:17:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id ACBA86B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:17:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a3so437421pfi.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:17:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=tRoNJ8c4cbN57uzpVjJsLti1b65Ha0XS4q1OKT5SUhc=;
        b=axlaaLx27vmmwj8tA/WWkrVE0dNHrDAdRRob/vMIQTcT7GbABLmYFsUs7XikltKrvJ
         BLylsFsqy171zswRV6ju8Aa37W57ewolYHWsyXAvM5D9sFBEovrRJkhMbyQF49qzVjjD
         IvbxpQAsUwRo9YKnRK5XZ4xc7sw4V8ltGg8oHDtNafhezf3Y30Fgxy9+uMsQcwqjPxLY
         HoEr/wVSl1QsAiDrcSfR8oolUVeZbBkFpH4OVUilW8HVrXOZ9eMN9WejdxYM36G+2XEj
         pQ0S0S8dBCcTqghSbDpHrqJTbogqOBO9wv8GNZtkIAN0tBaWlAPBuxmqNvmXmP57Z5Sw
         dGWA==
X-Gm-Message-State: APjAAAVzY+gdot1ahbllqDde34FYCZQyFZKFD1l/KZCnW9LH8rCx7W/M
	OoZDYHvmY0+Y89XnmVzYA9TI1Xv61vpjYtzstbCk1vLQAhon1ZZtv/Pwrv15i+Yf2LRW/ZFT6b4
	YltqNT4BRcNvQzTBVKk2S+O3PyihM4fvwU4XnG9Ss7o/UVfmqbbO93ctdvOn8SQODeA==
X-Received: by 2002:a17:902:801:: with SMTP id 1mr39164243plk.14.1556216274106;
        Thu, 25 Apr 2019 11:17:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhmzf8eW6+WVOUiOl9Dpg1HQO2jfnqqX8g2GOkdKLBckrEwEwPHvinWTOWNDmn+jQhm5OR
X-Received: by 2002:a17:902:801:: with SMTP id 1mr39164166plk.14.1556216273371;
        Thu, 25 Apr 2019 11:17:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556216273; cv=none;
        d=google.com; s=arc-20160816;
        b=D1KlTOUSpEOKUFUCIBvsCYxKayS7Bh428LXJSPloztfT/0UoRwWxdy4K1GwGMyoYJw
         tKaW3uGNOapzAIubHkKSYkyNZIJS1RkqHYqnPUkFqB4b7aW5laPEf1m9UFntmuaUMSkr
         AceoZmt/Dsxq4lv3fj1YGQ8BU6C+GLpqgmtUcnMNyk+rekRMJFa2MWZz//cKZ+bNQsxw
         neT7FT7b6ltSlHw+VEAh25V9cxhv2zACOuSz/xr64mC7au3X4NfIaJzOxrUwo5SdBGDE
         5m/pEP620xrBfI9ZlEYLG5RMc/yqUkjH9VP0YHuGw13JJ40/ZjMEDqNwyY2Z+abZ/0nJ
         UxVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=tRoNJ8c4cbN57uzpVjJsLti1b65Ha0XS4q1OKT5SUhc=;
        b=r2vUo9fpBlwwO9ycQp/G2bfGDaJOZ3tvvYY6xSaflu6SBYIIR8ktWzGnHPt7Mw1oLN
         CAKEoxrHgBjQC/9hK/nR3XETWDMMabewqfLLdO2rbvjsmUG6A8wgt2ijtdt8Z8z3GUCm
         skya74OT6sfc1q+1lbUIUgdyc1CKftCkk4LuAZKYO1NuIYjiDAeO4SlhFOW5QCX8dUDk
         dkwZyxdMz6sT5pZ4ojeQAZpS580hH8LUSHu1243+7sTbGBomABdBvnAA5M9xdrZmwnQV
         Q7Hz6FBfj9kBkfMzUTUHz+1h+uFef7pR2d/wTzYtdMYhRW/PODu1BE6GxclvWdyJJfcW
         ACHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=a2ZfRHVi;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h69si23590535pfc.100.2019.04.25.11.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 11:17:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=a2ZfRHVi;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=tRoNJ8c4cbN57uzpVjJsLti1b65Ha0XS4q1OKT5SUhc=; b=a2ZfRHViaari4YLFzrqFZ4Xcv
	pPtn0t/Ikwnz+zDeTwk5ZwWrGRVlT58S1XUXFSR8UgdTWRWewHdmfi4Subbyk8BKZwyNIG9unYqRE
	ALVHeVhS1e7uwc9LiONexeLx6a1SPYdmNRcLVe9GKIvDolsrpFXatNsNNIdTw21e/BJU5Dzhgy5ka
	2lkgXtDWh8vQ0B1s4dKgSvZ/lZT23l0RSn0J3QDJjFMaHw2aIPTeZ+Ug3Pe6X1dqSAuPRxjAc55Yb
	zKoCB0V6hKaeSVzY626itIKuX52IEH2PzF9nn3cwyYwucKNtPk/jTGTHqzLOiQgxvd7UEy1pISpqQ
	iPcq7BOgw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJiwK-0008P9-UW; Thu, 25 Apr 2019 18:17:45 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E5895203C072C; Thu, 25 Apr 2019 20:17:42 +0200 (CEST)
Date: Thu, 25 Apr 2019 20:17:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Rick Edgecombe <rick.p.edgecombe@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	x86@kernel.org, hpa@zytor.com, Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org, akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
	will.deacon@arm.com, ard.biesheuvel@linaro.org,
	kristen@linux.intel.com, deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v4 04/23] x86/mm: Save DRs when loading a temporary mm
Message-ID: <20190425181742.GZ11158@hirez.programming.kicks-ass.net>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
 <20190422185805.1169-5-rick.p.edgecombe@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190422185805.1169-5-rick.p.edgecombe@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 22, 2019 at 11:57:46AM -0700, Rick Edgecombe wrote:
> From: Nadav Amit <namit@vmware.com>
> 
> Prevent user watchpoints from mistakenly firing while the temporary mm
> is being used. As the addresses that of the temporary mm might overlap
> those of the user-process, this is necessary to prevent wrong signals
> or worse things from happening.

Ooh, goody, that would be fun indeed.

> Cc: Andy Lutomirski <luto@kernel.org>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

> Signed-off-by: Nadav Amit <namit@vmware.com>
> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>

