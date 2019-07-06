Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84B09C0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:32:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ECCE20843
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:32:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cmJgo3I5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ECCE20843
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D04776B0003; Sat,  6 Jul 2019 11:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB4408E0003; Sat,  6 Jul 2019 11:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA3DE8E0001; Sat,  6 Jul 2019 11:32:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9AAFF6B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 11:32:22 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id k21so13340808ioj.3
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 08:32:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Q/Uw5dIsHFTudDNvgVGgrJz9lD9sd+Kaa8O2sHnXsmw=;
        b=V2J1cD5OAvUh0XVx8/MXqwdQUhvz1YuZQgXwsbogYxYTbbGncfR/PTWS/IAu3NUbFi
         KHc0qAkM4jfPCK9DuzoL6DZIsUoR7r2whTmAamPJadeSbkgqW08Xlt2dLA7aW+bg7qdu
         HPe6z+6212Ni80z6BZwvjLGf2/4zT0/kPsLDs33pWhXTlc4CFOZtF/SimEgJIyFmMDpA
         qYWEWn8Ya2dcYJW+iD95LUc3SAwwDWL+D/Go9ExMsft074HLp13IACTp0Dw2eD6THtdJ
         piOvMmIfG04rPcbNTEW3IYtLQCSs2Jw3e6teY9bQxIpxhSbyDQ1VR4jVINwNiqbrpe/l
         mpJQ==
X-Gm-Message-State: APjAAAVcbtSTtek+8oeJF41By+QnqH/6djr2T7qpYZfgnYHqe3/3HFdA
	tgr3AWak1Jtdy822qBY6K7q8ZJ4hHXYxWLEzm/mOFmK1xJvFSdXIBv4qDzWRs21lTeeCsX4ny3t
	zNRkH/xTo/CQlkOtMcgsOxMZpaMGwYYUvwn6ObwM50+rYiVVGUtRigG7gj+EM81dsjg==
X-Received: by 2002:a5e:820a:: with SMTP id l10mr9447316iom.283.1562427142424;
        Sat, 06 Jul 2019 08:32:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPYgQ7UFHhZSwMUpv7c4lmws/dFpk2zMqOuL5iGnREEOSeaJPDIQCI/YxKqnj25K6Pre+M
X-Received: by 2002:a5e:820a:: with SMTP id l10mr9447283iom.283.1562427141879;
        Sat, 06 Jul 2019 08:32:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562427141; cv=none;
        d=google.com; s=arc-20160816;
        b=lqno4WQYd/yb1wmowpAseDwmG/2AQGFa2HjFFVwFzmd478eAH2FSfSABKncXPEEHjO
         uxX8mXOJAFiLT5m/nN/6GhYSQVLoBFkyaAWm/mvbudJppWbFV1vXJcOFyMpFeWfG/aqf
         0oY6YmG0GlTy7RMtrTBCOK4au6u1l4elzXHz33lgmPOuZqh8aSYysaAiwe6GLviEOpdu
         JRS85Wj5xP+HaKy9H37EnqpX0P6kLVZvlSB9rMgIOnAugCvxGze+WVkXcLcsuJlMp/yl
         WBGmnpBEMFpyIcsjjHpfSIm2Ft9MJ7N3/IVLYC0ybVI4qtFEyBmjk06XTROFdmwDR0Pj
         q+rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Q/Uw5dIsHFTudDNvgVGgrJz9lD9sd+Kaa8O2sHnXsmw=;
        b=OeL+PDXkGGP9ca/A+m4A51TgP3qGvrFtbghCLqaYsm9TDPe4d3SZPxcH6wRCjLBN0b
         bbLKypqgr9Zb2H8Ib00Hw4O2NNlWZDiKwpCQ0IYFcL+1mnYboEvajylQF/heV/0lKmOr
         VPIU3qspVtZa4qiT/KEOZp7Zze9VufmTS/XAWvn9xvh7YrUvF3KeBD0Mrd8mX6z87OaY
         Jud7NSedka2CtCQOXG996edQCJEZCDdKhfvoC/79DFjF40eBQhnEv4ujO/MFaimEUam7
         DUmZuzJQaGlltKRphx9mKMPmtJWipByYOcJl8b6L9wCByRDq6o4ypBciNLoRoQPCY2uR
         q2Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=cmJgo3I5;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e14si15649696ios.20.2019.07.06.08.32.21
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 06 Jul 2019 08:32:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=cmJgo3I5;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Q/Uw5dIsHFTudDNvgVGgrJz9lD9sd+Kaa8O2sHnXsmw=; b=cmJgo3I5TzZVReZe18xORp8oxP
	VXY4xNfqtX2mnXvoN/6ZEpFJNjR9dviNSO7LpOBOvXrbcTA9HelIkGn2GEfsOomvE11BQ3jWcK4Ng
	igvVajyszClx57PmbMHN/yeS3vriO30/nDt2jk/M11usjctitA7eVWBJPGE7eglxLDy738JqLqM93
	E0jRy/EdKzzOr0Vie7pv4vCQjYbGTyIVL23duY59LFdKPtiT0J7mmWXCWTUTtsQMGuCsaS2jxcHsC
	W+5Gys7PPNHitASuKSwYx5KvL32myUym+NFbDVrTIne5ykAP5n0trGhDacbe/h+B2QN17BBiPExzb
	5edt6X1w==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjmfQ-00017D-Aw; Sat, 06 Jul 2019 15:32:00 +0000
Subject: Re: [PATCH v5 08/12] S.A.R.A.: trampoline emulation
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
 <1562410493-8661-9-git-send-email-s.mesoraca16@gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <28431b5d-c34c-a54b-acbf-70d1ae635e0d@infradead.org>
Date: Sat, 6 Jul 2019 08:31:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1562410493-8661-9-git-send-email-s.mesoraca16@gmail.com>
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
> index 54a96e0..458e0e8 100644
> --- a/security/sara/Kconfig
> +++ b/security/sara/Kconfig
> @@ -117,6 +117,24 @@ choice
>  		  Documentation/admin-guide/LSM/SARA.rst.
>  endchoice
>  
> +config SECURITY_SARA_WXPROT_EMUTRAMP
> +	bool "Enable emulation for some types of trampolines"
> +	depends on SECURITY_SARA_WXPROT
> +	depends on ARCH_HAS_LSM_PAGEFAULT
> +	depends on X86
> +	default y
> +	help
> +	  Some programs and libraries need to execute special small code
> +	  snippets from non-executable memory pages.
> +	  Most notable examples are the GCC and libffi trampolines.
> +	  This features make it possible to execute those trampolines even

	  This feature makes it possible

> +	  if they reside in non-executable memory pages.
> +	  This features need to be enabled on a per-executable basis

	  This feature needs to be

> +	  via user-space utilities.
> +	  See Documentation/admin-guide/LSM/SARA.rst. for further information.
> +
> +	  If unsure, answer y.
> +
>  config SECURITY_SARA_WXPROT_DISABLED
>  	bool "WX protection will be disabled at boot."
>  	depends on SECURITY_SARA_WXPROT


-- 
~Randy

