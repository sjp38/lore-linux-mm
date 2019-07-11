Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A4DC742A4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 20:11:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E078F21670
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 20:11:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E078F21670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=firstfloor.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FD778E00F7; Thu, 11 Jul 2019 16:11:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AE388E00DB; Thu, 11 Jul 2019 16:11:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 376C48E00F7; Thu, 11 Jul 2019 16:11:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03BCC8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:11:46 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o16so4237210pgk.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 13:11:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=CNYn4mfrawfRjVoBj396r/+907ksiQc36lDRG03hLbE=;
        b=pSgNjkUtmaxz4jqo2ISnTVHWwegXceGJNKGtm//ulTsB96+N4/JSZ3gdPiIXEgFFYJ
         +jzrjoJiXenxriHyvSXkEWgCL4GQ2WEPt01qsuhzg7RV63eHk8Mpm60sDXTn/Ecv9dJU
         SKSUhIzpjoeyBzATp5ZFwEH1DCCtMjsmidjAWBHh2v3j3mbb9ENcfB9yKtENTSXdquE+
         CPWAcRqGevnmFj+WrBBMGrfGkVCM+jnqExEzhZ+lnI+yWFlKxDpftUDf1YrlqVvmgWDo
         /3UGXTPqYd/rhgJjRw1pB3zUi4DXIgWIBFynmqnIwmi3WAZXLPW35RfYjylwXVSlg3xW
         WSzQ==
X-Original-Authentication-Results: mx.google.com;       spf=fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.20 as permitted sender) smtp.mailfrom=andi@firstfloor.org
X-Gm-Message-State: APjAAAWQpLwEN0N4KXvQkcEl1ll7Lf+mL4EtOp2ehpCuuOQJRUnMJIxj
	1kQNVJvlFZHuVGLAJNP/h4nXgem/x2yvNw4eVZ4mXSNaIur9lLZDWTvQ4/FEGs+7YE2S41n2FGu
	xZ/KiX7MyeBLPKCeZ64CHyZeBGwzM3+642QXw4clLwhpMWAIqUU8idHoPRaqdj/k=
X-Received: by 2002:a17:902:2be8:: with SMTP id l95mr5308115plb.231.1562875905527;
        Thu, 11 Jul 2019 13:11:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBvLfEz5eJvMaqtIEjoYhhSrB1KrAccnz9ACEtYd8c3EXGNcU2gAbZjpQUWyfZaDLl6EZA
X-Received: by 2002:a17:902:2be8:: with SMTP id l95mr5308043plb.231.1562875904418;
        Thu, 11 Jul 2019 13:11:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562875904; cv=none;
        d=google.com; s=arc-20160816;
        b=x/9kXqj7wD8xX3Y9UtQl45x8u17Q0sUNxwdus+fVhHUHSYT/4bBD0YqAT/VPp3Qltm
         LCy/EZVHOt3d9GQ3UV8SFwIh3IUTYEQ3qP3dazvWXVcfrIgiSidPoILHe0v/O6A5RrDp
         5gzMiGG8CnN1SioVKQabeVijlnS/ClBS7I43vFMCT5ANJLDQeIVLdae3DxLMhNAW4oPH
         pEuKkKOdUT9mHFVl477MSxab7a6/TVge+yrexMU+L5ZbQEpt4v0OZWzO8cDp4JRfTI/Y
         x59fTVWovHR1/EVa+mvqtT8Ud1JdZRZ25kc/C72RMPs+98QXfkP4p8c4ZCJvDOVQBgIb
         /8jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=CNYn4mfrawfRjVoBj396r/+907ksiQc36lDRG03hLbE=;
        b=o9PyPR43ppw5tRODec1Ecc6pGVbjarEGVz+ZjhHTa0cHl6qn3LLtaXtp/UDr42bNx/
         Vi11yksBv4H8HV3JLSD7AnARD7Qib79bLPRFvsjdWpo32fpiSt6U2vcKXkdvdveqegyt
         Np4XKOJQvujPLJiNJz0brVvCvZhB/qxTRH0bILFFvFvmIIBiJYusHWQ563533vmOnUzJ
         uOEjFIEf4aHi5A4clIeuddPc7sIeP/iYzRrkChsVdYEgFCF22SR0wiNujuCuZ8nquhVU
         uS6Hs+MC7/8KBF+fJik13RHs8OuW6aj/N2hFNCoXO8NXOweMCzp/7ndGUtM1933hLikH
         EwWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.20 as permitted sender) smtp.mailfrom=andi@firstfloor.org
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g98si6061202pje.92.2019.07.11.13.11.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 13:11:44 -0700 (PDT)
Received-SPF: fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=fail (google.com: domain of andi@firstfloor.org does not designate 134.134.136.20 as permitted sender) smtp.mailfrom=andi@firstfloor.org
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Jul 2019 13:11:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,479,1557212400"; 
   d="scan'208";a="171342617"
Received: from tassilo.jf.intel.com (HELO tassilo.localdomain) ([10.7.201.137])
  by orsmga006.jf.intel.com with ESMTP; 11 Jul 2019 13:11:43 -0700
Received: by tassilo.localdomain (Postfix, from userid 1000)
	id 681A83007D3; Thu, 11 Jul 2019 13:11:43 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: pbonzini@redhat.com,  rkrcmar@redhat.com,  tglx@linutronix.de,  mingo@redhat.com,  bp@alien8.de,  hpa@zytor.com,  dave.hansen@linux.intel.com,  luto@kernel.org,  peterz@infradead.org,  kvm@vger.kernel.org,  x86@kernel.org,  linux-mm@kvack.org,  linux-kernel@vger.kernel.org,  konrad.wilk@oracle.com,  jan.setjeeilers@oracle.com,  liran.alon@oracle.com,  jwadams@google.com,  graf@amazon.de,  rppt@linux.vnet.ibm.com
Subject: Re: [RFC v2 02/26] mm/asi: Abort isolation on interrupt, exception and context switch
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
	<1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
Date: Thu, 11 Jul 2019 13:11:43 -0700
In-Reply-To: <1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
	(Alexandre Chartre's message of "Thu, 11 Jul 2019 16:25:14 +0200")
Message-ID: <874l3sz5z4.fsf@firstfloor.org>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Alexandre Chartre <alexandre.chartre@oracle.com> writes:
>  	jmp	paranoid_exit
> @@ -1182,6 +1196,16 @@ ENTRY(paranoid_entry)
>  	xorl	%ebx, %ebx
>  
>  1:
> +#ifdef CONFIG_ADDRESS_SPACE_ISOLATION
> +	/*
> +	 * If address space isolation is active then abort it and return
> +	 * the original kernel CR3 in %r14.
> +	 */
> +	ASI_START_ABORT_ELSE_JUMP 2f
> +	movq	%rdi, %r14
> +	ret
> +2:
> +#endif

Unless I missed it you don't map the exception stacks into ASI, so it
has likely already triple faulted at this point.

-Andi

