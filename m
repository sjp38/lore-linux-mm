Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	GAPPY_SUBJECT,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BDC1C0650E
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:30:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAAD720838
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 15:30:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="FVfMkcgg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAAD720838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 627DA6B0003; Sat,  6 Jul 2019 11:30:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B1438E0003; Sat,  6 Jul 2019 11:30:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 453AD8E0001; Sat,  6 Jul 2019 11:30:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25D2E6B0003
	for <linux-mm@kvack.org>; Sat,  6 Jul 2019 11:30:08 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id v3so6794081ios.4
        for <linux-mm@kvack.org>; Sat, 06 Jul 2019 08:30:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=R5T3JdF3uAoxSggzlvhNs2X88sgTBZ7bfNPEjr5/PdE=;
        b=UN9lBm0EdblsIboX62hguzolWTHCrB2ArtVx8QoIq/ybcqWFTr0KOcoCxzOdip66nn
         YttUiwHMiIBCSLbosafaOk+5EWGxtPfg9VOQchnBWak8jOFlZ77Cm2d9WtkX4MTv/zyb
         mKVNQXz5Zo/cFuJ1ZwplvS6BQh8wDnZQ3j/5g0NnHtfHl1SWom2owVaaVkbpWeYqae7x
         q26n58l2Nu155hFA3GOkLKOeH/Gv4RoeSYuP89jk59AK7/CvtVWzjAa8cS1cRfGvAjOJ
         NOUPit86AWI2gWBIRILX8u7CPKZfFnz0dLmPaPRDUqcyde/B7qggC76adwM/fYrNySQQ
         DAWA==
X-Gm-Message-State: APjAAAWwiE5HAzVe2tizaVII+U5fYCO9PGXnmgLINswivwc8+3kzYwPX
	zwsO/Pz8vwDI6VkDyS9U4XZHzCBtfz25Tf71SkKwFbxPb0d6Ud5Sn+wFK0UIk/rS0eG7XYwqM42
	2BUh0z4pn3Xy9mNwdU1XLtHrAyKDKA1LurnsphhTWOGM7HP1zL4055t/FYnmpQNHHfA==
X-Received: by 2002:a5d:94d7:: with SMTP id y23mr10058531ior.296.1562427007874;
        Sat, 06 Jul 2019 08:30:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0tLQTbYygAdk+2bAc2U2mjueuAIMc6M0sJYd9Oroj2MoudgrmWafyLf7afvfTPCk1aP9r
