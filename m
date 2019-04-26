Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABEEBC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:41:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6577A2084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:41:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6577A2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E16106B0006; Fri, 26 Apr 2019 10:41:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC4A16B0008; Fri, 26 Apr 2019 10:41:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3FBD6B000A; Fri, 26 Apr 2019 10:41:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 859266B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:41:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e128so2321677pfc.22
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:41:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=j/rTDPuynCgfnIRpgqrLtGC2hZKJFqL4K7FNjfA96rw=;
        b=XpDZ8Mx0MpYk+fkOTIX229QzG+fURJSlQyv+leVbwTy5gat1D9ShB/nASuxVxR10za
         dxuAVsgzdHCFhAsuvNf5nxqcbsjvLPEYSq1XI0+IVg5+KJTDCyWyNbazb03fanH63B95
         9McIXNnCqz0nUTfVYEsTpdUOSzWfc440xw3rlHY2q/f2shXlg8iBvzqa7IBY0LR7KW8Z
         ccfGcfv8MYCOF2AvHMJIWCC5equDTQb4BZNo4szR7dyHQj41WcwWifyp1bLEzZKMK21n
         pt+mbxmiC1k9KlB79Fb4dKVjfyxWJzweSFoFSVT/Gmm7o/ogzWdeKnA+32/771t6CdJg
         9kqg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCcj08P6pjHjbk3MiXyg89cJCQyBN+n6kWA+/IV1XdVNEQb25/
	2Qtnt3lVEidNwpkHsKgTvE++TiOUwc/MCKzpZf7uTBtckUXpnswoutWR20odI6E29CToOCGz74C
	2ZgoUtRTHpPpYUImYhk1XKikZlCuphtwKQ7LB+kPsRFeSHfDGXunjHreoGlnwIYqCkA==
X-Received: by 2002:a17:902:7c90:: with SMTP id y16mr2968221pll.309.1556289673212;
        Fri, 26 Apr 2019 07:41:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuSk17U57J2vlbg+261yGMebWFTKCs6iOxuT2ZqWzlwOTwSSfRRfL7UkFxztKJ+YRDclc0
X-Received: by 2002:a17:902:7c90:: with SMTP id y16mr2968162pll.309.1556289672585;
        Fri, 26 Apr 2019 07:41:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556289672; cv=none;
        d=google.com; s=arc-20160816;
        b=KmGtAOnPRKK7ZF9JISHvmLOCUpwOLIMyEYNm07ml+qNnNBHlBX4bAbsOwN/qsmDjKn
         dv+geWgLYfBibrtYQzBMjP+BTULzyX3CH+ej3CMmJ8DUnZDLa/aTodafVahX397c3NPt
         7qQYpp9049rpE/df/xcHu9ngBjb+2aIWDD1tqUAspn94K507iX9fwSVqgXk57nG7kzpk
         +AcLUvHZ2SMnYj83fbzjgL5Qy1aeYaPPqN5R9jmo2AhlqO9m0qcHehNVPVT2EHK0DShC
         OlBPq4j6Q0tz0HaN/tsvSBqjmOKdsZ9Buwcv/zCEeHXXvcZ+s2g+T6CY4cnoxsYPAuAu
         wLZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=j/rTDPuynCgfnIRpgqrLtGC2hZKJFqL4K7FNjfA96rw=;
        b=H2U5LNTIKYFSZtCtDLWwtxLey9ylBM/pDAaCnJvu8ZXOXOkj3KuAt+Lvo9NloLAHi0
         MoJUV8sMHqFWNFk5BOOjUNXcPyIgzmHn+sGnkT0bh8IGtU27bdp/O6OXWbl4XJuGu920
         CDNX33Uvztizk+IJJEOKIAWCpcugbSaccpu0gOaLDYHFtyST0QRZ8HCf7YRXCR1Jzl4I
         jDeG7ZBaUf+z3lOze2L1d+OC8gQ/aV3Ftcv21lmf71SYqD90Nu4CtG0ud/aI/BqZQF5z
         agMNlwmViN/wTiyvIFz0s25aWc8nTnJNA1t/p/mvo55VPZwo0Gmub82JxRZjqX1Jpxlh
         IT3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f6si14467104pgm.533.2019.04.26.07.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:41:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Apr 2019 07:41:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,397,1549958400"; 
   d="scan'208";a="165330519"
