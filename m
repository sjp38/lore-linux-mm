Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF77CC46477
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:17:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44A8420B7C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 01:17:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="vcKtePLx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44A8420B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B70B08E0003; Thu, 13 Jun 2019 21:17:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB236B026B; Thu, 13 Jun 2019 21:17:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C10E8E0003; Thu, 13 Jun 2019 21:17:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6EF6B026A
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 21:17:48 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id r6so276033oib.6
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 18:17:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8nbgoaA9t+VRRLs+GjQMqxqxNpifdpztNtP3T59dnl0=;
        b=KuSF5wsQi+EXIvwBcukPQ19TFxtcpUY5GIAChzGCiYEo487+h+z8Fe/wwbWnL8mpR4
         ERUuPrcMpgqYH2JZVPlOkjj5HcUujat0EL4Gp2I3FKHuoz6izejtZJlGdAJutDAFNyth
         cdjHn9EsJf298GCUMg/a177MkaFDsSXX9oYRgDs0TN/sK8D1aXYLUcX5j6N7tGhAnjcT
         M3Ij/HB4IKnBXLS3bfZYD9R5RBioCCkNhoHZQIPxDSfWpHxPdBsTlxzvbIuhH2LRdZ85
         Gf8/Pdgc1prrznDKDxcVO22cyBX85FZboP205WPqz7AlKoScEQDSASbMNmYi0eCP6ATy
         dQbg==
X-Gm-Message-State: APjAAAWZX7M5h5TB9Og+ttqT0liqYlo4fxJnt3YR30heI1DMYvfiJRQx
	NGimSzsGeSmovQt4mVTfaTiZph8KDDfe0M7t2pIcVaknNbVliVG0XR9E2VtoHczYjo5/E8l5Hm1
	nyQYcHfQX4v7VOz5AUAul90AaNJH/jf0PbXaBqyCmQJIcbAOqxdNg++I6cP4Hr0Ih8w==
X-Received: by 2002:a9d:630a:: with SMTP id q10mr10751795otk.91.1560475068027;
        Thu, 13 Jun 2019 18:17:48 -0700 (PDT)
X-Received: by 2002:a9d:630a:: with SMTP id q10mr10751760otk.91.1560475067165;
        Thu, 13 Jun 2019 18:17:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560475067; cv=none;
        d=google.com; s=arc-20160816;
        b=05L9BFRR+M24pFKsx3ddDaqDE1R7GGWj69IXpDOc10tH0k4eRc94HRPMj3xEA++1N/
         uzJovippBJpN0wf9kWy4vQIx0H2Jc2cryuJB24YENFVuLuzO2g/awyAQbdr9wz1SqIp0
         2eLwfLoree7sqAAJrm+QhjAjiKXAJt0HPY4q/bOj61mcs0SuGWr4biqrY01TlUfNUbhJ
         ULPaf1avYVPWle7/0Y84T2gRZ1OwFzaDFVAU9QerfUgfUSyGKPVeOUFW5UX1zog2elBn
         KIkhslzyXOZ0fC75epOTaUy/DKv1vKmBfypEgpMILjdlTBOfUsyE9Yma8Pe9WViuvhH7
         S+zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8nbgoaA9t+VRRLs+GjQMqxqxNpifdpztNtP3T59dnl0=;
        b=t/6mVrMd3x0UpG7tUZkV0C2chCjBLAwBEGN3ukqWoR2RAM6Bgj44Q6DvbgECwifUee
         iVDOX53qchxNnAnKgcsietdsKxyQYHLtRm4ClgtqD407d45feUPBCml6G3p8Me+szAWj
         f+vNYtzkEOu3y4dxMGTvQSA3uBZ/bDO4P1XWuTgq+g9QG5cGOe+uncMjU0TxZili3ejC
         k6f1nEMdJjj23afOZyTNBpEgAbJ7HckVuurZt+w9fCTZ/EZFnUNZL9eq5z9bDjLXfm9W
         zVps/Hgkum7cKpORcQWjfOmh8rxoP35OSNoDcy5EgmONYbLm9GkkaqEVOWQZNQypzJyk
         7rtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=vcKtePLx;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x16sor528296oix.171.2019.06.13.18.17.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 18:17:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=vcKtePLx;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8nbgoaA9t+VRRLs+GjQMqxqxNpifdpztNtP3T59dnl0=;
        b=vcKtePLxEoFUoXy+89bQnDDlZ0mUEPsGWsAYPOgRInH7NilDUDLImYUbNTQhZvJYlL
         3GmJ1IDvfOkbX1aykOjRJzjlrymJucTJ3b89o7Oxq1rDU+qr9udIXor3Ji7DKQKWd5Fr
         vqH0KgpaGote+shp3W2x5LAlrIfKSF8ZpXdS6tOBnfRzUc24Xwo5krz/ZTOD+Ezb0wFH
         N7jTA00CjMa9VcbDY+sL0im8c3B+PmKc1OyqgzGlkFBXOVpXBQk3gvXBPfLtpNKQ8K9g
         iZQtDJLRjtiSv/j3bdtRMTKZs45r31pqFO0qn5vNRQ/HG5uXC/4ny592rMfZkZn6rnL7
         2WVQ==