X-Received: by 2002:a5d:94d7:: with SMTP id y23mr10058487ior.296.1562427007090;
        Sat, 06 Jul 2019 08:30:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562427007; cv=none;
        d=google.com; s=arc-20160816;
        b=Z3U3/OuxXnmxEvsh+SrImLkBhnle8VdJyeoF7XzAFHnntP2/97sr4YpvR+xVgSSiol
         wPGrPGn+HKHiqmaexql8dpHrEbbzYPFHTijFRkODrBZkzTurKcqzUP7BzQa//NpORKQ8
         piCqcEszQ5JytTy6NHg/cOgF6qTUVVqa4xv7d9rQEfENXLNcOlgV8aJu94qdNDTB20qr
         PGZAsYTvLGKVYbyw1hzm0Qf6VYsiKsM2Q3gOYJPiXFf0PXV+L/xSEKCUMK28C3KOPeOo
         8FA1KcoiKF3/3WjVF/obpcDNDCdf3UhpZgM5Z3QRPsfIQw9v9SQMaO5ZwSLK0dUbIVvL
         26Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=R5T3JdF3uAoxSggzlvhNs2X88sgTBZ7bfNPEjr5/PdE=;
        b=uiG7ytHIvGWGa9I0/RK1+GgCCQq+xDUN3hWagp1qPszLwhoFNOx7B05n/3ZARaSyCR
         YG2QUVF4hyUO5d/jKxDq5AKfm8U1e8ZMhrYyjAZOQItuRYpPoLBWhbMsky3nMVm9m4UE
         m1RKhpF00IJW7ApnPjvury1dOkiroY7DB+S1/jdneLhfLZbC9NeZo6tM1vvniCCOGHdg
         GbOh85UOX/BRfwDKSyakDAU/ntd+g2yKWGpoMfYsK6ZjW92lDsY/QIPXNYEblrSkpXT2
         DkG/+8dNMDNjjlbz9MDaaYWsCjUlNblDFk80Iyo1ykEGzPLNQvGzMTK7ezV3liGoB0f5
         GqaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=FVfMkcgg;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id p13si16155576ioh.18.2019.07.06.08.30.06
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 06 Jul 2019 08:30:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=FVfMkcgg;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=R5T3JdF3uAoxSggzlvhNs2X88sgTBZ7bfNPEjr5/PdE=; b=FVfMkcggaArI6Rrc6O+/xTAlkz
	rdcq0dibJ5ZhFhfnlrZfRI4O7PCUETe4XxNS+sPGXlKZZhKmJrubnyzs3KpZV2acwXKXoaaPNL3NK
	YxOrfw10/Tu5j/fST3C0r9bS+RFzCcpbp2EvNY0NJMB7Hst0+6V/g+QcNi7NT9m3Dj/KoyWiF568i
	mP5sj1aDAYlF85pd9UNKMGjKJsKutGTc6MpknFrzOvLcMGpjeCxV++nNHz0sNB6yv+sNAI8YdLfRz
	oLAc0Jek9i95iKaZN+OoAFxWqlFDw0Ar4L2KzLdHRXTwh6j2NC3S5IxWPWUT7GG1JuS73FwiVgdbo
	f8WNQGUg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=midway.dunlab)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hjmcu-00015N-Sh; Sat, 06 Jul 2019 15:29:25 +0000
Subject: Re: [PATCH v5 02/12] S.A.R.A.: create framework
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
 <1562410493-8661-3-git-send-email-s.mesoraca16@gmail.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <4d85d8f3-b6be-04fe-ea5e-de47c9441f11@infradead.org>
Date: Sat, 6 Jul 2019 08:29:22 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <1562410493-8661-3-git-send-email-s.mesoraca16@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 7/6/19 3:54 AM, Salvatore Mesoraca wrote:
> diff --git a/security/sara/Kconfig b/security/sara/Kconfig
> new file mode 100644
> index 0000000..0456220
> --- /dev/null
> +++ b/security/sara/Kconfig
> @@ -0,0 +1,40 @@
> +menuconfig SECURITY_SARA
> +	bool "S.A.R.A."
> +	depends on SECURITY
> +	select SECURITYFS
> +	default n

No need for "default n".  Drop it, please.

> +	help
> +	  This selects S.A.R.A. LSM which aims to collect heterogeneous
> +	  security measures providing a common interface to manage them.
> +	  This LSM will always be stacked with the selected primary LSM and
> +	  other stacked LSMs.
> +	  Further information can be found in
> +	  Documentation/admin-guide/LSM/SARA.rst.
> +
> +	  If unsure, answer N.
> +
> +config SECURITY_SARA_DEFAULT_DISABLED
> +	bool "S.A.R.A. will be disabled at boot."
> +	depends on SECURITY_SARA
> +	default n
> +	help
> +	  If you say Y here, S.A.R.A. will not be enabled at startup. You can
> +	  override this option at boot time via "sara.enabled=[1|0]" kernel
> +	  parameter or via user-space utilities.
> +	  This option is useful for distro kernels.
> +
> +	  If unsure, answer N.
> +
> +config SECURITY_SARA_NO_RUNTIME_ENABLE
> +	bool "S.A.R.A. can be turn on only at boot time."

	               can be turned on

> +	depends on SECURITY_SARA_DEFAULT_DISABLED
> +	default y
> +	help
> +	  By enabling this option it won't be possible to turn on S.A.R.A.
> +	  at runtime via user-space utilities. However it can still be
> +	  turned on at boot time via the "sara.enabled=1" kernel parameter.
> +	  This option is functionally equivalent to "sara.enabled=0" kernel
> +	  parameter. This option is useful for distro kernels.
> +
> +	  If unsure, answer Y.
> +


-- 
~Randy

