Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 323D3C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:36:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDBA5218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 20:36:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDBA5218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93A4A6B0007; Tue, 23 Apr 2019 16:36:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E9F56B0008; Tue, 23 Apr 2019 16:36:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D7DF6B000A; Tue, 23 Apr 2019 16:36:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 465ED6B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 16:36:30 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n63so10369492pfb.14
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 13:36:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=wkDXEyuBWVa26ktVkqbuCJ5rsN/f+QpBE+itAQZqAZM=;
        b=bNCZBkARmHRo3zq22TeOtOb8+FUFfY3rRHwqrJtj+0hLU79cGjqYIn/ba+mJ4SmTZg
         OfK05Y1f9Cjpsh9jUUXQiI8rLAdMtCQ4uWCRCUwaZxPsVjf69Sebi9lc6YA/bbv5F0HP
         hS4yjTXpDX/5sb/bI88ZSdsxXEXchMcVLDinuztF7OXUx8L9wzNZAklicHmZcQNvpRC7
         0GaJUbrC1lYnozrrqHp5wvQLjH4wct/IddWA5mMM22epFXMkcvFMvY84d893tkgRZdfz
         RyEd5o0AKDTmYPcD5fQb/BsogSWLmyMJFkkjoBuuXDql8ouKRH1zSxqRL4n3No76+1Wd
         SQ4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX2fDlpkMWemu0fv9oN5Mz2oyPmPz/bt2Fxnx3x0fV4RBsZ0mpv
	J6hY7rSvJpp6VoG6Hbby5vFTCm30xHgs91eSKYngyR0LixmlOPvJaN0pLTTD+/o0gt/lCGdPeT1
	mXisRwa/MMU6SmPac0kdkEa7jrvkxTV6Y9cLv+0DIYu34L7d8QixvEMF8LDsfrDqhOw==
X-Received: by 2002:a63:4144:: with SMTP id o65mr26579064pga.241.1556051789969;
        Tue, 23 Apr 2019 13:36:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzf3p84ikjv5lOqCGwBXrPiTQa3Zobs5bmtsapG6BhGv3N0UFG7sZT+8raYXYnzkxjlvRL4
X-Received: by 2002:a63:4144:: with SMTP id o65mr26579010pga.241.1556051789235;
        Tue, 23 Apr 2019 13:36:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556051789; cv=none;
        d=google.com; s=arc-20160816;
        b=RKNRgjt8L/rKUBM1TJ2TAZPxakS8bbmDtbSNqATuLImR7d9WlaYG4s//aRDDDx+3Qv
         tVCDo9M8c6XIaG9JRJhK7DKRiHP1lNBGk1KYZEQR1IQBrkZz7du3nfgIyR8xvBlp7z2C
         BHFfr3pWvMsp2TW3lrQ4EN5AKLWqoizMIPmCAzeIJCX01a4xGx9/ez/BkSiLYOymchh5
         IERI9OSTkY/noQal3ZZzDhZGttY1G6RfAVRVpT69nr8a/xU63Mon9ZpGsqP3OUe0BDy0
         Nzhm/IsvlBGk3uOQ6z/YX6dlf8Ip+oShKEeaqSCgGVKD0+5KbghSD3OQpGDPPI7xgbtK
         xZGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=wkDXEyuBWVa26ktVkqbuCJ5rsN/f+QpBE+itAQZqAZM=;
        b=QN8Lbl7ccLB/DwztOuLdOLfJWhF3fhKk76A05ZqthhA1pt9eMoGwbu7Ex4AXkMfuOs
         8t2yeqS/oPX7NcNYJwJBjlW30ZViRLSuJz8NBop8HmLV+WaUGmWNm6M9dMW4+Jo4kLVg
         NR5RAAiERb1DVLAfDhnTf0dk4S5Sy83FdTaxH4hNJJFz26XhckzUinP8FEis07Bbaj9X
         HDoLDo3lHa2b8gZSl/CuFLrcH/gVyEe8l5KqsxUyFKticZK9q2BF26C6RPTa12wPdcGE
         NLOR/ZtxbXN+nR/60B2kMm7ML29ItW3XNkpDLBCAoRUiesTtClxUBDrjbgHHHSHe1JGr
         v5Uw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id c5si16329955plr.5.2019.04.23.13.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 13:36:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Apr 2019 13:36:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,387,1549958400"; 
   d="scan'208";a="318346461"
Received: from ray.jf.intel.com (HELO [10.7.201.133]) ([10.7.201.133])
  by orsmga005.jf.intel.com with ESMTP; 23 Apr 2019 13:36:28 -0700
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot
 option
To: Alexander Potapenko <glider@google.com>, akpm@linux-foundation.org,
 cl@linux.com, dvyukov@google.com, keescook@chromium.org, labbott@redhat.com
Cc: linux-mm@kvack.org, linux-security-module@vger.kernel.org,
 kernel-hardening@lists.openwall.com
References: <20190418154208.131118-1-glider@google.com>
 <20190418154208.131118-2-glider@google.com>
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
Message-ID: <a0b69045-f6c4-0290-1c59-4dd75b05ee25@intel.com>
Date: Tue, 23 Apr 2019 13:36:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418154208.131118-2-glider@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> +static void poison_dont(struct kmem_cache *c, void *object)
> +{
> +	/* Do nothing. Use for caches with constructors. */
> +}
> +
>  static struct kmem_cache *create_cache(const char *name,
>  		unsigned int object_size, unsigned int align,
>  		slab_flags_t flags, unsigned int useroffset,
> @@ -381,6 +391,10 @@ static struct kmem_cache *create_cache(const char *name,
>  	s->size = s->object_size = object_size;
>  	s->align = align;
>  	s->ctor = ctor;
> +	if (ctor)
> +		s->poison_fn = poison_dont;
> +	else
> +		s->poison_fn = poison_zero;
>  	s->useroffset = useroffset;
>  	s->usersize = usersize;
>  
> @@ -974,6 +988,7 @@ void __init create_boot_cache(struct kmem_cache *s, const char *name,
>  	s->align = calculate_alignment(flags, ARCH_KMALLOC_MINALIGN, size);
>  	s->useroffset = useroffset;
>  	s->usersize = usersize;
> +	s->poison_fn = poison_zero;

An empty indirect call is probably a pretty bad idea on systems with
retpoline.  Isn't this just a bool anyway for either calling poison_dont
or poison_zero?  Can it call anything else?

