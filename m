Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81908C2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:58:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4796320868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 18:58:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4796320868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD7DF6B0005; Fri,  7 Jun 2019 14:58:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C88686B0006; Fri,  7 Jun 2019 14:58:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B28296B000A; Fri,  7 Jun 2019 14:58:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 74B9B6B0005
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 14:58:21 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f25so2098481pfk.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 11:58:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=6XhrNd5RInfhDvaVt34HlCkXuTwCE7igxPanwCC78mU=;
        b=LDJbk+/jf8kkdbV9PyyVPU8QPpAWLJAJFB9Rc8t/4zUIUkl39X/+Ja0sh+uAQIv9Hp
         a5UL+aQU2L1JZi1Sy8Xa+dp/M4fPourIYffNmhETcW8SPdbYhJfvf+kgPnCjBuBvgS8c
         IWUt891xmXtpMjJaFuXzsShgTFSit6SK3Bq8qrnfMsY99ZpAD8A8koJXnqZ5ib9FTieL
         aaXZ59VtP4x4n1MtLHg9vyAA5uz/uPJ5cDTvMxwkPDS8cJzJHEBRSRcdxj3VcVHBKytD
         CVdZG9zZYpJolISTbjzNB9j7+hg7vnlAqLblmOtoMwT0BoAhL5pD3xwEUxS0mV/N0PpS
         WYMQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWOayrg629Ng7A83/DeHmJ4W7I95wxubxRBlhHf02+LLTnzRIpK
	0ltiSlw1PMNtwq5l71ZweQZFKPwxSl7x7COfUhZZwkEVrAR3YWSgmha5AXG1GngjP935kwhbrAM
	aWLORvVemOOBAwE0HFB/LbIiUt18ytJx5wKuJlBv9261qH8xSemk279R/L7OdHTVAFw==
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr56740087plb.26.1559933901121;
        Fri, 07 Jun 2019 11:58:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwif2rWxw+xD+vgSGVgSuRW/zrcukn+d1T6+CsozO6d7os4XI49FE5ziWmLUsEO+bu0gCH5
X-Received: by 2002:a17:902:290b:: with SMTP id g11mr56740047plb.26.1559933900424;
        Fri, 07 Jun 2019 11:58:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559933900; cv=none;
        d=google.com; s=arc-20160816;
        b=HhLKloQp99ROyy1mDdPuUN6+Zf7oYBzJutGEycgjQ7XUpTo33ynVvtOKNapPVHWyPN
         n3Sj9trjYaCh1WpwtrPCF7EOZhGSSAn4EkzA38UW4UKV0aN0Yffm2D8n1Mw5J82W0tTu
         mUo2QxYj+QQmZk4jjMdMvLB21C2SEBb0pKn5FisNKOoyPHadPfpGLcxg7UUCS6MXy/89
         cu9PsCyOCNTrsW6KW0N3E3NAKdzwuqr/eNPPOfhGHjrhx3g/oxxAu5a06PzCG6sNpIrx
         bvprVzEoEIcEcO0jVuFlnOwyZhuDVUCElA5RQUj+ofJ/w4iGR78EytCOMFhrJJwX8yIG
         /Tqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=6XhrNd5RInfhDvaVt34HlCkXuTwCE7igxPanwCC78mU=;
        b=zCEHu3a5oRFuc41Jq0TaE2arz67JS24QDSDY7iUkiJGnzzkmpKrBO0fOMDRVDad1iN
         4m6NFhHn0Apes8l9axZfvcCIkYZ8hsMAr98imZBLUt3KDAsfr4AZGXrIplZuMWsAID4C
         bVELprKBT/d0TmSEahKK70P+nab20lEJa//lTs001/Uju+ivKjp98KBXwe2cBXtuJN+F
         LOF0WE0QSJU2LAhKNRPGTH6gQMjGoy2M3Tncw/0p3fpjKpe6+24UO0uXiM+scYKVQAFI
         suZyJ6PFBhc1AynGxlFalq+S1YcQPg3YE9sUwV75r4O7TjQeuSRbp4jej0lipVJYNxdv
         DCIA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id g34si2827593pld.266.2019.06.07.11.58.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 11:58:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 Jun 2019 11:58:19 -0700
X-ExtLoop1: 1
Received: from ray.jf.intel.com (HELO [10.7.198.156]) ([10.7.198.156])
  by orsmga005.jf.intel.com with ESMTP; 07 Jun 2019 11:58:19 -0700
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup
 function
To: Andy Lutomirski <luto@amacapital.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Yu-cheng Yu
 <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org,
 linux-arch@vger.kernel.org, linux-api@vger.kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@gmail.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>,
 "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>,
 Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>,
 Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>,
 Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>,
 Randy Dunlap <rdunlap@infradead.org>,
 "Ravi V. Shankar" <ravi.v.shankar@intel.com>,
 Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
 Dave Martin <Dave.Martin@arm.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
 <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net>
 <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net>
 <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
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
Message-ID: <352e6172-938d-f8e4-c195-9fd1b881bdee@intel.com>
Date: Fri, 7 Jun 2019 11:58:19 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 11:29 AM, Andy Lutomirski wrote:
...
>> I think this new MSR probably needs to get included in oops output when
>> CET is enabled.
> 
> This shouldn’t be able to OOPS because it only happens at CPL 3,
> right?  We should put it into core dumps, though.

Good point.

Yu-cheng, can you just confirm that the bitmap can't be referenced in
ring-0, no matter what?  We should also make sure that no funny business
happens if we put an address in the bitmap that faults, or is
non-canonical.  Do we have any self-tests for that?

Let's say userspace gets a fault on this.  Do they have the
introspection capability to figure out why they faulted, say in their
signal handler?

>> Why don't we require that a VMA be in place for the entire bitmap?
>> Don't we need a "get" prctl function too in case something like a JIT is
>> running and needs to find the location of this bitmap to set bits itself?
>>
>> Or, do we just go whole-hog and have the kernel manage the bitmap
>> itself. Our interface here could be:
>>
>>    prctl(PR_MARK_CODE_AS_LEGACY, start, size);
>>
>> and then have the kernel allocate and set the bitmap for those code
>> locations.
> 
> Given that the format depends on the VA size, this might be a good
> idea.

Yeah, making userspace know how large the address space is or could be
is rather nasty, especially if we ever get any fancy CPU features that
eat up address bits (a la ARM top-byte-ignore or SPARC ADI).

> Hmm.  Can we be creative and skip populating it with zeros?  The CPU
should only ever touch a page if we miss an ENDBR on it, so, in normal
operation, we don’t need anything to be there.  We could try to prevent
anyone from *reading* it outside of ENDBR tracking if we want to avoid
people accidentally wasting lots of memory by forcing it to be fully
populated when the read it.

Won't reads on a big, contiguous private mapping get the huge zero page
anyway?

> The one downside is this forces it to be per-mm, but that seems like
> a generally reasonable model anyway.

Yeah, practically, you could only make it shared if you shared the
layout of all code in the address space.  I'm sure the big database(s)
do that cross-process, but I bet nobody else does.  User ASLR
practically guarantees that nobody can do this.

> This also gives us an excellent opportunity to make it read-only as
> seen from userspace to prevent exploits from just poking it full of
> ones before redirecting execution.

That would be fun.

