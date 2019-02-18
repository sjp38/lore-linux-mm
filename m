Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFEFDC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:20:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA0092146E
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 18:20:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA0092146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 485D18E0004; Mon, 18 Feb 2019 13:20:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435968E0002; Mon, 18 Feb 2019 13:20:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D5E78E0004; Mon, 18 Feb 2019 13:20:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAF7B8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:19:59 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p20so13040967plr.22
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 10:19:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=epQHERfmj9fC1KTUNvnwCdSjRWbY55yT7tucakaVaAU=;
        b=nzk9mRrYrOgWUviW4SesluGuXHmyG7VIfJE6mIx+KVPI5F959hY6Tl9MothyVsqh/o
         ve4hCCniy7N3IPJpFhstJ0JGPiSpxXrBSPwXc0MO0htOSPF473kOXbPnFqdY00p2Xa+A
         6dWdYtMwNvx2zBhZjXTNJFtSpZ7DA3V2rCx4A0lHetfyUVpyXtH5pF3S3PKGoOs0ez3v
         n9ApvCENZf6li8IYhZGYkF7TMktGY3M9QmBnRxO242O/UI4FMrIt97AavNQmaMJRbiYv
         dGklCoysaeiv0qQzjRB66nI1uOHED1tL1sc9NGwMC3R0JfPZAsolBvYAwoaG0OdfoR2F
         /2DQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZMk2brcVszuUjU6vI/5AKEYohNx4WlkQflZEte7j8F0gashI9T
	kK+nt4s7YhAMZUhfKpuXuejAtO9lXuStUdaA2ko62cgnKFKKiZwMcearfDZL/Dp+ZywNclBcJ1S
	ZOpWb/Ro+UvvNaKVlWYD2xNINQ6OISRp433Obm55Mg0wmyxtdUKoDSySvyGXr0K9jsA==
X-Received: by 2002:a17:902:29ab:: with SMTP id h40mr26614963plb.238.1550513999462;
        Mon, 18 Feb 2019 10:19:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZyJNvmaeBElBCH+FomuW3FfLY4mfRc/uqeq2PbH9Ar77xF8hYE9ImdsemrOsGZB0xS42SV
X-Received: by 2002:a17:902:29ab:: with SMTP id h40mr26614883plb.238.1550513998527;
        Mon, 18 Feb 2019 10:19:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550513998; cv=none;
        d=google.com; s=arc-20160816;
        b=hkJglf3mc2Nq6s1+CEDghf6g3u8/Laj/4sQIxqoZBTT/l4KZOs0tSpnHZx3SqsOd1q
         2OPcqidT4K/YjoA91vktAlZztcuBVwLW/pQ8VtE6ANnXU37mVxpk+Mg4nxyDpVgsCsKa
         GaAOVpKnZG5EPL5xpqzWdsC/VGkWwrXNR2NjQRy1CKH9pkw/Fb2HGrE9T1pXLf6fAVJJ
         gHD0hucQfZJ1bd/N3SnXbMA1z7ZQhQJ5/bNqxpvR+Y/XGQH4Al8wySF8HzoPq/1R30Fe
         R1TJKe+4tX1vAIXHnnVyzs4E02oij6yZNo6R3NNrQADp4+J+DLDd2WdXaU9KIwEnH4tO
         NTiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=epQHERfmj9fC1KTUNvnwCdSjRWbY55yT7tucakaVaAU=;
        b=h9iKoOX65qO3+iFMzjvZ6ekKr6symuREph4X+Ys0tkXMkG2JpSG5iYhxRfgvW4Uj+Z
         y5ZKqYaV0q8bop1DEfOHFBvQlYClFgzOXqjeY3GrF1dFb5AIssnIOoWRVHhhTC2DkDD0
         H6GxR/dktdc53oX73fK2N2ysTNmQ7ZgZ/niXG+28q2ip6U6IcO0sZXzQTNif3C2xiZNC
         ly05kGe1fpj0t2u/4GkjyVPYtlwIPUJ+6qTYKlJUsSL8wv+mUGNpyP5SsO1hJWxAjH33
         DVDA/bQjnxVpqxIwvDAaqGILyhD9HcosvNqt99TWrYiDUYiHift0qCamVsQdbsSX9C7Q
         rA4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h189si13668093pfc.211.2019.02.18.10.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 10:19:58 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Feb 2019 10:19:57 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,385,1544515200"; 
   d="scan'208";a="321370394"
