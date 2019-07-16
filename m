Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F4EBC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 04:33:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED20D2173C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 04:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="s0jW7HHM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED20D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A6BA6B0003; Tue, 16 Jul 2019 00:33:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4314F6B0005; Tue, 16 Jul 2019 00:33:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F87F6B0006; Tue, 16 Jul 2019 00:33:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 003606B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 00:33:41 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id a8so11066219oti.8
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 21:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=mBVLD8FyKgT6SsKBtjQIHWzc2KidSI6XthY/YMB8EBo=;
        b=gGwGZ1L7angWrXh5NoCP1v6T2V+Zn+39xzgRTcb8s6eiEZ5Dad/2iPYi07ipcWraa+
         itiLfiBpH8SF/77DJAPFFQ57XXdzapRshQ76lSj2C42dbYJShWZI8S22dDk45ARHh66o
         0c/jl7MTv+9c9GoZVQCWJCMfkssnNNKtykAtwPnmofUtTL1MsvhTWcZ36RKDJjeyvm6S
         hVozPWbX/N2GAR384xCu4zJnzIB/PNawMQyHQXS94BJH/7KE5IMaT0JDuJdLZszdm1zI
         z1QRxpJ7kl8BY1Mav93nwpHj/ChDRJ1MfaJzLE69XPyhSmRcg36JIBRwycmG+DJtQmEx
         LXPQ==
X-Gm-Message-State: APjAAAU3GbSJi66ruPEAYtT0Xvz6IhgWdqbbQpxA+sRsM/yb1rU/0P7b
	6w/uTzhRlBAXBwCUhi35gSk9p1Ab+Gmr2IPJwjnqVYpZq4c+XgFFFADrzQV50B87aYces4aLY/l
	t4gsTFh77mScLn3w8Z9megCDiwybt8NV9gA/nOAWLaKsB9b+SK6awATQgC0VmE2VPbQ==
X-Received: by 2002:aca:4c14:: with SMTP id z20mr14805244oia.121.1563251621583;
        Mon, 15 Jul 2019 21:33:41 -0700 (PDT)
X-Received: by 2002:aca:4c14:: with SMTP id z20mr14805213oia.121.1563251620663;
        Mon, 15 Jul 2019 21:33:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563251620; cv=none;
        d=google.com; s=arc-20160816;
        b=mzZ1UPRPuwnD8IMlckak6rWjDxhDteeUO+5SNvjUcowt8V9e92jYn+Lu+hfmmGVHy3
         EeP9Ir2MHSKiktNuoytxvQ9Q62o47etHpU4XGn8A2hLVajzZcAK4BP2ndqefBy9wTfWG
         2qGKJzRVI/aXh07ZHxjbDyeUgIxEY6Q9EXo4SmWUe8+4JbPCvy8Kog910j7q6Aroobmx
         j46b/fvmQZsSP/gQiD3cik/Kzh8ocVpztMtNmdkbgTIeAkmTkP+TEmsmVxx8Eru5Us7Q
         xv95uBfwcPwFkoZ7Mq8RcpP0gb+RkB79IoBlhSY4/MOEDJ4YWfsA5hDF/WjsMMrCUoJu
         kTFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=mBVLD8FyKgT6SsKBtjQIHWzc2KidSI6XthY/YMB8EBo=;
        b=WZefViCWKBizhUvbSlWmOyc24MxZJnUAS54whmD5ZuSdyl1+rDgwu6I4cSnWr2ao2Q
         3pvfcCAKSABQpJynPtAIjt3EFLiiX/CgPQHFiXT8j0aHYPcS/tgOS7Z6XsY9HkDAOM4Y
         uXF8KvmWeaquuXeZmNfX9Gb+jIHrZTUwyyWqP+lpvA21FM+SVPADmEHXXOjXX1H6SMs/
         ESOe/ukD1k9GimZRzGEUYs/m0EOE/BcXumBA694PEiojV69OAk1p/1em9wzYgUg0YyZb
         EeyJVONSoaklf5TK6yR8Z9LJ9ep6XxvpXGT4s82llfI2bgRaNdyUb707n7Vhj0iEtdpX
         CNfA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=s0jW7HHM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q131sor8617591oib.29.2019.07.15.21.33.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 21:33:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=s0jW7HHM;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mBVLD8FyKgT6SsKBtjQIHWzc2KidSI6XthY/YMB8EBo=;
        b=s0jW7HHMZZ06Pnd+l+c+Nga/bKl9JGwArhxxRfJ5+xwGF1l1jKEd98wa2C6K7uUUa8
         gPZHfXh2pDZpwK8Zrv6fhTGWRTm0nn+G0vaUXB5EMz+XUAKYKqeo/2yuF1OWOm8ZM6Xk
         9lw+3yq/bZfuBuCbHjoNwDxwmJP8YVVfT6k02SEHztTIWZL25CK6sk1tXagVmXYbwDhK
         GML9sW9uHhMKiNXyHGcZh+qVG3P10D1BnLYtBQ3rzN6HzdAr/PfjlXm7wxmDRqza+dMz
         9OPgdFdB9GXn/YlNtV9ZbyVVPQxo78nnYIoblnoTz+IbB7UyEPaxt2+C6WoZT3p9KEnO
         o8jg==
