Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9D87C28CC3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:53:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F32C2070B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 21:53:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="rEKgem6b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F32C2070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 154676B0274; Tue,  4 Jun 2019 17:53:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E2D6B0276; Tue,  4 Jun 2019 17:53:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F11AC6B0277; Tue,  4 Jun 2019 17:53:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B62F56B0274
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 17:53:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w31so5715949pgk.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 14:53:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ydSEivRYzdSfhn6bVS6O8EZKpwZExH21yzr12h2j8pI=;
        b=KXYhLSHWy9/I5l82rGgEUK1BL5etAMbPm2ZMaEopGsqu0Lbc25p0S3WpfIvRgKnAKf
         Xqc+jqoPk89AFmvJyBkzAO6qooWlg4r9Yo+datTiDzaqDbBPOmNziVGmXXAYoj8BHKMd
         o8oyAKsTdv578reBWSmGj9/ESdXC9sJ+lbVRO5M1R/16NgPRzAfiZ8AiOkUTGAiVmCBn
         CPZYeF3k651qkT5HS7TRszNSq6tkhrNAWiYCErUhpesYk/BW7VT7YpNxjkc75a9Vn914
         eMgzKXv37cteyuXFTNCELUlhmk56BSD15UipuHImIJZdNhVSlu50zLH4cyQisc4fiNJ+
         PlcA==
X-Gm-Message-State: APjAAAV90ZymtFVw7Rarz7NDRq0v1G35gmsYdj7+Wr5rhXr/3fsQ4nBS
	hYCrzj6VbKiif4cojY4m6mg+2/LyQv/NsKWDR34md/LMvVwTeuqOomnfGoB4XP3c+rv55KZICDu
	OJPSGROJh0MLydFFXfJhSskb6wCvrmMD50YUteg9pharRaN6aIRZMz4NA1qwDgH+ldg==
X-Received: by 2002:a62:2cc2:: with SMTP id s185mr40542223pfs.106.1559685212289;
        Tue, 04 Jun 2019 14:53:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxSMqNoVoIOWFJMZjfmJgtOP3w9I8Qk7tFkgRkqmi5oJdYriF/+YS+LmqzphDtTaQIEVZEH
X-Received: by 2002:a62:2cc2:: with SMTP id s185mr40542189pfs.106.1559685211625;
        Tue, 04 Jun 2019 14:53:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559685211; cv=none;
        d=google.com; s=arc-20160816;
        b=dCY8NVL9D7aWGv/GZQmuhmQtsAq7pKDJ4O8gGjf80ObDOq5brIK9vw2QP+jXymEONr
         CGXm5ZvmAdAJ8OodassDmxr2QB34evOMIXDGQp9CAyrKJudXHM+E/U0pyCWAdx0U7x2M
         sb/0NGdUefETqMVZ107t+WptcUDzn+jB0IJhkTvYGBJHTX5DCDriK79YOZPHphl9DL/0
         fGYEadFeKUPM2B/diolvnz1xnvSldHm+23GegKmYJVwSsQUiHRT6d9CB5IP34yYIJHdH
         CsIT/Hb6uwJcR1fOAa2yWk05MK7eVtpA0hRStpjF2WvlqPITJOYC9ADzrRI7fJ7Yxfm1
         qYtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ydSEivRYzdSfhn6bVS6O8EZKpwZExH21yzr12h2j8pI=;
        b=pjo1JhU/Af4XYmYlBUdI5xBuZC1+jk7WTVQgT2hsJ7Hc4O6MdgKAdI+2EVlnE5e2S8
         8AxEvX6PcHYC2EK6QM76xeKyGe0YIHbfuZpgnh9HM27qV2iVvmxhPMtdNB43/GUOf+vf
         nDQ6sW7qHfBuiu28ZkWHX14N2+SVTmXVnh84IN5G3UA6ThUy6fsdFeiWCMZZjIfQPOK6
         MQOu2qAC6+yos+P+x7DM4whrGkE0rlsCCXh7+n7HMlSSI4PpWuf+YWp5hKt+7Fr2/MFN
         RyAspUaHOZ9CoQuCGIWaWXqp5iR9Nbj9BifK7a2fm5dwexKTofiwEjQSMnB2LbgRymSQ
         GqmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rEKgem6b;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c9si22366545pgp.39.2019.06.04.14.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 14:53:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=rEKgem6b;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=ydSEivRYzdSfhn6bVS6O8EZKpwZExH21yzr12h2j8pI=; b=rEKgem6bNSXbcR15oERakPBEH
	ZV90o3C30SrvNq9uNtkXAN7m+277Y/z5tw8MfsVh+OcppVdR1OrSQhPJ7gMKDkfsmtPKlMP2PEtTp
	wv6tOwpzadAj06Ab4UzHL6vbw3yH/tzIQm+5j3XeQz5KVIYcz9L0pJDShL9qVvjab8euWgO6EZ8JP
	TNhxy7Sgkp4RSAnA1MPHZE/zWBv403ISpTJJHcI/8u60zuTEYjY7G8CoHHn22HZGKwNF8/09OoTDd
	GPRr5uyABlQYaLblfmmiFmOm5FqS2LZE0QKwwjJbPqtbNzs3E36ZfdB3/mg5ClCHkCkeC6w/QtqFP
	ZM3Jecpew==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hYHN0-0006qf-6V; Tue, 04 Jun 2019 21:53:26 +0000
Date: Tue, 4 Jun 2019 14:53:26 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Mark Rutland <mark.rutland@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Konovalov <andreyknvl@google.com>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Paul Mackerras <paulus@samba.org>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>
Subject: Re: [RFC V2] mm: Generalize notify_page_fault()
Message-ID: <20190604215325.GA2025@bombadil.infradead.org>
References: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559630046-12940-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 12:04:06PM +0530, Anshuman Khandual wrote:
> +++ b/arch/x86/mm/fault.c
> @@ -46,23 +46,6 @@ kmmio_fault(struct pt_regs *regs, unsigned long addr)
>  	return 0;
>  }
>  
> -static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
> -{
...
> -}

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0e8834a..c5a8dcf 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1778,6 +1778,7 @@ static inline int pte_devmap(pte_t pte)
>  }
>  #endif
>  
> +int notify_page_fault(struct pt_regs *regs, unsigned int trap);

Why is it now out-of-line?  

> +++ b/mm/memory.c
> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
> +{
> +	int ret = 0;
> +
> +	/*
> +	 * To be potentially processing a kprobe fault and to be allowed
> +	 * to call kprobe_running(), we have to be non-preemptible.
> +	 */
> +	if (kprobes_built_in() && !preemptible() && !user_mode(regs)) {
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret = 1;
> +	}
> +	return ret;
> +}
> +

I would argue this should be in kprobes.h as a static nokprobe_inline.

