Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E5DCC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:51:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 046FA217D9
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bsXbu4Dx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 046FA217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F566B0003; Tue,  6 Aug 2019 16:51:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9ED006B0006; Tue,  6 Aug 2019 16:51:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DD066B0007; Tue,  6 Aug 2019 16:51:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5AADA6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 16:51:51 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 191so56680689pfy.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 13:51:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Fqahyxs++tseC3xxaDSFqv0GOrg0dL2G+et2J54hbiQ=;
        b=cf3IDYwOS+nLyW/r0P8lnZG5oIfDurl/ebOQUgHLG8nGpR9vRiSX3oDLQUzVt5ZM+j
         TJMYYMaoQ5xozt5hz5595lmQDkdaSUwiXfJmljjF3sjapBLANlUKCdL07D6m0Bt1+pHk
         /eGH2XQCN7j2ckHlKhgM3wH+RpqVBfWVBCcZpDCfupaftVUgsFztCo0xD2obkODVoi9G
         abp2eI6QVZ8rwZHWHKXhB9g7DatUCvsqNxCzcYWwKIHIAYNqW1iGynHr4adytiCj83Qf
         nly50/u2EBh9u/hWVosZEca9IUXn/ooNMWogvULYUDdgAfh8zMPsDwZvwHjwggQmF1fS
         Oz8A==
X-Gm-Message-State: APjAAAUzOjaXMDJZz3UAYFb7C9+F3CnpFV03JJKPvcgDCA/mLdaYrEbO
	m6jcpwloJY6uib6uEHLgC7v47A0vpW6NZz8TA83l3/OYo9wrLfAK5M6P9l9T1tT5zEAD3BsxKA5
	+MMl/ltZB1+PZcg1khy+j9PGJEv20wI9RA3utwf7RL9DShL7qVGARjcBGfCLP4corKQ==
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr5058958pjo.131.1565124711045;
        Tue, 06 Aug 2019 13:51:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfrXRp9werBBviszNNXNL1ETHowYGhJISNvwMRJOAqWe03PvQ+/CKCP+DaVCfsJiLWLznD
X-Received: by 2002:a17:90a:8d09:: with SMTP id c9mr5058920pjo.131.1565124710248;
        Tue, 06 Aug 2019 13:51:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565124710; cv=none;
        d=google.com; s=arc-20160816;
        b=L+1U0OiDQxFcNkKfhY5xiBf5M/wnz8byhIclWt6MglGh6KGxbOpxOO+sHhHH0bxqrY
         BYSG0zDGtmtg1yJfUp0L+RDxjsdsNuPta/uKZrV79JIRO0UzMEKGnElzp3eKleoulvGO
         g20IeZ8unrpD0s2GQ2Xx5p9ZsKOgscWJ30NX2csYFQm/T3dim9R/bjW7n9jumgAagf3E
         YnYcoCzdeIKlGldizurBHZYhAcLMtbfUeERwc6FYh+dWcKHWaHzWdsX+ukV1YX/X9X9T
         fQ0+amA5t5uV2kvL0T79c/VdCmEHf5Igjmlh8dm3dlNqDiL9gvMvXdC6RQZJqKKi45ZZ
         KHjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Fqahyxs++tseC3xxaDSFqv0GOrg0dL2G+et2J54hbiQ=;
        b=av2sW9yqi8vMG+o1z8hwS1ZCYQxWNtAg5+5+bvVLgkb3m7mvHlNFGrJS66TkS2YwUD
         ecDFi1gwF2dgctl47uKqxcnDvm6ZqDBO+GcD19cXIEsbuGF7HDLjJUlyEmTEDcuDkpNT
         9VOwRpMHP8bdczkCOuYX9hDrMdfa4HCIl2oU9t1E9InD39l1S2YSb2N4JP2Tgsc1aYFB
         gCq11FJrAHID/NsYROFWq1wdvGJ8u91sIJ8C1Sl4RB0/PR9QsJgT5PwpQpYdu3BE8ha1
         +oso68F7OSLkjbXaYvcCNBlquBKF2mOEJoK1dSrjFcsUbLU2mhDAEctQFKJqvoM7f8tP
         7UAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bsXbu4Dx;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id cl13si43539473plb.97.2019.08.06.13.51.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 13:51:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bsXbu4Dx;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7C26D2173B;
	Tue,  6 Aug 2019 20:51:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565124709;
	bh=gmv2NhynOlvsJo/XaSmVGbWDHCIS29JRNjVFyDL59Zo=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=bsXbu4Dx0vPRFZVn7Kylt0tqlWkV0eU7YaCb+zd7CGaaVwGbccAS8ljEFwgTMUBBA
	 tkAC3iX3lvn0b6EK+PbvZtP8lpesaTAPP0jzqrw9KJIPXQc8G2mc0cmsC9mqj1bsHw
	 Yqts5gAZNKCpKtQWQDT/pjUojR2gM2gDwG6IiW0E=
