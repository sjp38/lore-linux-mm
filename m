Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EC2FC31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32D9C20866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 19:39:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qcJSquud"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32D9C20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A17746B026A; Wed, 12 Jun 2019 15:39:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C73D6B026B; Wed, 12 Jun 2019 15:39:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8905A6B026C; Wed, 12 Jun 2019 15:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0CF6B026A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:39:06 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id a8so6180673oti.8
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 12:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=V1aXbLm2XL+BepW2uBo1s2vdmZhrMu6a14z0RbbtF8Y=;
        b=WSw5zKkul+3VoFkAY4wPaAOiisRik8MQ+EOE7WpI/9mvKgKfbM1INItanD9Z/j0Oot
         1Jh0BnSTuViicHER3C9bnVyaYpFlPkH1dDOhnonBmO61kVARbFiaPtQcDuk7jp2hUNxB
         u3H8Rnm2J0FHT1jsei0U6l3PTAAvRuH1yeBIkpu4MS1zDH4fUV6yKtpnjBANCnXGMZdZ
         aJDo9GkTmrXZ5+AlkSDStHRR4U9GZx6NWI0FaVgDM67o4LrpLk5IJfZlxXXZf9ih3lN/
         cSOQzZoIUA8Uk0voPNvFwZln126hKPWixJl7x1xNYh8+UDs/JykB1V+77EM37QS5bicm
         nOKQ==
X-Gm-Message-State: APjAAAW2ck7kAw2/3R/TBc1LuRtUiZzsCgwTSVARpFymbbPoO6Ys4McA
	71A1+//yYu7zOZohyh7jO83WQ+orVrVsF9AHAv68HK6TDy7DDmTSbIOKTphRMqmiE3wjuNRauXq
	YRQd86e2xsrguqPBqgpZaPVuQjDRjNXWgKyJg8CyE7qQrCUQQ/nAY/avcyH3KnGGF+Q==
X-Received: by 2002:a9d:30c3:: with SMTP id r3mr2713702otg.141.1560368346022;
        Wed, 12 Jun 2019 12:39:06 -0700 (PDT)
X-Received: by 2002:a9d:30c3:: with SMTP id r3mr2713670otg.141.1560368345415;
        Wed, 12 Jun 2019 12:39:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560368345; cv=none;
        d=google.com; s=arc-20160816;
        b=iIyL8ztpanRJawrvGn2uUHMTYN9ZZ0/3v2IKck1u97KSsTnNCbO5YmZkFfHBacXolr
         birUvVfDWGYWrnueKnnM6mKzszrXVuH0nbdN9FhDu14vXduD7yzmarj9rtWVgkc52zhP
         /ZYJD/2agqdQm22F+4LWcH4IMc2GbQOPGUJYCZJEcpTJFfmumpclwmKM+V5ktBEniqvi
         O+YqhKEOHX2b3VlJRg1kcafBrd+eWUqIA9YsgB+Pz64ZFgJVCs2bsnKn/aEcaUUvKc3+
         /Ogx9Rbeo4wAeb7A+O6oP1DVMGRvVyj4QW0bo66ik05xiZMQiNaNl80SMBGjl5tmFRsg
         yK8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=V1aXbLm2XL+BepW2uBo1s2vdmZhrMu6a14z0RbbtF8Y=;
        b=aWu1a8KXvkuutJcovpKjEcOaGiAqlUphE3XCnzspKg1DwNBLEVAV723z0618PSx7Au
         upk0DFS2BuEcfx/pSzzptiYsiNl5SlNnPCyFec/pwFjrTBFqW4CO0p+zY7evxgJiFEhF
         O8hNvRVc+qn8sUz5ngdqK7aGfrXtNtqeRbcetBbGMBQATTDBYCxqa7rHbZvMxemT2NRV
         Wbk0iti/KtygJUVQKANU2MpiLbnnLzujJipE0M9vuaOSEja2Wlcypz2CB9f++t7X+Xdi
         bMTBvjb0DygoouwR7owmxIGV6tQqHwNy6PIhMVDqnalB7HrwuH/RFWH8wSObi1GWcStw
         D8rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qcJSquud;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor264005otf.84.2019.06.12.12.39.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 12:39:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qcJSquud;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=V1aXbLm2XL+BepW2uBo1s2vdmZhrMu6a14z0RbbtF8Y=;
        b=qcJSquudemsKFEajVtPQXtdzVykjJFvERu1WsQL2yRPQw4DTftC0IGNLeFOxRTfsx7
         hZwVOYf7FLiivzC0IoARki1mBZz+Eiy47UX/b4+OfOMNZNYP0cUymYaINAy27i9c64RP
         fCFijGpqoWoO2+qbyDUABTEumIlys0IJjxgwmpp+oASxvBn3KSxm2MLA0ZbMr0AtoJVp
         q+Ij+3pKAoRyYc7yobSoTIiww21H5hfWlyKorfgaLiIebfrRhm3uqbPk6FNvBsCD2E+b
         zN09bGYm1KJ7uC/Ct1J9TxqXNQO/Puu1I+1eHeL9jJafzNOzuVJIXFMiBHSUxFTwKavX
         lVUg==
