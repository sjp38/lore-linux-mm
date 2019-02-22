Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D5A5C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:54:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D74C220651
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 22:54:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D74C220651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EF5E8E0144; Fri, 22 Feb 2019 17:54:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 575828E0141; Fri, 22 Feb 2019 17:54:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F06E8E0144; Fri, 22 Feb 2019 17:54:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3CB08E0141
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 17:54:53 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id t26so2726221pgu.18
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 14:54:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=Ud2LBeXQliSDG2UaPkh84A4l57TzOut1Zflu97IJJWU=;
        b=toiv3Y3SLwPDepOxGMzyZyBuO095yyZL7MHPTTZj6lfTYepBVy0vjRauZV50O1Vy18
         QisUmKUUQJ++naw+75ykior6t70h+k1zG/hFYGO/u8klpSJrydixtE/J5aQfT89nneCq
         5dPF3xlb1XPTqvxZR+yfwJ2KSeZuPoYLJF52XubVX/KN57kXyg+/lH2kylGcwDMz7ajV
         kIyrRty96FJ3d2D4wUvZ9sniu4bkLSyyW5PYl0rIuUbrUPypZpb4SCtrcvEywuyks58i
         bCOt8CZtYx4ihGZaMt2t06LIHNY+2/abwBTY/6z1wdxqeZm+uC+WDmoToCT2JHxmAeHY
         HxCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubCrKw5tZoe7LMpVVr4Lf+UktyeF1hzm1VNiU3aaPL572+ubdj7
	ESVTlEwbBHyprglJQz84gQObqjjNk3oZGQ7LOaK/WhqAa7NpKnsiPjLhGkw8F77J5/ttm3zwCR2
	69UShL/GxFZsnttAGR13wTSrRflntfKjxRPO/VPFCKJLp0jZedWN4AcnKGVtnZgXcBA==
X-Received: by 2002:a63:2706:: with SMTP id n6mr6025790pgn.352.1550876093560;
        Fri, 22 Feb 2019 14:54:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0OLYV2VblyUKIEE4aiuYeA7qO9nYE7R9d0EsnsCg5BpvpsWTMs8EGElGPjsuGmuNdBHH0
X-Received: by 2002:a63:2706:: with SMTP id n6mr6025741pgn.352.1550876092625;
        Fri, 22 Feb 2019 14:54:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550876092; cv=none;
        d=google.com; s=arc-20160816;
        b=zgR7GSiqrKGDSCdHOKYxXN592A0DyyyYk7RRcjvb5AubM/iTdqW6NJcr4nKJD+oZqz
         YZJMxajykVzjCc0Q2onxffozDeNOPCpOfLsqh+hLQM2BuPgJgM/WlcJP8LG781YBje5U
         ilMLQlhzZ5vafNNm3NC49FVfJYCFv5gJQsLiGB87/xgvT+kOSpwT/zgZR2xzxzhHAc20
         8weFzBxFwCOH85UkM/U2B5iS9FPhnF5oipcDIpmFX7B0j+Qgi0n8Dc7/T6zpcqox9oQs
         xKrj+fTCKMrgEi0Zg5vOkHxHbwC3uGt1VGCwNnqMP3hSYNsbZmC6baYcwa2E/KeMR4hg
         uenA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=Ud2LBeXQliSDG2UaPkh84A4l57TzOut1Zflu97IJJWU=;
        b=w3AIJ9tkrUKY3NWr69lB+HE3u9St8PJY0e7a9M0fQTsA0xf0CgH9nUOImCaI8Ouyhp
         d3zCa4XLB781vi4PAmAZLj9du1Pfy2+7GI9aGG06r7IdidgedpZZrEhVjodlVFJ4J1e+
         O2O/nlI8ubXZ0fzjXfGh32oYPNRfG9NrlqKiEavoOEiCwMfZz0xz5mymQMP/Ak1TI19i
         pIZgPUiHwca5CVqtxrsYNEX3nPDmSRX2VLndgAMslqH5g50MNvIh3Uvl5j/Rx9fa5zsR
         sj2hBJ7SAy2iuG4zBPVid7m92u8q0VRk6nd+zrGZnBjwZFNcSUbd2d4r1YN07b9+y5TU
         7GUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id q77si2499424pfi.220.2019.02.22.14.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 14:54:52 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Feb 2019 14:54:52 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,401,1544515200"; 
   d="scan'208";a="120100398"
Received: from ray.jf.intel.com (HELO [10.7.201.17]) ([10.7.201.17])
  by orsmga008.jf.intel.com with ESMTP; 22 Feb 2019 14:54:50 -0800
Subject: Re: [PATCH v10 00/12] arm64: untag user pointers passed to the kernel
To: Andrey Konovalov <andreyknvl@google.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>,
 Kate Stewart <kstewart@linuxfoundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Shuah Khan <shuah@kernel.org>, Vincenzo Frascino
 <vincenzo.frascino@arm.com>, linux-arm-kernel@lists.infradead.org,
 linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>,
 Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>,
 Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
 Jacob Bramley <Jacob.Bramley@arm.com>,
 Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
 Chintan Pandya <cpandya@codeaurora.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>,
 Szabolcs Nagy <Szabolcs.Nagy@arm.com>
References: <cover.1550839937.git.andreyknvl@google.com>
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
Message-ID: <2ad5f897-25c0-90cf-f54f-827876873a0a@intel.com>
Date: Fri, 22 Feb 2019 14:54:51 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <cover.1550839937.git.andreyknvl@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> The following testing approaches has been taken to find potential issues
> with user pointer untagging:
> 
> 1. Static testing (with sparse [3] and separately with a custom static
>    analyzer based on Clang) to track casts of __user pointers to integer
>    types to find places where untagging needs to be done.

First of all, it's really cool that you took this approach.  Sounds like
there was a lot of systematic work to fix up the sites in the existing
codebase.

But, isn't this a _bit_ fragile going forward?  Folks can't just "make
sparse" to find issues with missing untags.  This seems like something
where we would ideally add an __tagged annotation (or something) to the
source tree and then have sparse rules that can look for missed untags.

