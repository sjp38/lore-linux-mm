Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F82CC0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A443920856
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:39:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="zk1xeLOy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A443920856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13F806B0003; Sat,  6 Jul 2019 11:39:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C8E28E0003; Sat,  6 Jul 2019 11:39:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED33B8E0001; Sat,  6 Jul 2019 11:39:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9FF1F6B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 11:39:05 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b6so5296641wrp.21
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 08:39:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7TQwAzn0J5EXLc+BbiWf8v/R95Wdjh5+dxrOc78SyBQ=;
        b=bKo9R9sum4UNECOz3ubstM0GE0FYa5uIi8uBDulrk4GabgOQofwy2/MmFzeu3W/vsS
         bFTHgFdvs62o+4+t6ZW8/2FDYxti718p7lhInXAWfY8T5tSpaAgyXCdQfCZoX4oVRy+T
         +0RD1n58VrUH240gX8QRmmICcjpgr3AXmbAjyQuF23MZt0Aekv09h41xXUq5eaKagGyO
         ugqak371eqSIx+eb5H4HCkBU9reaI2dvBLm+q2A9I3eKYdWxRI/Fo4j0zE1+lJQ67Ua3
         DRQ7ZeXqJqVdbagFIUDgk5T13yi5TjmanhVm+efhLGe6HWQgvI13htaVWRUZlFpEJ7Tx
         6Vnw==
X-Gm-Message-State: APjAAAUKoUjE5kL1g6Q++B0Dn2yydDf1A63JpDv4Y00wBd3pfBmWcF3v
	OJJRinhFd04s8gRcJAwJwHmNgltYhC6WHXrBf7e5+LMqg+yONCB7EI9AqabM2cuWWKVjXnprU8E
	EyPJx5ynabo31QzKjQnXc8l1g91n55R162cBx9sEfsStmqdU/y0uAUCHdwdBpFTEYYA==
X-Received: by 2002:a1c:9d53:: with SMTP id g80mr8458888wme.103.1562427545046;
        Sat, 06 Jul 2019 08:39:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9ItBLSTwD7d/zTYHdIuZOLB4lAQ10ulgRdXDcpfG6X+/NCV5ZfoHnCFfpYM/oyyGrITAT
X-Received: by 2002:a1c:9d53:: with SMTP id g80mr8458865wme.103.1562427544226;
        Sat, 06 Jul 2019 08:39:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562427544; cv=none;
        d=google.com; s=arc-20160816;
        b=OSPM6RKiV1PURCAOlNd5hKI7U6fRGyGZHbqVIHThPFwab7X30xML7cJGX1rekUid+I
         NKpZAxXYU/tK4KyA3pN8FofHYMvrRxIzrcJ/X2vFRvBHG9hSFygvqmJI0HbKwvxPRKEj
         EYZy76tEsPtZo/+ToBH/U+03MPG4LaxG0Jbgik4xIDCw2bir1hqkh0AUFYWOmqUdqX/N
         w6v06UphP6qJQ1P7v6KhUzD/7e57rbmv3nqCKllH0kBsYxVi49h3jOwFzTZJDuxXLUuo
         jFTezikl6Qma6IFctRIRgGA7VkED0DqYPyEO1+YYMMjxo9Bcc8tAV9lu1SoiVJea4pN/
         Xmnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=7TQwAzn0J5EXLc+BbiWf8v/R95Wdjh5+dxrOc78SyBQ=;
        b=TbYa7EGNmb4k7xkbq9fUcVnL07cStUqC8udMkueKJI+3EX/5581e8JWK7nbGw9BsQB
         qs8l4Q1j8jKdOBDpNh/cVJr5ZwJYhDieJBYHnAlECkK7dAsVIbGmKELbGHDGIjjVf/tQ
         heqVAaZO5iFoUAvLZTfCwm8siR/Y6AyYMTY8e2nvNzTIzGTyauOo8hqWKTzbacoyvQ2X
         /viYD9QvMXKy4NycyRedv1M3w3CmtDBCz4RUksWLt2sfoqBZ5J3lv+J9F3EtZQnVtIBW
         lsGIzxA8IVw3WrpJWEeFfKMT2dxYQ28BIgGoJ4Ds7unsayPe21cI8amO71LZWSXe7Z1z
         FewA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=zk1xeLOy;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id t4si7704490wmt.14.2019.07.06.08.39.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 06 Jul 2019 08:39:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=zk1xeLOy;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=7TQwAzn0J5EXLc+BbiWf8v/R95Wdjh5+dxrOc78SyBQ=; b=zk1xeLOyXqj8CUdxCMPGb5v4O6
	7hsXykVY8BfzjRyGPWIiYyGMnVxn3mN2H9t48yfsDQr2b0t2KsCupiuMaoV3qjEeKnUyIetD1fE5E
	1Ku0V7rf+tU/MCbArHAkSOmlGc/Zj0/pjuIp/N7qSWFohv/1Pkif4/dN2NQDN2MymGp3euW92NUIA
	Mc7fJimKvdws8bLQFAm3bwYo9fNSCQAO+C59n98FSTLsk4D/TjJWDbVVoGYXBWP/337wSBHKhUnQL
	3AFwOHHBGkPtXaEz8acl3Bi2LmaUZZCeImDaFYoBAUz0uGii+Nb43uWaZlXeqb7euZPHBZ9uKr4+7
	n448kLpw==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjmlu-0001Aq-7U; Sat, 06 Jul 2019 15:38:42 +0000