X-Google-Smtp-Source: APXvYqzh0qJjO8WXwzyiCt81xF7us6l+7SdOHJxXRhI8LwROXNh/TEz/D85MnJvSavOkYjfQBO3yc0+AR/rgwhtgbHU=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr6590343otf.126.1560368345122;
 Wed, 12 Jun 2019 12:39:05 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
In-Reply-To: <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 12:38:54 -0700
Message-ID: <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 12:37 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Wed, Jun 12, 2019 at 12:16 PM Qian Cai <cai@lca.pw> wrote:
> >
> > The linux-next commit "mm/sparsemem: Add helpers track active portions
> > of a section at boot" [1] causes a crash below when the first kmemleak
> > scan kthread kicks in. This is because kmemleak_scan() calls
> > pfn_to_online_page(() which calls pfn_valid_within() instead of
> > pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=n.
> >
> > The commit [1] did add an additional check of pfn_section_valid() in
> > pfn_valid(), but forgot to add it in the above code path.
> >
> > page:ffffea0002748000 is uninitialized and poisoned
> > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > ------------[ cut here ]------------
> > kernel BUG at include/linux/mm.h:1084!
> > invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> > CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ #6
> > Hardware name: Lenovo ThinkSystem SR530 -[7X07RCZ000]-/-[7X07RCZ000]-,
> > BIOS -[TEE113T-1.00]- 07/07/2017
> > RIP: 0010:kmemleak_scan+0x6df/0xad0
> > Call Trace:
> >  kmemleak_scan_thread+0x9f/0xc7
> >  kthread+0x1d2/0x1f0
> >  ret_from_fork+0x35/0x4
> >
> > [1] https://patchwork.kernel.org/patch/10977957/
> >
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
> >  include/linux/memory_hotplug.h | 1 +
> >  1 file changed, 1 insertion(+)
> >
> > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > index 0b8a5e5ef2da..f02be86077e3 100644
> > --- a/include/linux/memory_hotplug.h
> > +++ b/include/linux/memory_hotplug.h
> > @@ -28,6 +28,7 @@
> >         unsigned long ___nr = pfn_to_section_nr(___pfn);           \
> >                                                                    \
> >         if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> > +           pfn_section_valid(__nr_to_section(___nr), pfn) &&      \
> >             pfn_valid_within(___pfn))                              \
> >                 ___page = pfn_to_page(___pfn);                     \
> >         ___page;                                                   \
>
> Looks ok to me:
>
> Acked-by: Dan Williams <dan.j.williams@intel.com>
>
> ...but why is pfn_to_online_page() a multi-line macro instead of a
> static inline like all the helper routines it invokes?

I do need to send out a refreshed version of the sub-section patchset,
so I'll fold this in and give you a Reported-by credit.

