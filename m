Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1B81C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:52:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6FD0420B7C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 21:52:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="t/LtYlXI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FD0420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19BF36B000D; Wed, 12 Jun 2019 17:52:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14D1D6B000E; Wed, 12 Jun 2019 17:52:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2F1D6B0010; Wed, 12 Jun 2019 17:52:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id C8DA86B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 17:52:44 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id d13so8341217oth.20
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:52:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6I4UhGxWaA3Gb80VvVkJBFAuR8ADABp6ljN3MbUT8P8=;
        b=MtknMh+KufKbHFi4f1Pn3DwDJjV67SUa4rdbTFDDzrEVSwBSxR19Tg1lU+/u8/eMFi
         B8iUIZcKiVGZtc8tGS5aUG1pCpATf6P/NQkfPC7bw9WHZAgD1PYSu/kPFl2gZpY6OJlV
         8r8DgE4QjZ+kfgTSsQSHvsPaZzV2X0P9B+A/K539ENORlPvd9L8Tn4aIX5oNnVt10HJB
         hS14pRK2Dwct0c/NND53riJwDHQ3zHXBq2NASGpzCZ77l/DbEIYJks6CsELC1Q1p8bfN
         plMQ2srDrwZH6nTZIJrcrl1AzjR6cvdgw8utgv0H9lej6dQ/ELvc/7uulnY6z35L4eDr
         OMzA==
X-Gm-Message-State: APjAAAXunKX2NTuK9lFoRvZBDWy8DxJZDKzX94HoVaaeK5c203XEF3z1
	lntxriUTA8JRF3099ta6DlER2JpnDiBH8OLDiawijxCNUTFX/zG82lR9qavRh53dl6LwTmdEuS4
	gVGPEXyzDMS3ixZEkwaMULExYWmEh3ffXtfEqh2HcfxRh92z624RqFEDBH+XcaeEWdQ==
X-Received: by 2002:a9d:3ee:: with SMTP id f101mr4485303otf.311.1560376364467;
        Wed, 12 Jun 2019 14:52:44 -0700 (PDT)
X-Received: by 2002:a9d:3ee:: with SMTP id f101mr4485254otf.311.1560376363542;
        Wed, 12 Jun 2019 14:52:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560376363; cv=none;
        d=google.com; s=arc-20160816;
        b=HtL+OCNVYfWuRUQkCcJO1u/seuiuTf/UNbKMSvbiBtpJciUA1OvYLvkpYwdNppppem
         mrK45EhlX0fUeW7kg6PZFRAvFZOBIsic7jJf5LqJi810LejSWEHw0PgOlz4x4i6tcXJ3
         Ra1Mf/DdW8OkZnjBEqznOK/MrdlZBWXKj+s2CWChtaPAIvPHmki+bDvCEtryac1YCl7m
         ANs9yqihcZ4TLR3LCwdgpkdumztVZQNkfi7544Xvcw5U8ZVwHqaULYQlGdFfo+nbED8y
         rfnWDErAM12ctPFOSeRx3kmcISqcd0Po75i/k1zCbU8pL9aDBRbUjKxwV2eUR27MuDw+
         36Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6I4UhGxWaA3Gb80VvVkJBFAuR8ADABp6ljN3MbUT8P8=;
        b=lhpe8FzVDLjaZA159avoV/pAzchHorlhHsE0qMyXXJ2yTKVIe4Of9ORDoYMl2JeMy7
         lFy7F8yNGYTHmZXGErLtYmuunkXwZ04K2eL2MqhHzT2SVOh3dAwT5jozj3mgYBETBnBF
         DaD46YSZTmFOtYNpMR920fzEnMAEKSoDHRVZl86ydo37TgxIEpROJkwXtgu/8+IThf+R
         qiYRV2ELA802WdqVk/HatXHSw1r3yGYW4PaoNzl1byMwD10eZ0PUbJ03A1ZvvTrVW+H5
         zCmj/WO8NPHlnw1gOmMxNts43/qytL+8JtsUH6BDfdnNL2VdAAxVNKzaKIGXv5rKi2HH
         PzZA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="t/LtYlXI";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2sor575209oif.13.2019.06.12.14.52.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 14:52:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="t/LtYlXI";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6I4UhGxWaA3Gb80VvVkJBFAuR8ADABp6ljN3MbUT8P8=;
        b=t/LtYlXIF46TitPw589p2KKh1+ABnvcq6VWBiOms0xFk5we8MC19HRSnK0mk6paPV3
         BqWc1gkWt0hb/gtf242TP8yvyc/7QcNroF8CuoIZ5KzhQfcjxjkVHZ7SS5vDr8U7nikg
         e3I0n54wjzzXtHVEKaYxhV+xnkjXkxiLe2DEKyCQOi4Nww6fZVskUZSWcAlRHQmPF1u8
         mzVDonp1OWjLbaFYeorKfUuPPXnK2ugKYSPiETzx3FKkCodW8FnFk7Hg1oxst4U/743L
         B+PxySWCRWdncIfshw2o7NDwsRVaj706fOUZ1AmlKxXzpVHcwQqpG0D/LwWSETA1y+q8
         Ofxw==
