Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0656C4646D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 16:37:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B4F5208CB
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 16:37:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="JCidRKGf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B4F5208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F25D08E0003; Fri, 28 Jun 2019 12:37:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFD8D8E0002; Fri, 28 Jun 2019 12:37:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E12F28E0003; Fri, 28 Jun 2019 12:37:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA39D8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:37:15 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e25so4232300pfn.5
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 09:37:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:subject
         :to:cc:references:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=0pzbWUeVsfjE9BdYrrtWhCa67uI2Ig3SpxTxPTx6Clo=;
        b=nxHdwuxK179D3Q/cof9L1ftGyHpTpad6ItKD2sNgdT9yWwHgm8ibek+3EdCt1viaZb
         k4O3XwqecrOUewj5fQgSK7S7DoPuyh7cmgrOCfrjkXaVFrUD1vqIF7LhV1tuJBlB/Ewl
         arkRf+3I7eY7IEoOTioFVlx1SjkOH0tlWdU1LMxwYMu1jDWKEjKEQHkxq9o2y87GnuPS
         jw9eLKH+KAFOSqVFHG5qgvZlBspsmma69TgxvBGL74LMmatKV96TIp4N9KmwOOCTMN3z
         XUxbXpe0p/bvizcGMVN0cg7R6aZuir85sZCMKbvqqqYysDQWzGnAkuFaLtsP8K5wwN6l
         qBxQ==
X-Gm-Message-State: APjAAAV45sEcmt7pxN28bN+Cn2VkeFagCd2sS/rUYVEtj8oTP8uZoVRI
	lL28//myueJQSrrrfSMvgi3vc8eTLzNskECPLAm9oy0e2aqJIB3rz+9kkn3TOSgPHuMaXP9e3JJ
	aDmXAgHguQeZiLmmTS37GO0j6R5/m5S4VHZIiQF/MPOYlMg/4bYf9Y3xmL9kfgirNBQ==
X-Received: by 2002:a65:55ca:: with SMTP id k10mr10264170pgs.14.1561739835139;
        Fri, 28 Jun 2019 09:37:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPOh0xrG92/lrsptxA5TVIyhCA/zrcsIT5D0qG7S9UewdkBjt3fcFoc46Twx22v4nuffaX
X-Received: by 2002:a65:55ca:: with SMTP id k10mr10264121pgs.14.1561739834570;
        Fri, 28 Jun 2019 09:37:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561739834; cv=none;
        d=google.com; s=arc-20160816;
        b=Z8Mqs6m5uyY7B7P+6GDeCI1bWpdzu7lO1jyCiMLLgo/NuEe9icYURrhwxLySACyFAI
         q35TXP0knYmtFcLD+yZEoOgiZ3twUBb6rBGKLrOw31mYiS1qLIRFshojQOMJgBd4iWZx
         6CVI+ml+SDYY2kGmPyT8V4dJx9pbJOTe/BGe3pQ399BWqyWCYrljgUTor8j4hHte7wRc
         3DAfHcES/V63z6hg15wRmZnZrZ+mrwtcrT8d3cNFisI2swEwx9JheZ46B2bI4rw7f8pw
         mZ1f/2jTt9qT63zt+qp+/DMADywiy1wrto4aWBosASHNiJGlhAE99G9p5AeTCK+FNqFJ
         T4pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=0pzbWUeVsfjE9BdYrrtWhCa67uI2Ig3SpxTxPTx6Clo=;
        b=ZY87pUEwN7M6raGs3+sqc9BnfCMGUUgKanVhz/CmAPvRvNHSwaiHKUIYonpEeejD70
         HMGXL50a2BgXh7dukNsyGL2Vmh/XieW5jzTDihne6qBUU+oKGF+vt3yai160LIYId0q9
         diUr39c8zPZCOpFm9569Gs6FOVIUwcv4p2K8ZpBidcUuiOIJLKp4JGOITBpTak4eVxow
         xYz9Zi18DtCcpa5HqwmwKKxR6vfhMLHyGadRckLdfrdVtBPKHwGSLSJq48ZuDnX0UQds
         CvQL5MoIOkcd5BU/GCRMF388OpPiQkU0EvaL6wHTv7suxyWJe4Yi94QjRa2X1lm9Za95
         Akxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=JCidRKGf;
       spf=pass (google.com: domain of prvs=0752b0550=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0752b0550=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa3.hgst.iphmx.com (esa3.hgst.iphmx.com. [216.71.153.141])
        by mx.google.com with ESMTPS id j6si3135044pfi.240.2019.06.28.09.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 09:37:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0752b0550=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) client-ip=216.71.153.141;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=JCidRKGf;
       spf=pass (google.com: domain of prvs=0752b0550=atish.patra@wdc.com designates 216.71.153.141 as permitted sender) smtp.mailfrom="prvs=0752b0550=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1561739834; x=1593275834;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=db7Orwu5Rlutfa6PAdjI+6aa+OUGxvhoykOatgCpUZc=;
  b=JCidRKGftKQlAM+INTD/sKTgfVwV5q4IHy7Cjnuhd153u3iyEfMIzmVi
   XOHtQ2IR3hsKYNsFs47QOUq0/JtTPPMc+bG5DbCHqsS4j8I9JdPJHge9I
   sDgQLe3ya3f9OOgVs9ldjR5DadUBnYexZ7jW7lxW/ztGj1B+8BVqpkzs8
   9LwF5U+YmtppzYrMcBe+j10b+VIK9L1O0p6NmbNiBs+IQlvPZwPsyDbz/
   1csdGAjUdjnwMA8h3g0s5B6FTBJ+TZoVputCg4l8aTadjtEhrfSDgCkQD
   bv4XTq0x4O+KVwIAhzGfeC1i7I62T0HteE4cvqeg6WPfs9zazSDiNbmPy
   Q==;
