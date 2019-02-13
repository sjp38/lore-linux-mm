Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07959C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:30:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7929222CF
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:30:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7929222CF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 434BD8E0002; Wed, 13 Feb 2019 14:30:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40C9F8E0001; Wed, 13 Feb 2019 14:30:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2FAD58E0002; Wed, 13 Feb 2019 14:30:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E36958E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:30:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id v82so2663895pfj.9
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:30:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=woaR04FDtg8vErGn+oPZe/OJJj+WlynLwKDadgZHlic=;
        b=dp6PIq+dm0h5lF/6qmSj8C6S/JB2gAX9puKH2IgdQ3WGmS+UbCS3zIPEP68vmDp3u2
         310gbFWgh8jfhaXOAOzDlRBqs5Jo2hFxW5erQMxvCo2caWfdECZkEntTsRrQNsuOtPRk
         FxIVIt82s0ZjmVKvUQYfCdtBfDpOJxG323hJqaj2SXsUgHCOYYu6oFxhUcSIF7H+rP65
         1x+AeWEjdw+MX6mkqi9q4YZ+bqHq4tql/MlCS4ac3cVt7yI99yOJO0pOP3fHagjY2knW
         C34t65ZaUlOlZH3Tz9BHiqwjFmNKacFM6cO6kweO1ezXd0gPlllU0kwtd7ZJrkiG0Z7n
         jppg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubFTRJdiG704ILk+5KnvrMD0/HVKYrmOEw7Xjtn1N7aY3MbY4ns
	4Dt7klsZHstAzu6Vrrfed51El+7O/iBOsOZX0O/5w0uHYW0NOh291A5LqVgOa5ifjnmsL6v1VGh
	rSbeNL886NMW6bnpzQSZ5eZBnwRA/4ab9UesEyZa/MGQLLDSUr+3zhWYnCxk0XubzOw==
X-Received: by 2002:a63:1753:: with SMTP id 19mr1836971pgx.439.1550086216592;
        Wed, 13 Feb 2019 11:30:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbcJDB+5ZgPdRNc7Ey5vIzKMv5aFTzUa+YlvXHUlmrO38QjoDOHQqMrzl7EGQzoSF48qgzv
X-Received: by 2002:a63:1753:: with SMTP id 19mr1836918pgx.439.1550086215893;
        Wed, 13 Feb 2019 11:30:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550086215; cv=none;
        d=google.com; s=arc-20160816;
        b=ELmw/LFU+INhtYYl1lAWSBUQOhJa+kI4yLmgk0Z8UwA+rOq0nN3IcY5B0lURk7s2rP
         cVxwMabNFInTcgjZOLsMXS1naqkT/d2JBl05tcG42oMWGj2vlxukvrJqU0GzwRR29iX6
         Y52+ovaw/yJXQPvYrxcnKuCAYutJShMkc96UTdyw4Lx6j7O/Sz+dLmokXWkO0CMZ+R8a
         5St+lprt0NYsG3kaKS6GI5HLnTxJYiD4fd97oDXYXP5C5a7QvKQPFsIoHev69vprRWuN
         khHMtM6ooH45RhvDiKwbQ2paCZl1I+BNja9Ha/0ZTdpDc9phieyGMjnJg5CBLBZSmYJu
         WF7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:to
         :subject;
        bh=woaR04FDtg8vErGn+oPZe/OJJj+WlynLwKDadgZHlic=;
        b=lBxXeg+2nT8NGTiY1HXKYPnZP0doyE1K/UfJDH/RtJFYhYormwxy2SENK66zDe9vSv
         cRw6XVGAAwPhgjFjumgMCUOlFRhjwVlnCOeKZV12rDxTvpU68vVC+39HthrOukJRzHyB
         aNZZ3jSWbZ90ZZV/87l56W6QFCNHCjG84pn54rDLrw3o7gqsgPrvIXqTxmLtx/KgXnRT
         kF2bahogayvzU6QcBkMt7zy8WhispzVQ8uXGZZ987HoGXhZJZQHg/rck6chgOeQdp5ae
         oWOYw/09NsJr/immUhlmzN6b3EzYbZjnZp7mBzb4IXjzqHiIJ9nPMVmD32D6u9TlIYvj
         Wymg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j1si97995pgp.449.2019.02.13.11.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 11:30:15 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 11:30:13 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,366,1544515200"; 
   d="scan'208";a="143193613"
Received: from ssripath-mobl.amr.corp.intel.com (HELO [10.254.80.112]) ([10.254.80.112])
  by fmsmga002.fm.intel.com with ESMTP; 13 Feb 2019 11:30:09 -0800
Subject: Re: [PATCH v2] hugetlb: allow to free gigantic pages regardless of
 the configuration
To: Alexandre Ghiti <alex@ghiti.fr>, Vlastimil Babka <vbabka@suse.cz>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>,
 x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Mike Kravetz <mike.kravetz@oracle.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
References: <20190213192610.17265-1-alex@ghiti.fr>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <d367b5c7-eb05-6d0b-f9bf-5b3fc3f392a9@intel.com>
Date: Wed, 13 Feb 2019 11:30:11 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190213192610.17265-1-alex@ghiti.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> -#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
> +#ifdef CONFIG_COMPACTION_CORE
>  static __init int gigantic_pages_init(void)
>  {
>  	/* With compaction or CMA we can allocate gigantic pages at runtime */
> diff --git a/fs/Kconfig b/fs/Kconfig
> index ac474a61be37..8fecd3ea5563 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -207,8 +207,9 @@ config HUGETLB_PAGE
>  config MEMFD_CREATE
>  	def_bool TMPFS || HUGETLBFS
>  
> -config ARCH_HAS_GIGANTIC_PAGE
> +config COMPACTION_CORE
>  	bool
> +	default y if (MEMORY_ISOLATION && MIGRATION) || CMA

This takes a hard dependency (#if) and turns it into a Kconfig *default*
that can be overridden.  That seems like trouble.

Shouldn't it be:

config COMPACTION_CORE
	def_bool y
	depends on (MEMORY_ISOLATION && MIGRATION) || CMA

?