Received: from jhurd-mobl.amr.corp.intel.com (HELO [10.254.82.22]) ([10.254.82.22])
  by fmsmga005.fm.intel.com with ESMTP; 18 Feb 2019 10:19:56 -0800
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: mhocko@kernel.org, kirill@shutemov.name, kirill.shutemov@linux.intel.com,
 vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <7f25d3f4-68a1-58de-1a78-1bd942e3ba2f@intel.com>
 <413d74d1-7d74-435c-70c0-91b8a642bf99@arm.com>
 <35b14038-379f-12fb-d943-5a083a2a7056@intel.com>
 <3da12849-bc56-cb9b-f13f-e15d42416223@arm.com>
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
Message-ID: <d4fcaa44-344e-e8f1-f01f-e2f25f46fffb@intel.com>
Date: Mon, 18 Feb 2019 10:20:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <3da12849-bc56-cb9b-f13f-e15d42416223@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/18/19 12:31 AM, Anshuman Khandual wrote:
>> Ahh, got it.  I also assume that the Accessed bit on these platforms is
>> also managed similar to how we do it on x86 such that it can't be used
>> to drive invalidation decisions?
> 
> Drive I-cache invalidation ? Could you please elaborate on this. Is not that
> the access bit mechanism is to identify dirty pages after write faults when
> it is SW updated or write accesses when HW updated. In SW updated method, given
> PTE goes through pte_young() during page fault. Then how to differentiate exec
> fault/access from an write fault/access and decide to invalidate the I-cache.
> Just being curious.

Let's say this was on x86 where the Accessed bit is set by the hardware
on any access.  Let's also say that Linux invalidated the TLB any time
that bit was cleared in software (it doesn't, but let's pretend it did).

In that case, if we needed to do icache invalidation, we could optimize
it by only invalidating the icache when we see the Accessed bit set.
That's because any execution would first set the Accessed bit before the
icache was populated.

So, my question

>>>> Any idea which one it is?
>>>
>>> I am not sure about this particular reported case. But was able to reproduce
>>> the problem through a test case where a buffer was mapped with R|W|X, get it
>>> faulted/mapped through write, migrate and then execute from it.
>>
>> Could you make sure, please?
> 
> The test in the report [1] does not create any explicit PROT_EXEC maps and just
> attempts to migrate all pages of the process (which has 10 child processes)
> including the exec pages. So the only exec mappings would be the primary text
> segment and the mapped shared glibc segment. Looks like the shared libraries
> have some mapped pages.

Yeah, but the executable ones are also read-only in your example:

> $cat /proc/[PID]/numa_maps  | grep libc
> 
> ffffaa4c9000 default file=/lib/aarch64-linux-gnu/libc-2.28.so mapped=150 mapmax=57 N0=150 kernelpagesize_kB=4

^ These are all page-cache, executable and read-only.

> ffffaa621000 default file=/lib/aarch64-linux-gnu/libc-2.28.so
> ffffaa630000 default file=/lib/aarch64-linux-gnu/libc-2.28.so anon=4 dirty=4 mapmax=11 N0=4 kernelpagesize_kB=4
> ffffaa634000 default file=/lib/aarch64-linux-gnu/libc-2.28.so anon=2 dirty=2 mapmax=11 N0=2 kernelpagesize_kB=4

This last one is the only read-write one and it's not executable.


>> Write and Execute at the same time are generally a "bad idea".  Given
> 
> But wont this be the case for all run-time generate code which gets written to a
> buffer before being executed from there.

No.  They usually are r=1,w=1,x=0, then transition to r=1,w=0,x=1.  It's
never simultaneously executable and writable.

>> the hardware, I'm not surprised that this problem pops up, but it would
>> be great to find out if this is a real application, or a "doctor it
>> hurts when I do this."
> 
> Is not that a problem though :)

The point is that it's not a real-world problem.  You can certainly
expose this, but do *real* apps do this rather than something entirely
synthetic?

>> This set generally seems to be assuming an environment with "lots of
>> migration, and not much execution".  That seems like a kinda odd
>> situation to me.
> 
> Irrespective of the reported problem which is user driven, there are many kernel
> triggered migrations which can accumulate I-cache invalidation cost over time on
> a memory heavy system with high number of exec enabled user pages. Will that be
> such a rare situation !
> 
> [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2018-December/620357.html

I translate "trivial C application" to "highly synthetic microbenchmark".

I suspect what's happening here is that somebody wrote a micro that
worked well on x86, although it was being rather stupid.  Somebody got
an arm system, and voila: it's slower.  Someone says "Oh, this arm
system is slower than x86!"

Again, the big questions you have real-world applications with writable,
executable pages?  The kernel essentially has *zero* of these because
they're such a massive security risk.  Adding this feature will
encourage folks to replicate this massive security risk in userspace.

Seems like a bad idea.

