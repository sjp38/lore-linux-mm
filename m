Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0B22C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:57:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36180208E4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 18:57:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Ss3LFszE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36180208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B80076B0003; Tue, 23 Apr 2019 14:57:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B30876B0005; Tue, 23 Apr 2019 14:57:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A472D6B0007; Tue, 23 Apr 2019 14:57:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 682376B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 14:57:35 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a17so5824077plm.5
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:57:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=WoxsYSmFBK83nDtbePAM0iRr5J/WBY7aawmE+1nqSWU=;
        b=QTYqwrRFuVZDUZDDRgKgL8BAGniy4UuQEh7d5ihsLrYhWUoQVjfFB37S8iK2rIZb11
         kFRqKTCO4uF4DawFIl+jmFLrgBQv2/h8A559zdFseA10j2zschPqaG7mztI3Eaverm8C
         PKmUIkOPvboXBQkBbWP/SIMHLzbMbl+l7VqfNE7GgPHVWOMjjMDWhytlnUzndlegKtIb
         Lw+1vEWqrbKtmzpnQ6kRXE7njYrhLpn9W7O2KvQGXDyMt855A7l+c9QZW+Wm/ft9YLKP
         M2aXSK9WE4kPpVigflgPpE/jks7lcHAGEU1WzkJjn4GLUFFhvz6zN+MIFbTiSF1GN3qn
         EdTg==
X-Gm-Message-State: APjAAAWWdAmZ5wnOjDPwPKu1YOsmSFkFHOFvJQ+p0RwP7cPRVuT735cp
	z5XO9/aSPM6W4Nasa7VQxAr7vRSJZ5vBa2/s7ZNxK1KuqEYw7NsypAFE0OH8pTtlcG1x2KdFpH1
	af4xQP/e+md9a2NSKsAatsRyQY6LtQfewBd7N0tLiZ1Avv9W51zQRGCleulf7NDkLYg==
X-Received: by 2002:a63:c302:: with SMTP id c2mr26515070pgd.235.1556045854980;
        Tue, 23 Apr 2019 11:57:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrGnv+oyTJobaebgY9PkyrxtGVhIqtQWj+446dieH6hbUTH0SBl5G3vqrzc5lVGtupb08k
X-Received: by 2002:a63:c302:: with SMTP id c2mr26515025pgd.235.1556045854185;
        Tue, 23 Apr 2019 11:57:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556045854; cv=none;
        d=google.com; s=arc-20160816;
        b=uaYf1iXP4ZCoT5r3nzcjX8bNqm1dMjbZXdGkkFp+VudhtOmRxgHZGcWI0p8E50BVcx
         WIftxwK/OYc8tmnsDFuWDSWjYh8WBJKI83UbI2n8R8CShqnxcwVC72DX63L2ot42dAnU
         n+LndPsjvE/ECoKE6nJeGt80SELU4KZ5mhqZjEewsm1CRRd+iIwjHr/DZTvJKIwZanJA
         XHKABhhmgVRNQeV0Lssd52LAFlupVrM//nYw8yqoUHaZc4EcBvMWubQt/Nqh0mMLt/9g
         blLqjrEET07PisL3zZPFAi9iKYkJI6gwtIUT64aQIGgv+MnXzhi8zsFp1fIr6k7g76W+
         txVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=WoxsYSmFBK83nDtbePAM0iRr5J/WBY7aawmE+1nqSWU=;
        b=EGMBYxS/oOB7Y8jHDIo/hsxvN+c0tV/EM9yXkVwmpKKdT13bPzPnoTQFkVoKLp3o+z
         rFPrsLgcBRqXRkAU0brqe3vg2QtG4GEuwOM5xxrTQrbv3VN5hk4My5NY/0BssfaT9PqW
         EhStuzqRxeI0FzJByx8OSVRy5+403l7YhRLqs18Gl9kMNysjqBp6MoCmUqlGyFdwvMsf
         orlyDDw3tjqozLUu8sTHNWULsqBf2GSvN3IJxXF6/cGtT+YoTQQI5HwNBOPW6/YRtqC1
         YFQoaq41MLZ/6oD2sHTMHNBskpV3RVGkSOBc7H52XoXw2bYepEy3ksbMT/QQTI7kmaFM
         MYFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ss3LFszE;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e17si14635459pgv.422.2019.04.23.11.57.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Apr 2019 11:57:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Ss3LFszE;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WoxsYSmFBK83nDtbePAM0iRr5J/WBY7aawmE+1nqSWU=; b=Ss3LFszEbU35ZOvSDIV3uQWCkx
	Y6+GBmaYB034wqO+CDQR9qAVPnPIU3prlR0mQR/3NQ1HgukaFzcZE31bR5kTix8yWlTHdHKlksCft
	aoGlU5s1XeRtzXCCbQgs2iIjfyXCUe4R1KOE6E7iWz+Fz6Gd7kVViO1H8AfpUdNQAiryU3nzTDCom
	S81V4NEmVoI2vVAoGwr+1L+Mg4aRxGbQOst2Pf4opp+n0Ip36FsLWHP2a1U5CFK7rpTEmSTEXgGWV
	XbIlZ6M64nYfKc69S7jD9LbAsgwonYf3kBgIpqCcSbxVmVKS1RgZ/i2xgn4rbLnc7y8xoX5zEih2S
	hsGsQUNw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJ0bi-0006mE-MZ; Tue, 23 Apr 2019 18:57:30 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 8798929C3F389; Tue, 23 Apr 2019 20:57:28 +0200 (CEST)