X-IronPort-AV: E=Sophos;i="5.63,428,1557158400"; 
   d="scan'208";a="116660306"
Received: from h199-255-45-14.hgst.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 29 Jun 2019 00:37:14 +0800
IronPort-SDR: SXVPzR84g6nB/m0cDen5j5ZKwJh7XkZNA3TWfbivr9drbCD/buOdbwhOOzpwUXcDkQmnp0ujR5
 ouvy58UHwSUGXJakmGF3MA9/m6TTFd9KKjGmRrGOHtlA+DzBQtYwNz09eqehnKZ0sPdeWH4eos
 MM8Jd4q11iloB7OAXS1owCItL1kc8RXiOanTiGoFyBQfRuFoVi13IUNS/xG110h3U8fOwY4MMd
 kv5xk4cvpibBSTnsskk+KNBmK9FLdAnu017juh77Ue/BBTqqsX3iJXRUKE1HsTwdtnDI2Xy77j
 i0Z/jMU3uJp7rLvsOrNIMCI0
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 28 Jun 2019 09:36:19 -0700
IronPort-SDR: zdGYV+32eoQxixNUhCnJQ/Jkykro8Xn/bw1cwETlQY+5R3YMoipyYF4pLZ5CWan9ZZ0xuUmf5t
 qvKj/D5Xi+512cbwiuTqO5mohj37tvnm5Q8WbAz256vDOi8FBrC8hKBw0/ASDs36/cS507X714
 B1WZ3E0J+7heFw+4mlijGA+unvPLtch5XoffCFGHJp/V5LcFy128Z+Bvr3M6xq1TJelIhbrWlS
 8IxpFhuQToMKTnJZ/q4EUpRepTkzQcTuSwfsj5XNdrAL3LHwYZtNSNttKp1nm31PaOsn8UjxPa
 mPk=
Received: from usa002665.ad.shared (HELO [10.225.100.130]) ([10.225.100.130])
  by uls-op-cesaip02.wdc.com with ESMTP; 28 Jun 2019 09:37:14 -0700
Subject: Re: [PATCH v3 3/3] RISC-V: Update tlb flush counters
To: Paul Walmsley <paul.walmsley@sifive.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Christoph Hellwig <hch@infradead.org>, Albert Ou <aou@eecs.berkeley.edu>,
 Thomas Gleixner <tglx@linutronix.de>, Kees Cook <keescook@chromium.org>,
 Changbin Du <changbin.du@intel.com>, Anup Patel <anup@brainfault.org>,
 Palmer Dabbelt <palmer@sifive.com>,
 "maintainer:X86 ARCHITECTURE 32-BIT AND 64-BIT" <x86@kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>,
 Borislav Petkov <bp@alien8.de>, Vlastimil Babka <vbabka@suse.cz>,
 Gary Guo <gary@garyguo.net>, "H. Peter Anvin" <hpa@zytor.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
References: <20190429212750.26165-1-atish.patra@wdc.com>
 <20190429212750.26165-4-atish.patra@wdc.com>
 <alpine.DEB.2.21.9999.1906272243530.3867@viisi.sifive.com>
From: Atish Patra <atish.patra@wdc.com>
Message-ID: <d79430e8-20c0-d9b1-c72c-6d116f9e03db@wdc.com>
Date: Fri, 28 Jun 2019 09:37:12 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.9999.1906272243530.3867@viisi.sifive.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 10:47 PM, Paul Walmsley wrote:
> On Mon, 29 Apr 2019, Atish Patra wrote:
> 
>> The TLB flush counters under vmstat seems to be very helpful while
>> debugging TLB flush performance in RISC-V.
>>
>> Update the counters in every TLB flush methods respectively.
>>
>> Signed-off-by: Atish Patra <atish.patra@wdc.com>
> 
> This one doesn't apply any longer.  Care to update and repost?
> 
> 
> - Paul
> 

Yeah. The baseline patch (Gary's patch) was not accepted. I will rebase 
it on top of master and resend.

-- 
Regards,
Atish

