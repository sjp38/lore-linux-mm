Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4F93C10F00
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 05:16:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AFCB218A5
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 05:16:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AFCB218A5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD6056B0003; Thu, 21 Mar 2019 01:16:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B86B76B0006; Thu, 21 Mar 2019 01:16:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A773E6B0007; Thu, 21 Mar 2019 01:16:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FA9B6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 01:16:09 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id n63so4605729pfb.14
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 22:16:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=llOBApfIF/W4DGbDzs740EHXe+L19GllRpbu1ZwvtPM=;
        b=PTWxU9is9bY4KWHb3JXaxVN/8dwmp5q0fsN7xYGxiIA6k84vqmEplnwFVxB1S9Fhya
         Ei4XwVJrDBTmIMA3rt+RDVH/jsmP5C1wktAMAI1H2HUTS/3oVZPulKKJUXXISMsQ9AC4
         lSBL3JVzIZVa3HD2yoAr1Fotj0uS7/xmesLt4D8x0PtxamWDRUcVq9UdZzWOXMft33a6
         2DAtkTb+g7CxkJbr7yDUccI37N07IM4ifR1SIv5yhMILwMkLcwvkmZXicmIEH7UhEQ8+
         /v/qfmmYSbJ41bHjhbf7K2sqEBNOs1wf8OcMrJ49qmg9wcKt7ttdtOjfzFE7w0VIxScE
         Nu+w==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAXSPsBSI5fMRp3LyieWVUTC2HUlj5lmbcRnSlIwFO7etb5bllCP
	LioJc900Gm5ClV5R4eiWeg36Rnr3+MFt2IVQwn8/EpALymZji4ib+6XiBBM40iN9S8/U8MxjH3F
	kv5jVO/bMh3vICx3G88EJIEirxBJC7+dCCG6wVCkkjwuUkLEoElEXFrSMZDtBrco=
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr1678359plb.335.1553145369127;
        Wed, 20 Mar 2019 22:16:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrKo9ovQ+k+mUbfGEph4XdgMrEOe07rN8+b57O2t3m/IL4YIkm1jDpFEFMRfGa/YZjdIur
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr1678310plb.335.1553145368198;
        Wed, 20 Mar 2019 22:16:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553145368; cv=none;
        d=google.com; s=arc-20160816;
        b=EJtZ1uA8WxVMU07LAhkSwDHSOJcEkdXyu7k97WHWtA58iXxnv2+ckWbcvQws3IoE0M
         TiqHXCbFroahWyaiZXJ81uSHIFmd3yvXJAlcppYzN5H3Cr/ziy/WOnMAPN8raRVFU+H6
         HOv8xyDfq9ZIXuS7lPHfQOWRb/69ns9mBuAq2yk4nz8t4DItH7Y6c81WyQPiWhTklicq
         JJ8c+aZDN24/aZAOCoB81qi6vs7y8rzTxoys86jxdJAngeXTnVbxqphg4fiudxBrzpKa
         tjU3FcbzI2A382V4w2P9Jcz33lvtd60wNyPLajzmPyNLGkfsmduJESK1ikiGcJ68y+1e
         O8xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=llOBApfIF/W4DGbDzs740EHXe+L19GllRpbu1ZwvtPM=;
        b=SFdZFlyZz7LIXfOb3PEHNFngaMNCplLRQnBw91Gjr+tSzaJ8xCPxmA0/1gLbaNoznu
         o21LDGrPtNMVT/UoIV7+jWeCFKX5VNDJ/EzhaHfhjW0lVZasGCAPtj7tV8B74sYcqF1E
         5IMB/kwklEW5pgqf/yAAtTWrBIEfljg8on1Rqyi+fw2h93dRjwpIF9uz0c7JLX6fOar4
         lEIckLLgSs4uvemu4eJrPnadbHC0IQyHaBhELH8FooncSo3K5sHyrbJWFgE49+WjWq79
         v84PQNWErQMhJMCNQ19K1uB24Iqidxmk+NVsvzam0RjHCzjzZohvC0rX5GT9Te8oa4jA
         8VJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id w1si3534632plz.106.2019.03.20.22.16.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Mar 2019 22:16:07 -0700 (PDT)
Received-SPF: neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=203.11.71.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 203.11.71.1 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44Pw421R1hz9sPY;
	Thu, 21 Mar 2019 16:15:57 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, paulus@ozlabs.org, benh@kernel.crashing.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2] kmemleak: skip scanning holes in the .bss section
In-Reply-To: <20190320181656.GB38229@arrakis.emea.arm.com>
References: <20190313145717.46369-1-cai@lca.pw> <20190319115747.GB59586@arrakis.emea.arm.com> <87lg19y9dp.fsf@concordia.ellerman.id.au> <20190320181656.GB38229@arrakis.emea.arm.com>
Date: Thu, 21 Mar 2019 16:15:56 +1100
Message-ID: <87y35824fn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000003, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Catalin Marinas <catalin.marinas@arm.com> writes:
> On Thu, Mar 21, 2019 at 12:15:46AM +1100, Michael Ellerman wrote:
>> Catalin Marinas <catalin.marinas@arm.com> writes:
>> > On Wed, Mar 13, 2019 at 10:57:17AM -0400, Qian Cai wrote:
>> >> @@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
>> >>  
>> >>  	/* data/bss scanning */
>> >>  	scan_large_block(_sdata, _edata);
>> >> -	scan_large_block(__bss_start, __bss_stop);
>> >> +
>> >> +	if (bss_hole_start) {
>> >> +		scan_large_block(__bss_start, bss_hole_start);
>> >> +		scan_large_block(bss_hole_stop, __bss_stop);
>> >> +	} else {
>> >> +		scan_large_block(__bss_start, __bss_stop);
>> >> +	}
>> >> +
>> >>  	scan_large_block(__start_ro_after_init, __end_ro_after_init);
>> >
>> > I'm not a fan of this approach but I couldn't come up with anything
>> > better. I was hoping we could check for PageReserved() in scan_block()
>> > but on arm64 it ends up not scanning the .bss at all.
>> >
>> > Until another user appears, I'm ok with this patch.
>> >
>> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
>> 
>> I actually would like to rework this kvm_tmp thing to not be in bss at
>> all. It's a bit of a hack and is incompatible with strict RWX.
>> 
>> If we size it a bit more conservatively we can hopefully just reserve
>> some space in the text section for it.
>> 
>> I'm not going to have time to work on that immediately though, so if
>> people want this fixed now then this patch could go in as a temporary
>> solution.
>
> I think I have a simpler idea. Kmemleak allows punching holes in
> allocated objects, so just turn the data/bss sections into dedicated
> kmemleak objects. This happens when kmemleak is initialised, before the
> initcalls are invoked. The kvm_free_tmp() would just free the
> corresponding part of the bss.
>
> Patch below, only tested briefly on arm64. Qian, could you give it a try
> on powerpc? Thanks.
>
> --------8<------------------------------
> diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
> index 683b5b3805bd..c4b8cb3c298d 100644
> --- a/arch/powerpc/kernel/kvm.c
> +++ b/arch/powerpc/kernel/kvm.c
> @@ -712,6 +712,8 @@ static void kvm_use_magic_page(void)
>  
>  static __init void kvm_free_tmp(void)
>  {
> +	kmemleak_free_part(&kvm_tmp[kvm_tmp_index],
> +			   ARRAY_SIZE(kvm_tmp) - kvm_tmp_index);
>  	free_reserved_area(&kvm_tmp[kvm_tmp_index],
>  			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
>  }

Fine by me as long as it works (sounds like it does).

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