Subject: Re: [PATCH v5 06/12] S.A.R.A.: WX protection
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>, linux-kernel@vger.kernel.org
Cc: kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Brad Spengler <spender@grsecurity.net>,
 Casey Schaufler <casey@schaufler-ca.com>,
 Christoph Hellwig <hch@infradead.org>,
 James Morris <james.l.morris@oracle.com>, Jann Horn <jannh@google.com>,
 Kees Cook <keescook@chromium.org>, PaX Team <pageexec@freemail.hu>,
 "Serge E. Hallyn" <serge@hallyn.com>, Thomas Gleixner <tglx@linutronix.de>
References: <1562410493-8661-1-git-send-email-s.mesoraca16@gmail.com>
 <1562410493-8661-7-git-send-email-s.mesoraca16@gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <fcbf55e9-78dc-fb1a-e893-4fea8ebdc202@infradead.org>
Date: Sat, 6 Jul 2019 08:38:39 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1562410493-8661-7-git-send-email-s.mesoraca16@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/6/19 3:54 AM, Salvatore Mesoraca wrote:
> diff --git a/security/sara/Kconfig b/security/sara/Kconfig
> index b98cf27..54a96e0 100644
> --- a/security/sara/Kconfig
> +++ b/security/sara/Kconfig
> @@ -60,3 +60,77 @@ config SECURITY_SARA_NO_RUNTIME_ENABLE
>  
>  	  If unsure, answer Y.
>  
> +config SECURITY_SARA_WXPROT
> +	bool "WX Protection: W^X and W!->X protections"
> +	depends on SECURITY_SARA
> +	default y
> +	help
> +	  WX Protection aims to improve user-space programs security by applying:
> +	    - W^X memory restriction
> +	    - W!->X (once writable never executable) mprotect restriction
> +	    - Executable MMAP prevention
> +	  See Documentation/admin-guide/LSM/SARA.rst. for further information.

	                                        .rst for further information.

> +
> +	  If unsure, answer Y.
> +
> +choice
> +	prompt "Default action for W^X and W!->X protections"
> +	depends on SECURITY_SARA
> +	depends on SECURITY_SARA_WXPROT
> +	default SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_COMPLAIN_VERBOSE
> +
> +        help

Use tab instead of spaces for indentation above.

> +	  Choose the default behaviour of WX Protection when no config
> +	  rule matches or no rule is loaded.
> +	  For further information on available flags and their meaning
> +	  see Documentation/admin-guide/LSM/SARA.rst.
> +
> +	config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_COMPLAIN_VERBOSE
> +		bool "Protections enabled but not enforced."
> +		help
> +		  All features enabled except "Executable MMAP prevention",
> +		  verbose reporting, but no actual enforce: it just complains.
> +		  Its numeric value is 0x3f, for more information see
> +		  Documentation/admin-guide/LSM/SARA.rst.
> +
> +        config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE_VERBOSE
> +		bool "Full protection, verbose."
> +		help
> +		  All features enabled except "Executable MMAP prevention".
> +		  The enabled features will be enforced with verbose reporting.
> +		  Its numeric value is 0x2f, for more information see
> +		  Documentation/admin-guide/LSM/SARA.rst.
> +
> +        config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE
> +		bool "Full protection, quiet."
> +		help
> +		  All features enabled except "Executable MMAP prevention".
> +		  The enabled features will be enforced quietly.
> +		  Its numeric value is 0xf, for more information see
> +		  Documentation/admin-guide/LSM/SARA.rst.
> +
> +	config SECURITY_SARA_WXPROT_DEFAULT_FLAGS_NONE
> +		bool "No protection at all."
> +		help
> +		  All features disabled.
> +		  Its numeric value is 0, for more information see
> +		  Documentation/admin-guide/LSM/SARA.rst.
> +endchoice
> +
> +config SECURITY_SARA_WXPROT_DISABLED
> +	bool "WX protection will be disabled at boot."
> +	depends on SECURITY_SARA_WXPROT
> +	default n

Omit "default n" please.

> +	help
> +	  If you say Y here WX protection won't be enabled at startup. You can
> +	  override this option via user-space utilities or at boot time via
> +	  "sara.wxprot_enabled=[0|1]" kernel parameter.
> +
> +	  If unsure, answer N.
> +
> +config SECURITY_SARA_WXPROT_DEFAULT_FLAGS
> +	hex
> +	default "0x3f" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_COMPLAIN_VERBOSE
> +	default "0x2f" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE_VERBOSE
> +	default "0xf" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_ALL_ENFORCE
> +	default "0" if SECURITY_SARA_WXPROT_DEFAULT_FLAGS_NONE


-- 
~Randy