X-Google-Smtp-Source: APXvYqwdAs273+zThaXtnthQnsSuA9ZucHUwlLKNfCaVtbLGHxXDRC+l4/3o+aTsLW2iF/B+6rqVusxTGhsI9bWaQGA=
X-Received: by 2002:aca:fc50:: with SMTP id a77mr15055837oii.0.1563251620193;
 Mon, 15 Jul 2019 21:33:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190715081549.32577-1-osalvador@suse.de> <20190715081549.32577-2-osalvador@suse.de>
In-Reply-To: <20190715081549.32577-2-osalvador@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 15 Jul 2019 21:33:29 -0700
Message-ID: <CAPcyv4hT6w_=-6AVPvf24=bGJUy=XTOSjNeZ8b56r=Uukpiz8w@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm,sparse: Fix deactivate_section for early sections
To: Oscar Salvador <osalvador@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Michal Hocko <mhocko@suse.com>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 1:16 AM Oscar Salvador <osalvador@suse.de> wrote:
>
> deactivate_section checks whether a section is early or not
> in order to either call free_map_bootmem() or depopulate_section_memmap().
> Being the former for sections added at boot time, and the latter for
> sections hotplugged.
>
> The problem is that we zero section_mem_map, so the last early_section()
> will always report false and the section will not be removed.
>
> Fix this checking whether a section is early or not at function
> entry.
>
> Fixes: mmotm ("mm/sparsemem: Support sub-section hotplug")
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/sparse.c | 5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
>
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 3267c4001c6d..1e224149aab6 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -738,6 +738,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>         DECLARE_BITMAP(map, SUBSECTIONS_PER_SECTION) = { 0 };
>         DECLARE_BITMAP(tmp, SUBSECTIONS_PER_SECTION) = { 0 };
>         struct mem_section *ms = __pfn_to_section(pfn);
> +       bool section_is_early = early_section(ms);
>         struct page *memmap = NULL;
>         unsigned long *subsection_map = ms->usage
>                 ? &ms->usage->subsection_map[0] : NULL;
> @@ -772,7 +773,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>         if (bitmap_empty(subsection_map, SUBSECTIONS_PER_SECTION)) {
>                 unsigned long section_nr = pfn_to_section_nr(pfn);
>
> -               if (!early_section(ms)) {
> +               if (!section_is_early) {
>                         kfree(ms->usage);
>                         ms->usage = NULL;
>                 }
> @@ -780,7 +781,7 @@ static void section_deactivate(unsigned long pfn, unsigned long nr_pages,
>                 ms->section_mem_map = sparse_encode_mem_map(NULL, section_nr);
>         }
>
> -       if (early_section(ms) && memmap)
> +       if (section_is_early && memmap)
>                 free_map_bootmem(memmap);
>         else
>                 depopulate_section_memmap(pfn, nr_pages, altmap);

Reviewed-by: Dan Williams <dan.j.wiliams@intel.com>

In fact, this bug was re-introduced between v9 and v10 as I had seen
this bug before, but did not write a reproducer for the unit test.

