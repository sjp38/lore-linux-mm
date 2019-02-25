Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DC3DC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:24:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 297CB20C01
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:24:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 297CB20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D33DD8E0010; Mon, 25 Feb 2019 10:24:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D09DB8E000B; Mon, 25 Feb 2019 10:24:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF9498E0010; Mon, 25 Feb 2019 10:24:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 790578E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:24:06 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id b4so7515102plb.9
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:24:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=cvLPglrmlarCn3NwbDyxd0R3IaiIIM60KqvXteZiwNo=;
        b=RU2awEpTQoTRUxtKYOR1aE5hu2y7UiM2CndqlRN5/V/TTwGSgRvrX6hbL80p7UxRnb
         45hQCG9XBATZzurb3VT32W0FGqAkTQJHmbT0stPcZD0vExFVSf+JPGjdGu0Dcnp1TIH0
         r3+l0NY6hDMhfhjg/xVoByWuWz40WPM4Tj8HO5xiLzZmJUFCMaT+M8YhTaArBK/iTtHL
         A5N2xzdFr7ijNXM+NLW0EzfgxClotgnv5n5C3UldhsBOPfhuNMTyNtSc6cTk2rhC23ml
         2Pr32uCCPSWvijA8ogu3HCD+AmFRlqAWjzcdWcBZGhJaxxvTkEOZjRICgm6ozzcsohJ/
         2MqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYdQY0GFZbFxTxYzpRtgz3Xio2tm0V4yiSQvud9XxVfcpgmIvHJ
	T8feCdW3VSaq94Lc8cgM6y2LAsRRGjdP2UdtAL8uZZz/ab6PAyTQrNd604rKdVfhmWu2JYU3GwT
	vHODNthjp0EsG3hzJ/+/cGWTTVmvfxHwe2w17rh/t/zXkuBm3eiQ0ljv6p5n19LjgyA==
X-Received: by 2002:aa7:9289:: with SMTP id j9mr21073117pfa.130.1551108246099;
        Mon, 25 Feb 2019 07:24:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbL7q9JIxVHUY3vRc4cbdjaMPfDSER3JO4ecTmkfxlZrrR1p96OkWK6yCNBa7JZI5oR63rd
X-Received: by 2002:aa7:9289:: with SMTP id j9mr21073064pfa.130.1551108245242;
        Mon, 25 Feb 2019 07:24:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551108245; cv=none;
        d=google.com; s=arc-20160816;
        b=wHvuSixOzp/+tcLy1c3mniR1/N3kHjGLpo1aU9lHCgyeNq+9cgn2IW1YQoqmVmjTMQ
         4JrGs2iVA6wGObdPDnbifNMbZdmM4379CUPUb8Lx4nhql5mSn/UAZ52kDEN+Zu1UJ+i8
         0SyqN+Z9ZMl/ysldMqdI++vTqE/rnVvxwkuT0ZWTjSCCxZwNJIW9RFcGiwlL1NQzuszs
         RpWhan7zbjQAybp9Fje/6CloygN7dOWHwTzQPHDZZQoRf553/1Fx/BjYk/GCh98BsE9d
         FJhX3x1jOP9LOBb8mEXFcJocu8Bc4N8KN/3qNCajAb7iCANBaKmAYyFHykrwcbiEIn27
         HpCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=cvLPglrmlarCn3NwbDyxd0R3IaiIIM60KqvXteZiwNo=;
        b=lhGF28Y+tN3JWZ9ixYSj/cwe9wwTDRmtqv0OvjeeoZ9DtPMfzNcVNCGYSZhq123odh
         UiQaL/gNI6QGKqROfAOnFaI5JUI0qWVWXvHvNoNIXYVESLxeALKt3Icedgw2+7yKcHLq
         QI/J2t5vY+fREx+fZH3TJCqkcJfKKjLWIll4Q9CSMYzcOAOicRWQAqIA0Yuk4gx2ad+j
         A64hHZUWNQnNzsSSGHHP9sNRqiXOUYXvinHKHBSXSqfbkEpYxLDbS75YxRBwVmw3yQ6S
         dcBVv5on2QTEavPR4TdNgTIv6CJ44wg6nKNtxBy7BWOZRqLVLpQQFluIO5ZZC6c+C9I4
         SrPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id f11si5441742pgs.291.2019.02.25.07.24.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 07:24:05 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 07:24:04 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,411,1544515200"; 
   d="scan'208";a="141463618"
Received: from mmshuai-mobl.amr.corp.intel.com (HELO [10.254.87.252]) ([10.254.87.252])
  by orsmga001.jf.intel.com with ESMTP; 25 Feb 2019 07:23:59 -0800
Subject: Re: [PATCH 3/6] x86/numa: define numa_init_array() conditional on
 CONFIG_NUMA
To: Pingfan Liu <kernelfans@gmail.com>, x86@kernel.org, linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andy Lutomirski <luto@kernel.org>,
 Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Jonathan Corbet <corbet@lwn.net>, Nicholas Piggin <npiggin@gmail.com>,
 Daniel Vacek <neelx@redhat.com>, linux-kernel@vger.kernel.org
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-4-git-send-email-kernelfans@gmail.com>
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
Message-ID: <8f703c5f-44c7-3a96-487e-3bdf46ee41b0@intel.com>
Date: Mon, 25 Feb 2019 07:23:59 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1551011649-30103-4-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/24/19 4:34 AM, Pingfan Liu wrote:
> +#ifdef CONFIG_NUMA
>  /*
>   * There are unfortunately some poorly designed mainboards around that
>   * only connect memory to a single CPU. This breaks the 1:1 cpu->node
> @@ -618,6 +619,9 @@ static void __init numa_init_array(void)
>  		rr = next_node_in(rr, node_online_map);
>  	}
>  }
> +#else
> +static void __init numa_init_array(void) {}
> +#endif

What functional effect does this #ifdef have?

Let's look at the code:

> static void __init numa_init_array(void)
> {
>         int rr, i;
> 
>         rr = first_node(node_online_map);
>         for (i = 0; i < nr_cpu_ids; i++) {
>                 if (early_cpu_to_node(i) != NUMA_NO_NODE)
>                         continue;
>                 numa_set_node(i, rr);
>                 rr = next_node_in(rr, node_online_map);
>         }
> }

and "play compiler" for a bit.

The first iteration will see early_cpu_to_node(i)==1 because:

static inline int early_cpu_to_node(int cpu)
{
        return 0;
}

if CONFIG_NUMA=n.

In other words, I'm not sure this patch does *anything*.

