Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75BA8C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:14:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3622420880
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 16:14:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=alien8.de header.i=@alien8.de header.b="Ji8ztF0K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3622420880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=alien8.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A57188E0024; Wed, 20 Feb 2019 11:14:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A07408E0002; Wed, 20 Feb 2019 11:14:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CFAA8E0024; Wed, 20 Feb 2019 11:14:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32D3E8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 11:14:17 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id y1so8648787wrh.21
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 08:14:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=va5wQs9EKQ1GeiZlKtwOOE8k4i30bqMSIDq6ZHKsbjU=;
        b=eGLOegWR6Wh6TsFPIOZIwTXZHyJMW1pQFIGmt5igsS1CPRTGQNr6CFGsNxxPEpdhMg
         p1yX54XCjhn1t3s8npEGmzq/KpKyjKym7NVfWLAHXKbVNpL2KvU+cHhSM/6I32dkvfTh
         vZc9BwEO3bH/B2oSGYY1TwD+piIeTqEZcou9X7aNObimuHzyWwXL3xL0HkuAIkykqoMo
         X9Uvq0jY3FRz2D6LrUMZ6udE7DqDJW7r7GUI0jAEKY66reJQb7FThLeTrQMdeNHCxx5t
         DXj4KpRuhL/P5bAVqLZ2MTz9rwqWhJ/BQK+WdGZgKTMgaXMm/uUdaRwSrOcPx+uPZ9i0
         Xj3A==
X-Gm-Message-State: AHQUAua9h4yF6BIb2oeLzInoAmsZ/Phz97v4aY50QbkQXP85adwiM7VQ
	WiL9aCmR56z8XFbkAr7/qlP4fOnb7Z97MUrhQRvPusUiPK13Ha5jxg9W1WP7AjKsKB2/iAqv8jA
	CcPBbGJNCsk86tAUByLsnpYhg204/EamNKCNifeN5R1rKfQYyOLopA6CKp1cQ8b+NVw==
X-Received: by 2002:a1c:4044:: with SMTP id n65mr7430562wma.85.1550679256748;
        Wed, 20 Feb 2019 08:14:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaikV2HN6CpjGP5dctmPf6dDeo55TlEKdwycnXtFxrxiF0plRnZgGR/GYrks08sNsNmLvL7
X-Received: by 2002:a1c:4044:: with SMTP id n65mr7430503wma.85.1550679255831;
        Wed, 20 Feb 2019 08:14:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550679255; cv=none;
        d=google.com; s=arc-20160816;
        b=KoNvqhP1eu9soEN51SIUjkY7Rn21plBcLPl4vJL5Ay72GAEqbVQ1+eW80xsgEx9UId
         OtzUKcYyIt2HnWQpFJSLXVzbkkXxNOI1Xsuu5WAeLaSRfvNyQ4H/zPrefMz0tsTxCb5q
         pMJGKzxQ8JHhCT7G2ajkv3VQiL/pUpgeetksoj89oxgyAZtq8TkwouuzTsEVeGQjeF65
         BCPRw3dKJLHis528CM3ymn9BoCInYKAh8qruAz32gMyNY0bOdYjRdwrvYhqjISgYvyZm
         cpG85tzhij1o5xySY0Hw/JONqFlhT+bEov4a6hDL4KhbywZI9pz9NpNCA0j/sZNkrIGx
         gVCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=va5wQs9EKQ1GeiZlKtwOOE8k4i30bqMSIDq6ZHKsbjU=;
        b=EvB+3Mp1b2ECGzCbKOsOnDQ6h6ySR1qC9Yss6GMCoyv+NsF0roak9M+nnOwv79basJ
         4xKWX9W1Zu7q8cRYrLQGjRAMfvmICIoNjWPNSSqkTtTWaw6bneeaUx8rrCUMCWBhnO+t
         vA1iPICKVH++etPissbnIQ+DHNb+WOAMuHpAuP5ohTjKvOr+G27hUN2FSnWgKgaqh6MG
         +iAk7Bjk8AKpOGbp4fLKmtV9+xhjToxY8o5Dsy3P5QlyL399cdqR6h2Z1b6Oohu0Eemk
         RiJUEm7OoVyaneXCR5444KzlqhudrBUY1V5rfTZtoFCNM954S3tQ5s5mkxy+3513HWPe
         GU2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=Ji8ztF0K;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTPS id 71si14044826wrl.91.2019.02.20.08.14.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 08:14:15 -0800 (PST)
Received-SPF: pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) client-ip=2a01:4f8:190:11c2::b:1457;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@alien8.de header.s=dkim header.b=Ji8ztF0K;
       spf=pass (google.com: domain of bp@alien8.de designates 2a01:4f8:190:11c2::b:1457 as permitted sender) smtp.mailfrom=bp@alien8.de;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alien8.de
Received: from zn.tnic (p200300EC2BCB85008CB41DEE22243FB8.dip0.t-ipconnect.de [IPv6:2003:ec:2bcb:8500:8cb4:1dee:2224:3fb8])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.skyhub.de (SuperMail on ZX Spectrum 128k) with ESMTPSA id 134121EC0375;
	Wed, 20 Feb 2019 17:14:15 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=alien8.de; s=dkim;
	t=1550679255;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:in-reply-to:in-reply-to:  references:references;
	bh=va5wQs9EKQ1GeiZlKtwOOE8k4i30bqMSIDq6ZHKsbjU=;
	b=Ji8ztF0KNPSq2TKU/mqM5d2+gQ1HXE6WbaT5lXCP1LRVWqLNWzSCUO69gR5gAHxSgC+AhR
	okn8X6hUV+WjBYED3Mi862I9Uy++eBvKkda8tfepkTSZqGJiVx5Z44/C7M84NwJzvXu9MT
	LjuXADMac2mmrKkYhQGt6NMhDpwlIfo=
Date: Wed, 20 Feb 2019 17:14:12 +0100
From: Borislav Petkov <bp@alien8.de>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"linux-integrity@vger.kernel.org" <linux-integrity@vger.kernel.org>,
	"Dock, Deneen T" <deneen.t.dock@intel.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>,
	"nadav.amit@gmail.com" <nadav.amit@gmail.com>,
	"linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"kristen@linux.intel.com" <kristen@linux.intel.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"linux_dti@icloud.com" <linux_dti@icloud.com>,
	"luto@kernel.org" <luto@kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v2 15/20] vmalloc: New flags for safe vfree on special
 perms
Message-ID: <20190220161412.GE3447@zn.tnic>
References: <20190129003422.9328-1-rick.p.edgecombe@intel.com>
 <20190129003422.9328-16-rick.p.edgecombe@intel.com>
 <20190219124853.GB19514@zn.tnic>
 <b01f3fafb44c31842f897d3f62b5b9ccc1306ec5.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <b01f3fafb44c31842f897d3f62b5b9ccc1306ec5.camel@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 07:42:53PM +0000, Edgecombe, Rick P wrote:
> So to capture both of those intentions, maybe I'll slightly tweak your
> suggestion to VM_FLUSH_RESET_PERMS?

Yeah, sure, better.

VM_HAS_SPECIAL_PERMS doesn't tell me what those special permissions are
while flush and reset permissions makes a lot more sense, thx.

> I had thought it was easier to read. If its not the case, I'll change it as you
> suggest.

My logic is, the less local vars, the easier to scan the code quickly.

> Ard had expressed interest in having the set_alias_() functions for Arm, and the
> names were chosen to be arch agnostic. He didn't explicitly commit but I was
> under the impression he might create an implementation for ARM and we could
> remove this block.

Yeah, Will has those on his radar too so we should be good here.

Thx.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