Date: Tue, 23 Apr 2019 20:57:28 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
	broonie@kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-next@vger.kernel.org, mhocko@suse.cz,
	mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
	Josh Poimboeuf <jpoimboe@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@kernel.org>
Subject: Re: mmotm 2019-04-19-14-53 uploaded (objtool)
Message-ID: <20190423185728.GX14281@hirez.programming.kicks-ass.net>
References: <20190419215358.WMVFXV3bT%akpm@linux-foundation.org>
 <af3819b4-008f-171e-e721-a9a20f85d8d1@infradead.org>
 <20190423082448.GY11158@hirez.programming.kicks-ass.net>
 <D7626BC0-FCE9-4424-A6F5-D4AAB6727ED4@amacapital.net>
 <20190423173912.GJ12232@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190423173912.GJ12232@hirez.programming.kicks-ass.net>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 07:39:12PM +0200, Peter Zijlstra wrote:
> On Tue, Apr 23, 2019 at 09:07:01AM -0700, Andy Lutomirski wrote:
> > > diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> > > index 22ba683afdc2..c82abd6e4ca3 100644
> > > --- a/arch/x86/include/asm/uaccess.h
> > > +++ b/arch/x86/include/asm/uaccess.h
> > > @@ -427,10 +427,11 @@ do {                                    \
> > > ({                                \
> > >    __label__ __pu_label;                    \
> > >    int __pu_err = -EFAULT;                    \
> > > -    __typeof__(*(ptr)) __pu_val;                \
> > > -    __pu_val = x;                        \
> > > +    __typeof__(*(ptr)) __pu_val = (x);            \
> > > +    __typeof__(ptr) __pu_ptr = (ptr);            \
> > 
> > Hmm.  I wonder if this forces the address calculation to be done
> > before STAC, which means that gcc can’t use mov ..., %gs:(fancy
> > stuff).  It probably depends on how clever the optimizer is. Have you
> > looked at the generated code?
> 
> I have not; will do before posting the real patch.

x86_64-defconfig using gcc-7.3:

$ ./compare.sh defconfig-build defconfig-build1 vmlinux
compat_fillonedir                                         228        227   -1,+0
copy_fpstate_to_sigframe                                  446        448   +2,+0
                                             total   11374268   11374269   +1,+0


$ ./compare.sh defconfig-build defconfig-build1 vmlinux copy_fpstate_to_sigframe

...

0000 ffffffff81027448:  90                      nop                                                      \ 0000 ffffffff81027448:       8b 15 92 75 a8 01       mov    0x1a87592(%rip),%edx
0000 ffffffff81027449:  90                      nop                                                      \ 0000                         ffffffff8102744a: R_X86_64_PC32 fpu_user_xstate_size-0x4
0000 ffffffff8102744a:  90                      nop                                                      \ 0000 ffffffff8102744e:       48 01 da                add    %rbx,%rdx
0000 ffffffff8102744b:  8b 15 8f 75 a8 01       mov    0x1a8758f(%rip),%edx                              \ 0000 ffffffff81027451:       90                      nop
0000                    ffffffff8102744d: R_X86_64_PC32 fpu_user_xstate_size-0x4                         \ 0000 ffffffff81027452:       90                      nop
0000 ffffffff81027451:  c7 04 13 45 58 50 46    movl   $0x46505845,(%rbx,%rdx,1)                         \ 0000 ffffffff81027453:       90                      nop
0000 ffffffff81027458:  31 d2                   xor    %edx,%edx                                         \ 0000 ffffffff81027454:       c7 02 45 58 50 46       movl   $0x46505845,(%rdx)
0000 ffffffff8102745a:  90                      nop                                                      \ 0000 ffffffff8102745a:       31 d2                   xor    %edx,%edx
0000 ffffffff8102745b:  90                      nop                                                      \ 0000 ffffffff8102745c:       90                      nop
0000 ffffffff8102745c:  90                      nop                                                      \ 0000 ffffffff8102745d:       90                      nop
0000 ffffffff8102745d:  90                      nop                                                      \ 0000 ffffffff8102745e:       90                      nop
0000 ffffffff8102745e:  90                      nop                                                      \ 0000 ffffffff8102745f:       90                      nop
0000 ffffffff8102745f:  90                      nop                                                      \ 0000 ffffffff81027460:       90                      nop
0000 ffffffff81027460:  90                      nop                                                      \ 0000 ffffffff81027461:       90                      nop
0000 ffffffff81027461:  90                      nop                                                      \ 0000 ffffffff81027462:       90                      nop
0000 ffffffff81027462:  90                      nop                                                      \ 0000 ffffffff81027463:       90                      nop
0000 ffffffff81027463:  31 c9                   xor    %ecx,%ecx                                         \ 0000 ffffffff81027464:       90                      nop

...

So yes, it changes some code, but meh.

