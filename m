Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16A94C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:38:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C491E240B7
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 12:38:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C491E240B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 629EE6B0010; Tue,  4 Jun 2019 08:38:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5DAF66B026C; Tue,  4 Jun 2019 08:38:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CA1C6B026E; Tue,  4 Jun 2019 08:38:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 007E56B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 08:38:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so233887edr.18
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 05:38:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XpQKN5Du9jjV+zmIJMhwGQwNBMlMSRWmvQ/QDMJxQ3g=;
        b=TGC1+OQLzmH4rTZ0/T4WNY4KDxABkB3lXRFFyrWlzObqjiBDVPUrQjSvG3UBR7Kmos
         zt+VMhBYJxN4DmLX/4swm2QBl5xIAiyiuakwwgOcKJb2YZHcd1UuPu1VtZWyjpyR/VBa
         RNb03jeQHbm2uu9ohiNcs9sBFMT+DwnCTjhuMpAfBJ1T0EkIRkRBe6ykoS49qH3Jlk6i
         mxSFT30i5vmtVTvrfPe/nRVSwIqJe/sdaEu1o+GMOIBd+0AZzHh7OQopLMFbOoYzengs
         sFuzS5eGfDJY4khumi46OWh4eKcJfwm/0tkoL4ivZXIc2L2GpF1pJrxuvy2yjyidXEX1
         af3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX1dq+AXtXy+r56yQHXDNszpeY9VQYSSixyeCC1GHhgDUo3lHGx
	wHSapzW5VBvcnNTRKs4pRJFExd8uyqm4EUdSw6nA0mn93W1fqJimeScoc32Jb3lPkSgOEjDCUyq
	Vslv31l6freQVDrF8qjdt5b5JzvczjLmJwFGcAZyJmsZ2+TauUYRHxR+5JMrtDqeLaw==
X-Received: by 2002:a17:906:7047:: with SMTP id r7mr29224543ejj.11.1559651890557;
        Tue, 04 Jun 2019 05:38:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyytEZ1cuIQF7OKg1NvBvxabMc2xNJzyMjpY6mO8D8JC4BgsU1SgDHS6/683TkKMJWG0ept
X-Received: by 2002:a17:906:7047:: with SMTP id r7mr29224476ejj.11.1559651889750;
        Tue, 04 Jun 2019 05:38:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559651889; cv=none;
        d=google.com; s=arc-20160816;
        b=T3YJjKP0DVQkFcUVShgIL5s1hMn8qLdb+IeM1vkD3Lwvhx+lNGFLG42nmb6/x0Qol8
         BkP1/Z4VtS5Bbx5UEQlSHxyaaRUejh11nBf6Kps5G1MvaA8URIOarIY7LuJELEOey6m8
         rC+H5Ft2DmDBaRpFDS53SgKEU4qTZHeApoh7h3zODtieT3NGZO9UMGeJnq9hj86xDZw6
         AxNd7a7kS0FVukpmarH9PjMGh0F2HUAkgbNqOJiZ3CI+WCULdlELJXZU4RGJV/02SUle
         2M4QpSV0aDLLjDEkxBhPgc2l1G52MKnKUjAcxDl5WJHsP4w+gm/OThFYLoSZTTiu7XGL
         8O3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XpQKN5Du9jjV+zmIJMhwGQwNBMlMSRWmvQ/QDMJxQ3g=;
        b=W9sIYxSOsLjU+6a4Tr0c8Ho8A1fANPIvAO5838ODNtjS/kGaGAAp62bY52kNj0zhD7
         +tvvn+j+AgHVj0EkKA8Zu3HrXiBY6kyG3WtuI6LViXGah1jn4BKlTy2oxJnL0MxYdhu6
         ydSZDk4+IxpWt6ccIvH7GTDpHCRKeu6nWGVRa2NrpEeCSvjbsm6kK5TkwRDkh8ULNGoB
         MPKPQTmpXZ8KPQKdKVyuhAsAarOGwDy+OnbJlCXDTRRNDnVKhT+XALcU1xlmMkTVfDFe
         +qAC+0rE7U1IInbLn+PwIaKSpEqlSjeRt9fjoMwoYQtjJp0E98BUVsMRhqFI4VeT+7HT
         cDQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x15si6091444edb.167.2019.06.04.05.38.09
        for <linux-mm@kvack.org>;
        Tue, 04 Jun 2019 05:38:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 623BCA78;
	Tue,  4 Jun 2019 05:38:08 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A86153F690;
	Tue,  4 Jun 2019 05:38:02 -0700 (PDT)
Date: Tue, 4 Jun 2019 13:38:00 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Andrey Konovalov <andreyknvl@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v2] uaccess: add noop untagged_addr definition
Message-ID: <20190604123759.GA6610@arrakis.emea.arm.com>
References: <c8311f9b759e254308a8e57d9f6eb17728a686a7.1559649879.git.andreyknvl@google.com>
 <20190604122841.GB15385@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604122841.GB15385@ziepe.ca>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 09:28:41AM -0300, Jason Gunthorpe wrote:
> On Tue, Jun 04, 2019 at 02:04:47PM +0200, Andrey Konovalov wrote:
> > Architectures that support memory tagging have a need to perform untagging
> > (stripping the tag) in various parts of the kernel. This patch adds an
> > untagged_addr() macro, which is defined as noop for architectures that do
> > not support memory tagging. The oncoming patch series will define it at
> > least for sparc64 and arm64.
> > 
> > Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >  include/linux/mm.h | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0e8834ac32b7..dd0b5f4e1e45 100644
> > +++ b/include/linux/mm.h
> > @@ -99,6 +99,17 @@ extern int mmap_rnd_compat_bits __read_mostly;
> >  #include <asm/pgtable.h>
> >  #include <asm/processor.h>
> >  
> > +/*
> > + * Architectures that support memory tagging (assigning tags to memory regions,
> > + * embedding these tags into addresses that point to these memory regions, and
> > + * checking that the memory and the pointer tags match on memory accesses)
> > + * redefine this macro to strip tags from pointers.
> > + * It's defined as noop for arcitectures that don't support memory tagging.
> > + */
> > +#ifndef untagged_addr
> > +#define untagged_addr(addr) (addr)
> 
> Can you please make this a static inline instead of this macro? Then
> we can actually know what the input/output types are supposed to be.
> 
> Is it
> 
> static inline unsigned long untagged_addr(void __user *ptr) {return ptr;}
> 
> ?
> 
> Which would sort of make sense to me.

This macro is used mostly on unsigned long since for __user ptr we can
deference them in the kernel even if tagged. So if we are to use types
here, I'd rather have:

static inline unsigned long untagged_addr(unsigned long addr);

In addition I'd like to avoid the explicit casting to (unsigned long)
and use some userptr_to_ulong() or something. We are investigating in
parallel on how to leverage static checking (sparse, smatch) for better
tracking these conversions.

-- 
Catalin