Received: from gbotts-mobl.amr.corp.intel.com (HELO [10.254.86.96]) ([10.254.86.96])
  by fmsmga004.fm.intel.com with ESMTP; 26 Apr 2019 07:41:10 -0700
Subject: Re: [RFC PATCH 0/7] x86: introduce system calls addess space
 isolation
To: Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
 Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
 Dave Hansen <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
 Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, x86@kernel.org
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 mQINBE6HMP0BEADIMA3XYkQfF3dwHlj58Yjsc4E5y5G67cfbt8dvaUq2fx1lR0K9h1bOI6fC
 oAiUXvGAOxPDsB/P6UEOISPpLl5IuYsSwAeZGkdQ5g6m1xq7AlDJQZddhr/1DC/nMVa/2BoY
 2UnKuZuSBu7lgOE193+7Uks3416N2hTkyKUSNkduyoZ9F5twiBhxPJwPtn/wnch6n5RsoXsb
 ygOEDxLEsSk/7eyFycjE+btUtAWZtx+HseyaGfqkZK0Z9bT1lsaHecmB203xShwCPT49Blxz
 VOab8668QpaEOdLGhtvrVYVK7x4skyT3nGWcgDCl5/Vp3TWA4K+IofwvXzX2ON/Mj7aQwf5W
 iC+3nWC7q0uxKwwsddJ0Nu+dpA/UORQWa1NiAftEoSpk5+nUUi0WE+5DRm0H+TXKBWMGNCFn
 c6+EKg5zQaa8KqymHcOrSXNPmzJuXvDQ8uj2J8XuzCZfK4uy1+YdIr0yyEMI7mdh4KX50LO1
 pmowEqDh7dLShTOif/7UtQYrzYq9cPnjU2ZW4qd5Qz2joSGTG9eCXLz5PRe5SqHxv6ljk8mb
 ApNuY7bOXO/A7T2j5RwXIlcmssqIjBcxsRRoIbpCwWWGjkYjzYCjgsNFL6rt4OL11OUF37wL
 QcTl7fbCGv53KfKPdYD5hcbguLKi/aCccJK18ZwNjFhqr4MliQARAQABtEVEYXZpZCBDaHJp
 c3RvcGhlciBIYW5zZW4gKEludGVsIFdvcmsgQWRkcmVzcykgPGRhdmUuaGFuc2VuQGludGVs
 LmNvbT6JAjgEEwECACIFAlQ+9J0CGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEGg1
 lTBwyZKwLZUP/0dnbhDc229u2u6WtK1s1cSd9WsflGXGagkR6liJ4um3XCfYWDHvIdkHYC1t
 MNcVHFBwmQkawxsYvgO8kXT3SaFZe4ISfB4K4CL2qp4JO+nJdlFUbZI7cz/Td9z8nHjMcWYF
 IQuTsWOLs/LBMTs+ANumibtw6UkiGVD3dfHJAOPNApjVr+M0P/lVmTeP8w0uVcd2syiaU5jB
 aht9CYATn+ytFGWZnBEEQFnqcibIaOrmoBLu2b3fKJEd8Jp7NHDSIdrvrMjYynmc6sZKUqH2
 I1qOevaa8jUg7wlLJAWGfIqnu85kkqrVOkbNbk4TPub7VOqA6qG5GCNEIv6ZY7HLYd/vAkVY
 E8Plzq/NwLAuOWxvGrOl7OPuwVeR4hBDfcrNb990MFPpjGgACzAZyjdmYoMu8j3/MAEW4P0z
 F5+EYJAOZ+z212y1pchNNauehORXgjrNKsZwxwKpPY9qb84E3O9KYpwfATsqOoQ6tTgr+1BR
 CCwP712H+E9U5HJ0iibN/CDZFVPL1bRerHziuwuQuvE0qWg0+0SChFe9oq0KAwEkVs6ZDMB2
 P16MieEEQ6StQRlvy2YBv80L1TMl3T90Bo1UUn6ARXEpcbFE0/aORH/jEXcRteb+vuik5UGY
 5TsyLYdPur3TXm7XDBdmmyQVJjnJKYK9AQxj95KlXLVO38lcuQINBFRjzmoBEACyAxbvUEhd
 GDGNg0JhDdezyTdN8C9BFsdxyTLnSH31NRiyp1QtuxvcqGZjb2trDVuCbIzRrgMZLVgo3upr
 MIOx1CXEgmn23Zhh0EpdVHM8IKx9Z7V0r+rrpRWFE8/wQZngKYVi49PGoZj50ZEifEJ5qn/H
 Nsp2+Y+bTUjDdgWMATg9DiFMyv8fvoqgNsNyrrZTnSgoLzdxr89FGHZCoSoAK8gfgFHuO54B
 lI8QOfPDG9WDPJ66HCodjTlBEr/Cwq6GruxS5i2Y33YVqxvFvDa1tUtl+iJ2SWKS9kCai2DR
 3BwVONJEYSDQaven/EHMlY1q8Vln3lGPsS11vSUK3QcNJjmrgYxH5KsVsf6PNRj9mp8Z1kIG
 qjRx08+nnyStWC0gZH6NrYyS9rpqH3j+hA2WcI7De51L4Rv9pFwzp161mvtc6eC/GxaiUGuH
 BNAVP0PY0fqvIC68p3rLIAW3f97uv4ce2RSQ7LbsPsimOeCo/5vgS6YQsj83E+AipPr09Caj
 0hloj+hFoqiticNpmsxdWKoOsV0PftcQvBCCYuhKbZV9s5hjt9qn8CE86A5g5KqDf83Fxqm/
 vXKgHNFHE5zgXGZnrmaf6resQzbvJHO0Fb0CcIohzrpPaL3YepcLDoCCgElGMGQjdCcSQ+Ci
 FCRl0Bvyj1YZUql+ZkptgGjikQARAQABiQIfBBgBAgAJBQJUY85qAhsMAAoJEGg1lTBwyZKw
 l4IQAIKHs/9po4spZDFyfDjunimEhVHqlUt7ggR1Hsl/tkvTSze8pI1P6dGp2XW6AnH1iayn
 yRcoyT0ZJ+Zmm4xAH1zqKjWplzqdb/dO28qk0bPso8+1oPO8oDhLm1+tY+cOvufXkBTm+whm
 +AyNTjaCRt6aSMnA/QHVGSJ8grrTJCoACVNhnXg/R0g90g8iV8Q+IBZyDkG0tBThaDdw1B2l
 asInUTeb9EiVfL/Zjdg5VWiF9LL7iS+9hTeVdR09vThQ/DhVbCNxVk+DtyBHsjOKifrVsYep
 WpRGBIAu3bK8eXtyvrw1igWTNs2wazJ71+0z2jMzbclKAyRHKU9JdN6Hkkgr2nPb561yjcB8
 sIq1pFXKyO+nKy6SZYxOvHxCcjk2fkw6UmPU6/j/nQlj2lfOAgNVKuDLothIxzi8pndB8Jju
 KktE5HJqUUMXePkAYIxEQ0mMc8Po7tuXdejgPMwgP7x65xtfEqI0RuzbUioFltsp1jUaRwQZ
 MTsCeQDdjpgHsj+P2ZDeEKCbma4m6Ez/YWs4+zDm1X8uZDkZcfQlD9NldbKDJEXLIjYWo1PH
 hYepSffIWPyvBMBTW2W5FRjJ4vLRrJSUoEfJuPQ3vW9Y73foyo/qFoURHO48AinGPZ7PC7TF
 vUaNOTjKedrqHkaOcqB185ahG2had0xnFsDPlx5y
Message-ID: <1c12e195-1286-0136-eae5-4b392d9fe4c0@intel.com>
Date: Fri, 26 Apr 2019 07:41:09 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/25/19 2:45 PM, Mike Rapoport wrote:
> The idea behind the prevention is that if we fault in pages in the
> execution path, we can compare target address against the kernel symbol
> table.  So if we're in a function, we allow local jumps (and simply falling
> of the end of a page) but if we're jumping to a new function it must be to
> an external label in the symbol table.  Since ROP attacks are all about
> jumping to gadget code which is effectively in the middle of real
> functions, the jumps they induce are to code that doesn't have an external
> symbol, so it should mostly detect when they happen.

This turns the problem from: "attackers can leverage any data/code that
the kernel has mapped (anything)" to "attackers can leverage any
code/data that the current syscall has faulted in".

That seems like a pretty restrictive change.

> At this time we are not suggesting any API that will enable the system
> calls isolation. Because of the overhead required for this, it should only
> be activated for processes or containers we know should be untrusted. We
> still have no actual numbers, but surely forcing page faults during system
> call execution will not come for free.

What's the minimum number of faults that have to occur to handle the
simplest dummy fault?