X-Google-Smtp-Source: APXvYqwnLvLUXAIBseQng2RkfJRQeHEAdwzemebMnlXZNkRFXGIM74a/VpUj/BftE9ogX5hDYp+SuC6GzNHuSRcTVD0=
X-Received: by 2002:aca:ec82:: with SMTP id k124mr222963oih.73.1560475066694;
 Thu, 13 Jun 2019 18:17:46 -0700 (PDT)
MIME-Version: 1.0
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com>
 <1560451362.5154.14.camel@lca.pw>
In-Reply-To: <1560451362.5154.14.camel@lca.pw>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 13 Jun 2019 18:17:34 -0700
Message-ID: <CAPcyv4hYfDtRHF-i0dNzo=ffQk6qnrasRwkVfAVnwgWj0PJ4jg@mail.gmail.com>
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

On Thu, Jun 13, 2019 at 11:42 AM Qian Cai <cai@lca.pw> wrote:
>
> On Wed, 2019-06-12 at 12:37 -0700, Dan Williams wrote:
> > On Wed, Jun 12, 2019 at 12:16 PM Qian Cai <cai@lca.pw> wrote:
> > >
> > > The linux-next commit "mm/sparsemem: Add helpers track active portions
> > > of a section at boot" [1] causes a crash below when the first kmemleak
> > > scan kthread kicks in. This is because kmemleak_scan() calls
> > > pfn_to_online_page(() which calls pfn_valid_within() instead of
> > > pfn_valid() on x86 due to CONFIG_HOLES_IN_ZONE=n.
> > >
> > > The commit [1] did add an additional check of pfn_section_valid() in
> > > pfn_valid(), but forgot to add it in the above code path.
> > >
> > > page:ffffea0002748000 is uninitialized and poisoned
> > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > raw: ffffffffffffffff ffffffffffffffff ffffffffffffffff ffffffffffffffff
> > > page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
> > > ------------[ cut here ]------------
> > > kernel BUG at include/linux/mm.h:1084!
> > > invalid opcode: 0000 [#1] SMP DEBUG_PAGEALLOC KASAN PTI
> > > CPU: 5 PID: 332 Comm: kmemleak Not tainted 5.2.0-rc4-next-20190612+ #6
> > > Hardware name: Lenovo ThinkSystem SR530 -[7X07RCZ000]-/-[7X07RCZ000]-,
> > > BIOS -[TEE113T-1.00]- 07/07/2017
> > > RIP: 0010:kmemleak_scan+0x6df/0xad0
> > > Call Trace:
> > >  kmemleak_scan_thread+0x9f/0xc7
> > >  kthread+0x1d2/0x1f0
> > >  ret_from_fork+0x35/0x4
> > >
> > > [1] https://patchwork.kernel.org/patch/10977957/
> > >
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > ---
> > >  include/linux/memory_hotplug.h | 1 +
> > >  1 file changed, 1 insertion(+)
> > >
> > > diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> > > index 0b8a5e5ef2da..f02be86077e3 100644
> > > --- a/include/linux/memory_hotplug.h
> > > +++ b/include/linux/memory_hotplug.h
> > > @@ -28,6 +28,7 @@
> > >         unsigned long ___nr = pfn_to_section_nr(___pfn);           \
> > >                                                                    \
> > >         if (___nr < NR_MEM_SECTIONS && online_section_nr(___nr) && \
> > > +           pfn_section_valid(__nr_to_section(___nr), pfn) &&      \
> > >             pfn_valid_within(___pfn))                              \
> > >                 ___page = pfn_to_page(___pfn);                     \
> > >         ___page;                                                   \
> >
> > Looks ok to me:
> >
> > Acked-by: Dan Williams <dan.j.williams@intel.com>
> >
> > ...but why is pfn_to_online_page() a multi-line macro instead of a
> > static inline like all the helper routines it invokes?
>
> Sigh, probably because it is a mess over there.
>
> memory_hotplug.h and mmzone.h are included each other. Converted it directly to
> a static inline triggers compilation errors because mmzone.h was included
> somewhere else and found pfn_to_online_page() needs things like
> pfn_valid_within() and online_section_nr() etc which are only defined later in
> mmzone.h.

Ok, makes sense I had I assumed it was something horrible like that.

Qian, can you send more details on the reproduction steps for the
failures you are seeing? Like configs and platforms you're testing.
I've tried enabling kmemleak and offlining memory and have yet to
trigger these failures. I also have a couple people willing to help me
out with tracking down the PowerPC issue, but I assume they need some
help with the reproduction as well.