Date: Tue, 6 Aug 2019 13:51:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Qian Cai <cai@lca.pw>, arnd@arndb.de, kirill.shutemov@linux.intel.com,
 mhocko@suse.com, linux-mm@kvack.org, linux-arch@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] asm-generic: fix variable 'p4d' set but not used
Message-Id: <20190806135148.867b32afce5a64e4ed651ccd@linux-foundation.org>
In-Reply-To: <20190806143904.GE11627@ziepe.ca>
References: <1564774882-22926-1-git-send-email-cai@lca.pw>
	<20190806143904.GE11627@ziepe.ca>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Aug 2019 11:39:04 -0300 Jason Gunthorpe <jgg@ziepe.ca> wrote:

> On Fri, Aug 02, 2019 at 03:41:22PM -0400, Qian Cai wrote:
> > GCC throws a warning on an arm64 system since the commit 9849a5697d3d
> > ("arch, mm: convert all architectures to use 5level-fixup.h"),
> > 
> > mm/kasan/init.c: In function 'kasan_free_p4d':
> > mm/kasan/init.c:344:9: warning: variable 'p4d' set but not used
> > [-Wunused-but-set-variable]
> >   p4d_t *p4d;
> >          ^~~
> > 
> > because p4d_none() in "5level-fixup.h" is compiled away while it is a
> > static inline function in "pgtable-nopud.h". However, if converted
> > p4d_none() to a static inline there, powerpc would be unhappy as it
> > reads those in assembler language in
> > "arch/powerpc/include/asm/book3s/64/pgtable.h",
> > 
> > ./include/asm-generic/5level-fixup.h: Assembler messages:
> > ./include/asm-generic/5level-fixup.h:20: Error: unrecognized opcode:
> > `static'
> > ./include/asm-generic/5level-fixup.h:21: Error: junk at end of line,
> > first unrecognized character is `{'
> > ./include/asm-generic/5level-fixup.h:22: Error: unrecognized opcode:
> > `return'
> > ./include/asm-generic/5level-fixup.h:23: Error: junk at end of line,
> > first unrecognized character is `}'
> > ./include/asm-generic/5level-fixup.h:25: Error: unrecognized opcode:
> > `static'
> > ./include/asm-generic/5level-fixup.h:26: Error: junk at end of line,
> > first unrecognized character is `{'
> > ./include/asm-generic/5level-fixup.h:27: Error: unrecognized opcode:
> > `return'
> > ./include/asm-generic/5level-fixup.h:28: Error: junk at end of line,
> > first unrecognized character is `}'
> > ./include/asm-generic/5level-fixup.h:30: Error: unrecognized opcode:
> > `static'
> > ./include/asm-generic/5level-fixup.h:31: Error: junk at end of line,
> > first unrecognized character is `{'
> > ./include/asm-generic/5level-fixup.h:32: Error: unrecognized opcode:
> > `return'
> > ./include/asm-generic/5level-fixup.h:33: Error: junk at end of line,
> > first unrecognized character is `}'
> > make[2]: *** [scripts/Makefile.build:375:
> > arch/powerpc/kvm/book3s_hv_rmhandlers.o] Error 1
> > 
> > Fix it by reference the variable in the macro instead.
> > 
> > Signed-off-by: Qian Cai <cai@lca.pw>
> >  include/asm-generic/5level-fixup.h | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
> > index bb6cb347018c..2c3e14c924b6 100644
> > +++ b/include/asm-generic/5level-fixup.h
> > @@ -19,7 +19,7 @@
> >  
> >  #define p4d_alloc(mm, pgd, address)	(pgd)
> >  #define p4d_offset(pgd, start)		(pgd)
> > -#define p4d_none(p4d)			0
> > +#define p4d_none(p4d)			((void)p4d, 0)
> 
> Yuk, how about a static inline instead?

Yes.  With the appropriate `#ifndef __ASSEMBLY__' to avoid powerpc
build errors?

