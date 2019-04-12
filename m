Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F4B0C282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:44:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C10420850
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:44:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C10420850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 714DF6B000C; Fri, 12 Apr 2019 10:44:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69D306B000D; Fri, 12 Apr 2019 10:44:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5175B6B026B; Fri, 12 Apr 2019 10:44:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 16A546B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:44:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id p13so6384224pll.20
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:44:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=bP4Fwd2yVFH5P84nqqsHQ9FNx5Djc027pg5lP9xvbz0=;
        b=EBALn7BMWwTNnGrSWThitk/iQfC40xQKwGBXqga+2/5aVHleVgSL0fsyw4xSFFe4y4
         IpNiDU++xe7hwrzbhvE7BpMQH2LRFquRQqidto2rkVGepykpCL005CsDEafXpWj/h/cW
         bDY6D56lB7crd4qtL3m8AJLzejtatVHkbqTxWVK2fl6ncwXy3c2vzjomSRTHhoBcMwBB
         GNFNQWNIimjw8EZHAjwEqL8vxfc8sQaOb5iM2LyM+E8kOXs7hEcXe7HLpHJ2P2TneJc9
         78tymTcCwHUYTSNaLHyg85pHRiXeXwftVH70hD4SvgL5/t6i8j6S4T4bvG6XtYwqa+fO
         gNSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW8nlAh8q+mf//WwcnF97NhcmyMsU02hh6t3++VbBtZUiMCfAzA
	/QCPHb0qGmntgFwG41PGc/A63qKhhp3ML6Rz/RzQp4saNtp6DmbQmyvdURdczp/n7Ge9arl3BEG
	EWLEbAGXtYHyUEoNBboBCngEOe8BN4KMJSli7VeaKGmSDoX93Qq95bwHe3dCoE6snnA==
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr1565493plb.236.1555080283549;
        Fri, 12 Apr 2019 07:44:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywYh2CjUqE6NtVlS1oiBAHkTPk87/6r8ej16OHXDhCZgD5WX80HFoM87pxB2T10Pa/ZCG+
X-Received: by 2002:a17:902:2aa6:: with SMTP id j35mr1565434plb.236.1555080282761;
        Fri, 12 Apr 2019 07:44:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555080282; cv=none;
        d=google.com; s=arc-20160816;
        b=GJNJlaLgWMh0cnz8xhAJXYaa5bbTDAQ1OmfqKQj5UaL/jNCpFt7RAkqdjtJDGAJKoC
         Gk3AjRXXMjkq8vuo8k0GkoL7v1HYabAjhc2TI67ujGH4+1xvMSQGfMy8LFXrUbX/Hm0i
         bsQ23FgDg0AoH9RxFrYNFI0sHuGUopgSu9rKyFT3ONwv+VLmIdQy1pIeG9OSBFK2jipk
         giZsy5CDz1qSkRS0jzLtL97xhW8NiD0y9XkEqcxS2AGySSJ/qF4hh1S845icnlWhzgzu
         bI/um5sSdNZ4tVUKTfr/gsxdE0LVkOomMTkdSqqnDIAsL9U5oQBk4HWS6xNMgdCdHWf4
         fjJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=bP4Fwd2yVFH5P84nqqsHQ9FNx5Djc027pg5lP9xvbz0=;
        b=GVYCGlHjYp9y7zTIEKc5HfHEFPt7wPX0F+sE/UVh9W9p4E/nVLjtx/aL0IGpjJyBU/
         I0injmfpwNNARnT0+/S6UArAuLzxOynaIYsBdmJ8lbTcNxdo3zvCxT5GMLee3mM4XPdW
         vCM+yGNW9jWmNs7L/6jQnB1MRvkv1/DNmrux48ZLcl8egvW2Aqchjn6M+v2uv1ChegsO
         afcbwSEDbFnhoFw6fDZVVAUWGP8g/u2S4cz7DqnbjWpYQrhi+i1/7wIFrwJPqhgfe+Sx
         uaPcaIcAkd/CGVuv09pITyhb6ZQJc3i5/hKjOXhGCDPUavTx3OqhprEsqMtgEZxkGlyC
         X0/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id j5si21919780plk.328.2019.04.12.07.44.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Apr 2019 07:44:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Apr 2019 07:44:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,341,1549958400"; 
   d="scan'208";a="336804153"
Received: from jeburk-mobl4.amr.corp.intel.com (HELO [10.251.16.160]) ([10.251.16.160])
  by fmsmga005.fm.intel.com with ESMTP; 12 Apr 2019 07:44:40 -0700
Subject: Re: [PATCH v8 00/20] Convert x86 & arm64 to use generic page walk
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org,
 Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190403141627.11664-1-steven.price@arm.com>
 <4e804c87-1788-8903-ccc9-55953aa6da36@arm.com>
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
Message-ID: <3b9561d0-3bde-ef7a-0313-c2cc6216f94d@intel.com>
Date: Fri, 12 Apr 2019 07:44:37 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <4e804c87-1788-8903-ccc9-55953aa6da36@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/10/19 7:56 AM, Steven Price wrote:
> Gentle ping: who can take this? Is there anything blocking this series?

First of all, I really appreciate that you tried this.  Every open-coded
page walk has a set of common pitfalls, but is pretty unbounded in what
kinds of bugs it can contain.  I think this at least gets us to the
point where some of those pitfalls won't happen.  That's cool, but I'm a
worried that it hasn't gotten easier in the end.

Linus also had some strong opinions in the past on how page walks should
be written.  He needs to have a look before we go much further.