X-Google-Smtp-Source: APXvYqzoYqA6hvg+G2xozSexw2i/LuPgM2SYC22ou80KIuOhKtfwezG57afnlpkDvjkEHXWsl7UZfNyc19QuHcKKzYM=
X-Received: by 2002:aca:4208:: with SMTP id p8mr947757oia.105.1560376362796;
 Wed, 12 Jun 2019 14:52:42 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com> <1560376072.5154.6.camel@lca.pw>
In-Reply-To: <1560376072.5154.6.camel@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Jun 2019 14:52:31 -0700
Message-ID: <CAPcyv4gOhSOwE1DYWdLRkYSo2EL=KFf7LXUZ1w+M=w0xwFpknQ@mail.gmail.com>
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

On Wed, Jun 12, 2019 at 2:47 PM Qian Cai <cai@lca.pw> wrote:
>
> On Wed, 2019-06-12 at 12:38 -0700, Dan Williams wrote:
> > On Wed, Jun 12, 2019 at 12:37 PM Dan Williams <dan.j.williams@intel.com>
> > wrote:
> > >
> > > On Wed, Jun 12, 2019 at 12:16 PM Qian Cai <cai@lca.pw> wrote:
> > > >
> > > > The linux-next commit "mm/sparsemem: Add helpers track active portions
> > > > of a section at boot" [1] causes a crash below when the first kmemleak
> > > > scan kthread kicks in. This is because kmemleak_scan() calls
> > > > pfn_to_online_page(() which calls pfn_valid_within() instead of
> > > > pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=n.
> > > >
> > > > The commit [1] did add an additional check of pfn_section_valid() in
> > > > pfn_valid(), but forgot to add it in the above code path.
> > > >
> > > > page:ffffea0002748000 is uninitialized and poisoned
> > > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > > > ------------[ cut here ]------------
> > > > kernel BUG at include/linux/mm.h:1084!
> > > > invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> > > > CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ #6
> > > > Hardware name: Lenovo ThinkSystem SR530 -[7X07RCZ000]-/-[7X07RCZ000]-,
> > > > BIOS -[TEE113T-1.00]- 07/07/2017
> > > > RIP: 0010:kmemleak_scan+0x6df/0xad0
> > > > Call Trace:
> > > >  kmemleak_scan_thread+0x9f/0xc7
> > > >  kthread+0x1d2/0x1f0
> > > >  ret_from_fork+0x35/0x4
> > > >
> > > > [1] https://patchwork.kernel.org/patch/10977957/
> > > >
> > > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > > ---
> > > >  include/linux/memory_hotplug.h | 1 +
> > > >  1 file changed, 1 insertion(+)
> > > >
> > > > diff --git a/include/linux/memory_hotplug.h
> > > > b/include/linux/memory_hotplug.h
> > > > index 0b8a5e5ef2da..f02be86077e3 100644
> > > > --- a/include/linux/memory_hotplug.h
> > > > +++ b/include/linux/memory_hotplug.h
> > > > @@ -28,6 +28,7 @@
> > > >         unsigned long ___nr = pfn_to_section_nr(___pfn);           \
> > > >                                                                    \
> > > >         if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> > > > +           pfn_section_valid(__nr_to_section(___nr), pfn) &&      \
> > > >             pfn_valid_within(___pfn))                              \
> > > >                 ___page = pfn_to_page(___pfn);                     \
> > > >         ___page;                                                   \
> > >
> > > Looks ok to me:
> > >
> > > Acked-by: Dan Williams <dan.j.williams@intel.com>
> > >
> > > ...but why is pfn_to_online_page() a multi-line macro instead of a
> > > static inline like all the helper routines it invokes?
> >
> > I do need to send out a refreshed version of the sub-section patchset,
> > so I'll fold this in and give you a Reported-by credit.
>
> BTW, not sure if your new version will fix those two problem below due to the
> same commit.
>
> https://patchwork.kernel.org/patch/10977957/
>
> 1) offline is busted [1]. It looks like test_pages_in_a_zone() missed the same
> pfn_section_valid() check.
>
> 2) powerpc booting is generating endless warnings [2]. In vmemmap_populated() at
> arch/powerpc/mm/init_64.c, I tried to change PAGES_PER_SECTION to
> PAGES_PER_SUBSECTION, but it alone seems not enough.

Yes, I was just sending you another note about this. I don't think
your proposed fix is sufficient. The original intent of
pfn_valid_within() was to use it as a cheaper lookup after already
validating that the first page in a MAX_ORDER_NR_PAGES range satisfied
pfn_valid(). Quoting commit  14e072984179 "add pfn_valid_within helper
for sub-MAX_ORDER hole detection":

    Add a pfn_valid_within() helper which should be used when scanning pages
    within a MAX_ORDER_NR_PAGES block when we have already checked the
validility
    of the block normally with pfn_valid().  This can then be
optimised away when
    we do not have holes within a MAX_ORDER_NR_PAGES block of pages.

So, with that insight I think the complete fix is this:

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6dd52d544857..9d15ec793330 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1428,7 +1428,7 @@ void memory_present(int nid, unsigned long
start, unsigned long end);
 #ifdef CONFIG_HOLES_IN_ZONE
 #define pfn_valid_within(pfn) pfn_valid(pfn)
 #else
-#define pfn_valid_within(pfn) (1)
+#define pfn_valid_within(pfn) pfn_section_valid(pfn)
 #endif

 #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL

