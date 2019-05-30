Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87D42C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:06:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C835257C9
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 11:06:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="KW9gnXpS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C835257C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2E396B026C; Thu, 30 May 2019 07:06:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7F56B026E; Thu, 30 May 2019 07:06:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0BB26B026F; Thu, 30 May 2019 07:06:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1D96B026C
	for <linux-mm@kvack.org>; Thu, 30 May 2019 07:06:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id r4so4337323pfh.16
        for <linux-mm@kvack.org>; Thu, 30 May 2019 04:06:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XWSZAD9Y6uBVo7L5n2t8Ehyy7C5gbqMnRx8yZh9FlDg=;
        b=gAddm46XsGitcgnRjXdKvG0JAD18qKG8vB6iMD3B4JqdMEJBvoWwxxqNh5rGnvKR+3
         9nuCLsf5pN5MisgMhuY2oJsrb02qZbE9XWYls5iCpcUrIbbeZxfaqSPRaK/FdnAKj5I0
         UL73FX4tUscA3OzoSc9rvrgib5WKqnKr2mR/dXbnJ3Bp2l+CaLfMYYgc7yPodMi58JGJ
         Xf3iuqpPEDBuCJTgLQwRUNJwGALro+qtkii7ppiUXXu7wCv7oHhJZOP1VvdOu7zRrDDt
         4QEvTl/7H0RF7JbJw4HAp9/q9z6qoPyPXf7vf4YUpX68m3h0BsRofEp7KPm7RsVPffzX
         rghw==
X-Gm-Message-State: APjAAAU5clpFJ/6xbisGi4JDQxt63a1wDlBo03d+qLIZUsF2dy7fMIrs
	40C1E4rf041G5MvmzHUCTjnzOe31d+RazMpWCZ/b6dWGFa4y5xpkwV6OUYS2B7Hh5mXge51/r+V
	E+CsEI7bG68w4yV4SoiBSVzsUthBiulxxgMlwYQJHHIWm+pR+jKxVlelxoz9mzsjDoA==
X-Received: by 2002:a63:43c2:: with SMTP id q185mr3306546pga.280.1559214404999;
        Thu, 30 May 2019 04:06:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgTw+DMfJM+/HLd2BcBua9kYHZtjJopPDQ5sS5Er3n1EIhfPNVWD+oPUm1GpT4w++vQZGX
X-Received: by 2002:a63:43c2:: with SMTP id q185mr3306481pga.280.1559214404071;
        Thu, 30 May 2019 04:06:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559214404; cv=none;
        d=google.com; s=arc-20160816;
        b=i0hzP5dfEMIwS/+8FF2MuWdyTgrCspoADp9UuL8aaRNB6RDUjfKi+JRXJyCdvOsV2Y
         Hf2b0gNQN+JxqWBwnWJbzqW8b8aVv5XzFJPO1SnJX+lloFwrGok8bWAa1NsoK8A24oYH
         98vtxJomzn+J0Sz06Ljs36GtpDIWj+7678CFMEwW2Et/u5Qj5cl0Fz+5A5iVKkw5aTL4
         rY51yVMtZvJPtBKyldOKUixSDRgdNWs0KMtQaamVfuBMqDgVnLTzDTyxwLXSgvkCGRre
         +zX5HCBJPvBu/nnKsKx50uRtaK8RaWEbu1vGGArU6LbY8XP7r+B0XsPryYpvkW65QbGP
         mJpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=XWSZAD9Y6uBVo7L5n2t8Ehyy7C5gbqMnRx8yZh9FlDg=;
        b=NRfzdmnAy/8gO//jfDnnlkBrBTaQUQ5lkswRoGDxSKGeIMAkXbCjvWbILdhfaZaZbH
         rmUVyAts+Rl/aM9Z/YCsjj26d0P0PfPPewno1dr/CCKXqYOBr6OncbilqrPEOKc4uqjl
         VS8/AEWTseML9UdhMOxX5/McrumTOj/NlVts5T/T30SqwpMZ1AsmWgOPGG7NMCEgiCIs
         NDEEI/NuLKqGbJg2OYgkOYRm8I00VTW1sym2oOCAes1qwZ775dW+4gvE5zMvo3MsJNC7
         Q1aY/+q1uJYqd3zgUdWKa6UHNw7lqcxR0AN4Xx9izidE4o7jC0s4/ztbOINqmIwBy9P2
         5WUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KW9gnXpS;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d24si3014868pgk.106.2019.05.30.04.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 May 2019 04:06:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=KW9gnXpS;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=XWSZAD9Y6uBVo7L5n2t8Ehyy7C5gbqMnRx8yZh9FlDg=; b=KW9gnXpShROlZkddwXNzmFYlO
	fmIqAbGM2SAjmXl9zY3TDwFtQnfiDLggLdshi5XIGPQxS3N2b9fI8eNDGA5CdBld4QgdGWer5Q9Ir
	58plIdYsqK7CE2ULlzaf6e3ndrG50anFfSpiL1RUGymu0dFCqQYpDTA9rKtBgtDQFojobJPChdzfh
	MzHtjhsFqDNt+GjziZ1c5QrQMMbip4vZ+Zfak6M+Hs4u1QJVcpRPLOPMswU88cCWHQw/XIU3x1t9u
	QHvDrd9yzlNEjQ5Cs6u2sQB4QLtEFYrUHNmUW7XL7WXMfwfRqZkB5YqUhHS/1U//ulgnX74EIJ6o3
	ZQ2g4WdDw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWItL-0006m3-ND; Thu, 30 May 2019 11:06:39 +0000
Date: Thu, 30 May 2019 04:06:39 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org, sparclinux@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
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
	"David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] mm: Generalize notify_page_fault()
Message-ID: <20190530110639.GC23461@bombadil.infradead.org>
References: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1559195713-6956-1-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 30, 2019 at 11:25:13AM +0530, Anshuman Khandual wrote:
> Similar notify_page_fault() definitions are being used by architectures
> duplicating much of the same code. This attempts to unify them into a
> single implementation, generalize it and then move it to a common place.
> kprobes_built_in() can detect CONFIG_KPROBES, hence notify_page_fault()
> must not be wrapped again within CONFIG_KPROBES. Trap number argument can

This is a funny quirk of the English language.  "must not" means "is not
allowed to be", not "does not have to be".

> @@ -141,6 +142,19 @@ static int __init init_zero_pfn(void)
>  core_initcall(init_zero_pfn);
>  
>  
> +int __kprobes notify_page_fault(struct pt_regs *regs, unsigned int trap)
> +{
> +	int ret = 0;
> +
> +	if (kprobes_built_in() && !user_mode(regs)) {
> +		preempt_disable();
> +		if (kprobe_running() && kprobe_fault_handler(regs, trap))
> +			ret = 1;
> +		preempt_enable();
> +	}
> +	return ret;
> +}
> +
>  #if defined(SPLIT_RSS_COUNTING)

Comparing this to the canonical implementation (ie x86), it looks similar.

static nokprobe_inline int kprobes_fault(struct pt_regs *regs)
{
        if (!kprobes_built_in())
                return 0;
        if (user_mode(regs))
                return 0;
        /*
         * To be potentially processing a kprobe fault and to be allowed to call
         * kprobe_running(), we have to be non-preemptible.
         */
        if (preemptible())
                return 0;
        if (!kprobe_running())
                return 0;
        return kprobe_fault_handler(regs, X86_TRAP_PF);
}

The two handle preemption differently.  Why is x86 wrong and this one
correct?

