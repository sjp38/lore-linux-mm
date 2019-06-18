Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C61EC31E5E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:09:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E5ADD2085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 14:09:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E5ADD2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A4F76B0005; Tue, 18 Jun 2019 10:09:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 655FB8E0002; Tue, 18 Jun 2019 10:09:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 544728E0001; Tue, 18 Jun 2019 10:09:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CD3C6B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 10:09:40 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id q6so7850263pll.22
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 07:09:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=n5Np95uwoUQwcgJ2vuK7l9WFNLZtic2B/xi1+I99n20=;
        b=DwijySCIEhtjFo6k46GyyjEBzFl+IPXB8/mP3eRw4MsqS+Wurb8Hw1eSz/zwEtqk4F
         sfnET57Gojvzarc84jHy1VWZ3ui461lmNoQQcKQZmKI/YimD4zXD8HAxWeiEs2zDycJL
         AwckIL3wyai6I+j0oMVKp3M74AolGICv8yBJRyXOW0KCe50BS8K3nbUdMpteLtT+cW0R
         WbWCNSdxil68ylBGAnMYDhtccYVo8iSww+QZwbUhxYub9YXg2IIrC9SujPEz81Iz1Uyw
         1xeSMxB61P34hauu2TyowrAS1iKQzs57ZuIBUtbP5SU/jSPihK9l7+a4REpfE0d0B9AZ
         0FZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVpuPWwZW73iaL6C86YUasL9jaYLO2xfcpmgvourcU2eaZEtLn1
	bgpm7LdVc+QqvSiVKi/k3wvQH7DMaZKL2jhQriL1UvJynyyhkrkKMKtYWCfvGpXdceVWItA8OUJ
	dHDltPQTVgUG7VZwg6VxlcFrL+H2KrCkNJv7DgyYdp1CRI7PrKMA1tNRHx+DWkNzaAA==
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr2415827pjl.41.1560866979772;
        Tue, 18 Jun 2019 07:09:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYlqZIkGMQwTEyNwUGVqG7mAVx8qzWtge7eRWXhaF63hMZj3d0scCv6DSxgZ/EA2L0lZDp
X-Received: by 2002:a17:90a:7d04:: with SMTP id g4mr2415746pjl.41.1560866978820;
        Tue, 18 Jun 2019 07:09:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560866978; cv=none;
        d=google.com; s=arc-20160816;
        b=ezt9OJpMYwRsi3YLab7KjpIY+VuWILMEufcrK9qyULrFzcOS1EqFgU210MnNgIYSAF
         i17p5wR1DFELVA1J65lRzMeUiocwB2wLhFic/lgpKwv0EM86e5/+SDwmjZ65abVpllu6
         qQRCyDk9hKenUkQzt/DcCt1SF8T+NAC6hhkdUoVtCtl1XYja1UoB2J/1QTjbqWrABed6
         fXajbtbzJhwcpsphjDO1tv0iuG3qZduC65ANdtjDp6EmlcnsDYobHs0HorZVel3UHi7E
         br+ReETGPsYv8wDtM0AexWQx65XhPalZRdE3ZU15z116ZZSA47DrqJmXjCFDjfocp1k3
         8dLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=n5Np95uwoUQwcgJ2vuK7l9WFNLZtic2B/xi1+I99n20=;
        b=Ly9UFViBu73aGedaZcHNoo/yl065apdHC0sQgvIEtDgkRN5vYECOSvSs5EXg3zZ85o
         CpXo/c0QFblFfneojfUppQwPWyfwCdp6yNM+hY49RzspCzHMT+6QFMo6uDhGNTsic4BY
         AAZKR7QHXvhGkrqmJLUzVQSsEYfkrNKNozp2A4ZvjPbE9MgYK1SckWTON5sjnnj3qZlt
         GRsZMKqaabIyqxnjhEzf33FDUmcYzTEqn4gUXgK0BzA00EQ0UmgWOE8g4xudzWPJmVok
         IJlbDmVq4iLvvTEBtb2CyvKcttXvKHjEAHBG8GqGamDdSw0U2d/83wzowbN59AiiQ/nL
         qPXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 61si13301401plr.368.2019.06.18.07.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 07:09:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 07:09:37 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,389,1557212400"; 
   d="scan'208";a="243002896"
Received: from oamaslek-mobl.amr.corp.intel.com (HELO [10.251.9.224]) ([10.251.9.224])
  by orsmga001.jf.intel.com with ESMTP; 18 Jun 2019 07:09:37 -0700
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for
 MKTME
To: Peter Zijlstra <peterz@infradead.org>,
 Kai Huang <kai.huang@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>,
 David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>,
 Jacob Pan <jacob.jun.pan@linux.intel.com>,
 Alison Schofield <alison.schofield@intel.com>, Linux-MM
 <linux-mm@kvack.org>, kvm list <kvm@vger.kernel.org>,
 keyrings@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>
References: <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
 <1560816342.5187.63.camel@linux.intel.com>
 <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
 <1560821746.5187.82.camel@linux.intel.com>
 <CALCETrUrFTFGhRMuNLxD9G9=GsR6U-THWn4AtminR_HU-nBj+Q@mail.gmail.com>
 <1560824611.5187.100.camel@linux.intel.com>
 <20190618091246.GM3436@hirez.programming.kicks-ass.net>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <2ec26c05-7c57-d0e0-a628-94d581b96b63@intel.com>
Date: Tue, 18 Jun 2019 07:09:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190618091246.GM3436@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/18/19 2:12 AM, Peter Zijlstra wrote:
> On Tue, Jun 18, 2019 at 02:23:31PM +1200, Kai Huang wrote:
>> Assuming I am understanding the context correctly, yes from this perspective it seems having
>> sys_encrypt is annoying, and having ENCRYPT_ME should be better. But Dave said "nobody is going to
>> do what you suggest in the ptr1/ptr2 example"? 
> 
> You have to phrase that as: 'nobody who knows what he's doing is going
> to do that', which leaves lots of people and fuzzers.
> 
> Murphy states that if it is possible, someone _will_ do it. And this
> being something that causes severe data corruption on persistent
> storage,...

I actually think it's not a big deal at all to avoid the corruption that
would occur if it were allowed.  But, if you're even asking to map the
same data with two different keys, you're *asking* for data corruption.
 What we're doing here is continuing to  preserve cache coherency and
ensuring an early failure.

We'd need two rules:
1. A page must not be faulted into a VMA if the page's page_keyid()
   is not consistent with the VMA's
2. Upon changing the VMA's KeyID, all underlying PTEs must either be
   checked or zapped.

If the rules are broken, we SIGBUS.  Andy's suggestion has the same
basic requirements.  But, with his scheme, the error can be to the
ioctl() instead of in the form of a SIGBUS.  I guess that makes the
fuzzers' lives a bit easier.

BTW, note that we don't have any problems with the current anonymous
implementation and fork() because we zap at the encryption syscall.

