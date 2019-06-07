Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0D22C28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:08:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5864F2089E
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 08:08:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="UkJpC7dn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5864F2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C78516B000C; Fri,  7 Jun 2019 04:08:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C27896B000E; Fri,  7 Jun 2019 04:08:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3D6B6B0266; Fri,  7 Jun 2019 04:08:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9366A6B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 04:08:46 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id g142so1211191ita.6
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 01:08:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=T2+J8KOCU8D0FrF3JsY6TcG0OhfOJ0h4LqGgdXA+AZ0=;
        b=P9BL+aMzZ6OXLlT4IjLQq3qMvmn+Gm1YOrTdX8RqeXIqhg1rOJhPs8SvR8PDBT9xJK
         uBiO1KJsn4xXI4iZ4EkdjwAEFn0KMR86KqQINOeLGgWx4BZMfPvJY9FLGus/Z0++KuAF
         3BZAy+X937s95coyr8e+gBL5nd3s/3ASGj5YXCfQPBYf1yndDCaHqLKq87CEwM5llWHg
         NvjRPT4LYG9sTwi6LbcRQYwAxNzJ6QFarHniPZuO42qPWqARguH3SP4/iyy+o2HcABjx
         FC6NN5htuvCbDlGjCGHI0gLOBxV4kM/eKE2MWXLrSuR08UYIGp/7tOeZfiKHXCVYLYVQ
         +Zag==
X-Gm-Message-State: APjAAAWE+yzHMxC6a9KcPndK0YsrSUGOnQRvO9F3TkYkt54ZGmj45JT3
	fg+cSEnOynPKQYmF5+Qg+h/YzK4g5LgCf5cOvT+mmJi6mcSuYmUvDhWAseq3yWOaWuEy8sTlq95
	tLDpQDUadHnekwDpUoS6s6AD6tmXJXarMrNqZsr0/obGFAIvDtk0ojqUhGzDbAhdcUg==
X-Received: by 2002:a24:db06:: with SMTP id c6mr3632189itg.47.1559894926356;
        Fri, 07 Jun 2019 01:08:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGj1DQ8yd7IAhA259MJqZFVenuAwHCx4oFa1fKnBh9qXn5zMepQy1TdgXrq6Fv3JQOrvYG
X-Received: by 2002:a24:db06:: with SMTP id c6mr3632159itg.47.1559894925792;
        Fri, 07 Jun 2019 01:08:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559894925; cv=none;
        d=google.com; s=arc-20160816;
        b=IwS+LFkE3zxfzdkm/O/I/gvAD7JWD9d17Ghihjk/q5+Dx+qQfZkHtLy2s2lXNWRjPy
         TYzEowqxNJlQAeVQVLot37285sThmNIKcCqhuV7wugRE2+lAQFSCLnJdShYyaSt2LzDW
         iT32QLp2UOU+UOEBGAMt50N8YjMdNafsCjLhLl9p/C0KSJUf6EskI69/mJIxfY1PiEBk
         bDlYzVer+x574q87WQbsMUUTG9r2oyY+aZZfh/X/EA7hmnC8mK2vuMTjZoaU9gCbiGSI
         NmQ9OGIP6pDIFznP87vGtactYN5CsWEyJ1fiV82ykSFRXmNwtcvxFfUKjFgdjsM/V+76
         WQEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=T2+J8KOCU8D0FrF3JsY6TcG0OhfOJ0h4LqGgdXA+AZ0=;
        b=yAs9aGzmDnBRGyq4QpWp3zX1sbsLZte1cW7BQZzp4kE1sQY/L5DU5SG8RqfNQEha2t
         AHgD2L5SjS0+9WM6HMZ05UMiJdQupuGuKrrUBBRszaIHg9m8y5SIMen0eQCZ1E9nmrWz
         JaOhVfzBb3ae4Tb7esigKQ1Q3HHOtw6E++C5GiBPigozUONYeVtN5/bqjus6RcnNqkVG
         L0UbGMcrNi8Q2kCOX/okhrNWk0YjGTj8gWs8Gtq2o6C97MYhaychX6rRFCkKgmUd1pgQ
         zcS5RzxmU+cq4doVnIUxgZItA8cMMnK/IH4K1iNzM+Ra2vyFI9zpPRXyPZl+vZwP9ZLa
         mjeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=UkJpC7dn;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k195si773183itb.89.2019.06.07.01.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Jun 2019 01:08:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=UkJpC7dn;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=T2+J8KOCU8D0FrF3JsY6TcG0OhfOJ0h4LqGgdXA+AZ0=; b=UkJpC7dnl6p1BOyZG/oCTfAsK
	MCq5N2Nkf5FTQ36Pp2TRqbmVMpzuneO72NDYNJpinfN4KhVjvnSMi1SGmTI84SdmvdHpZxj3DpDlS
	l4oFrtTyTTWpHOt+Byrg8AY5dgn5Qmbsg7JVMYHaxNEm9eICXvy4+QVioPIenEOX5990R58OWw6E9
	2lwQs5Ub8efcU5WDrtjgCEPFkcvXjXaa/0b1m2HwGBwS+mMml6ETFXG7W9uC0T+hOFNtLMQCLXjLj
	k5K1dJQurVg95jcGZz8Uj7b4tJk14Th7RH7f6n09w9n57k5QK+4OXn9HCEx2swAN+cRTvcI0oKEpY
	im/2HQGTg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hZ9vO-0006Rr-2q; Fri, 07 Jun 2019 08:08:34 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id B1910202CD6B2; Fri,  7 Jun 2019 10:08:32 +0200 (CEST)
Date: Fri, 7 Jun 2019 10:08:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
Message-ID: <20190607080832.GT3419@hirez.programming.kicks-ass.net>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-4-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606200926.4029-4-yu-cheng.yu@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 01:09:15PM -0700, Yu-cheng Yu wrote:
> Indirect Branch Tracking (IBT) provides an optional legacy code bitmap
> that allows execution of legacy, non-IBT compatible library by an
> IBT-enabled application.  When set, each bit in the bitmap indicates
> one page of legacy code.
> 
> The bitmap is allocated and setup from the application.

> +int cet_setup_ibt_bitmap(unsigned long bitmap, unsigned long size)
> +{
> +	u64 r;
> +
> +	if (!current->thread.cet.ibt_enabled)
> +		return -EINVAL;
> +
> +	if (!PAGE_ALIGNED(bitmap) || (size > TASK_SIZE_MAX))
> +		return -EINVAL;
> +
> +	current->thread.cet.ibt_bitmap_addr = bitmap;
> +	current->thread.cet.ibt_bitmap_size = size;
> +
> +	/*
> +	 * Turn on IBT legacy bitmap.
> +	 */
> +	modify_fpu_regs_begin();
> +	rdmsrl(MSR_IA32_U_CET, r);
> +	r |= (MSR_IA32_CET_LEG_IW_EN | bitmap);
> +	wrmsrl(MSR_IA32_U_CET, r);
> +	modify_fpu_regs_end();
> +
> +	return 0;
> +}

So you just program a random user supplied address into the hardware.
What happens if there's not actually anything at that address or the
user munmap()s the data after doing this?

