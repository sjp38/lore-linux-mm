Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC231C468C1
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:57:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54B7820833
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:57:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54B7820833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B59C46B0005; Mon, 10 Jun 2019 00:57:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE2F86B0266; Mon, 10 Jun 2019 00:57:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95B856B0269; Mon, 10 Jun 2019 00:57:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 583C36B0005
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:57:33 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q2so5042851plr.19
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:57:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=xt3OlpAeGDjW0iU+ef5NfnIlyPvuJHNQH68m7g+548c=;
        b=J+QPexDedCv9w/49vHQEWcaoT9O66MTF1X7UBEreCGIy0oWVtP4emNZ+D0nIQTmzvM
         e4c7DiDAg9reARGrkS+nhL9N3CwZ5bDUtXHzlFu7jTtyAZnUBVbrO736Eu6VYEeH/vHl
         JcIAgoab3CUrd3bpE0ftcO5VycL3LDHJG309RQAmRQxpPet6xhwgWfZt6iDQ47I/Hd17
         wI3paZEqq269uIQ1s8PCD4XL56Q2+P/UJD1gaGcwO4ru6eov+26mQzqbvHAUxiBmjXXK
         Ii7M+8nJKSGR1R7fk3f/2C33d4fyK8BTIe4EnrHQDLwwO5wi4ZdmiZdQKbh/bIm6dzwj
         ELLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV1yyioPIivSvEhsvzifibbRZbJWJbFl+qOX01pnGf9fzdLqKLv
	hZ7Dju3tqDOM2ZSlDafwV8wEanC1zwxsBaROigx29W6hYJbukV4/0M9RLDABnjnY2JdvTaMMmio
	SzLjVjQa+Z9Tq9VdhDOD6ONpBH/R5BScenrJW90TKqNV5Oq8iPlfFNvRRZOKLLVrEoA==
X-Received: by 2002:a62:7d13:: with SMTP id y19mr14240262pfc.62.1560142653034;
        Sun, 09 Jun 2019 21:57:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfbnvIFjl1kNefSoQBFTm94UHJGPRkik0sPwFAWx8DXCx3OYk8lDW25U6ixqHOmSHOH2K8
X-Received: by 2002:a62:7d13:: with SMTP id y19mr14240232pfc.62.1560142652437;
        Sun, 09 Jun 2019 21:57:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560142652; cv=none;
        d=google.com; s=arc-20160816;
        b=pGFCp5MJgpz19r9uSPWZxMHPwiiuEYFUrX2Sc7lRj+0TOIPo5mQ5CWle5nETbHmQ1R
         qMCXoXjW2xVW/Ve40HrehStTz0eE3aziB+SItXYcX/7MWdnWlnFxn0lYLsr3vURLtvNX
         qUc4B6i8sWZx5rG2bS3OXknyUt0xtHEYAYgzx/QCpVU1PJ4RtU9Z2mqtt486LVXNBK0S
         NrhcQaju88ImxRzxo5NCerTKgR+rxkGFELmRinCpqWC12198YV6DbqcnW9aIR/+BUGky
         rVqADkODAR6qw00HxitsFxurzUnMuGqJi+O0cw2ysU3UByFvGbj3qgMc23OxSveTkw9B
         VYHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=xt3OlpAeGDjW0iU+ef5NfnIlyPvuJHNQH68m7g+548c=;
        b=xzSwVlYny5EsZo/TGMBNzDbFLFigvZ446/vrWQJZO2vtR1wJCXG2rUPXCpzComHcJJ
         p9CoYVKLf1e1xWBP1z+8R/bdQg91FJunAi5fK0TXeO9cgMVkqK8i4EoNwowiOKPokDCl
         1mn7I3e1OBBLLJqF1WkcLT0GBcMhejRlJPo4XvR+kBo4iHk8q8kNwol1B38JtpmvT1B1
         8wZVSNLwIEqQhfwMepp/kfjI6lZIg2J4DRz3ha0Bp+cVEdrTTn08SAPTPXiY39ATvPSN
         XEi0BTAMsee81bIf10UzaxA0+8DM6Qd3sRUo+Ak666obTRlXQuQB7DGiDeVJkvkwWMtG
         uvug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f62si8878993plf.88.2019.06.09.21.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 21:57:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Jun 2019 21:57:31 -0700
X-ExtLoop1: 1
Received: from jinzicui-mobl.amr.corp.intel.com (HELO [10.252.132.156]) ([10.252.132.156])
  by orsmga002.jf.intel.com with ESMTP; 09 Jun 2019 21:57:30 -0700
Subject: Re: [RFC V3] mm: Generalize and rename notify_page_fault() as
 kprobe_page_fault()
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Mark Rutland <mark.rutland@arm.com>,
 Christophe Leroy <christophe.leroy@c-s.fr>,
 Stephen Rothwell <sfr@canb.auug.org.au>,
 Andrey Konovalov <andreyknvl@google.com>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Russell King <linux@armlinux.org.uk>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>,
 Fenghua Yu <fenghua.yu@intel.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 "David S. Miller" <davem@davemloft.net>, Thomas Gleixner
 <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>,
 Dave Hansen <dave.hansen@linux.intel.com>, Vineet Gupta
 <vgupta@synopsys.com>, linux-snps-arc@lists.infradead.org,
 James Hogan <jhogan@kernel.org>, linux-mips@vger.kernel.org,
 Ralf Baechle <ralf@linux-mips.org>, Paul Burton <paul.burton@mips.com>
References: <1559903655-5609-1-git-send-email-anshuman.khandual@arm.com>
 <20190607201202.GA32656@bombadil.infradead.org>
 <f1b109a3-ef4c-359c-a124-e219e84a6266@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <33c6a1cd-5c07-e623-28e5-f31f6fe30394@intel.com>
Date: Sun, 9 Jun 2019 21:57:29 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <f1b109a3-ef4c-359c-a124-e219e84a6266@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/9/19 9:34 PM, Anshuman Khandual wrote:
>> Do you really think this is easier to read?
>>
>> Why not just move the x86 version to include/linux/kprobes.h, and replace
>> the int with bool?
> Will just return bool directly without an additional variable here as suggested
> before. But for the conditional statement, I guess the proposed one here is more
> compact than the x86 one.

FWIW, I don't think "compact" is generally a good goal for code.  Being
readable is 100x more important than being compact and being un-compact
is only a problem when it hurts readability.

For a function like the one in question, having the individual return
conditions clearly commented is way more important than saving 10 lines
of code.

