Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85BFDC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 02:29:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EED5420818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 02:29:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="IlHYoGDp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EED5420818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6972C6B0003; Tue, 16 Jul 2019 22:29:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6488E6B0005; Tue, 16 Jul 2019 22:29:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50FB58E0001; Tue, 16 Jul 2019 22:29:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2784D6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 22:29:08 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id a8so12764783oti.8
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 19:29:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Xha1gnu4k9Oy72ln0mL+F+SQtEp2dX0Dej1VFn9Byxc=;
        b=PGqyJ7nVorAoTThMZ3ONExvjjOs+8BnDLtt8GpU6YuEJwXJt5hbDymGUDOSCEA9PMc
         XJs1i3eefQbsIFrksAlau3K+t+i2Xne5tbL3gC47FMv1inNM85WZQuV4L6BJJscYzdw6
         OCPmqMPgZN9AX55LWZH/d7H3XV3NYjdlEM9sk+0HwKNDqYDnLBHzvxAQEUMOtiLqKd1y
         ttSE+G+lJuEqwTDtaVreBURd7O0DrXzZeGVffTTuqjo1QxnNufoSjuRDS1zZJsyRnZLp
         +1pt6l7wVF6hK/U2vZ0rBQI+9JQfqIzaRNqFd2fNINZiX5zpP5N5yefhS4hGHC87r3E/
         D5oA==
X-Gm-Message-State: APjAAAW3om7BCITvTFK3RZqF0Eagf7c1YCJRIYYZ4QIy7aK+v8eEAT3u
	WaIZV6QJauIZWyIgP5Nkk9/xfPNJ+RUmJWnGmUtsKQJ4nI8FHlGtVuNkxW1WAjeSkvuRBqeax/t
	lkBSq5Dd5r2GDkh2bhOdg0OABQV3KJbgoi2QDvRmngME/D6QRs6NsghtvEEQMwus8yA==
X-Received: by 2002:aca:518f:: with SMTP id f137mr16408045oib.123.1563330547700;
        Tue, 16 Jul 2019 19:29:07 -0700 (PDT)
X-Received: by 2002:aca:518f:: with SMTP id f137mr16408013oib.123.1563330546822;
        Tue, 16 Jul 2019 19:29:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563330546; cv=none;
        d=google.com; s=arc-20160816;
        b=RD3QTZp1e4PPUsjthtMDQMe6N1Rte2oCGcGyv9mvfEoMXY3M3mxZLeNBZrle+0Pyjl
         8X4LAgmFV8yJxE1hNC5yCw4fQIWht822/2eRuvW2j2KN40vyiydZ87/yNZv/kQWUFtys
         xwK/Q/qW8f1l4haZB5UN67EP2M0lfpyzqQlnDnmT5UxtlfWHVcm8EY5t6g8uvsDUNM1f
         CUx/sy8KqGhIfh4HbE1OIMOXBlWb2Hdsdai5JabQ2g5ut1eO8UySQN8tzC/ev1U02iz3
         dsgORqMUdYDJLS9jmUhseWgHUCsYReJvvat8Sc2d8267ksCfoyeWqTyuESa73LOrHfva
         MMJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Xha1gnu4k9Oy72ln0mL+F+SQtEp2dX0Dej1VFn9Byxc=;
        b=LKfqv3O71cbUCSa9qEtLjjxihJhge4XnQjzO6TJzZP/rIIYaMo54X+YULr55lYF9Z1
         jk0mrFLg5DDQIf3fLF4OQZ74iXXJW/SdPoU1ioUW/8/TRXURmEWNLa3/sQVze6EAawgB
         0xu5ONHdu0QB4vGNToB8A21Rh3u9NTms7SRYu6yIvjrz+YvAEmz9/Ba0kaRUhrL98E/M
         uGH0mXUUrTOkju5JscRlaAgiFCIf42cvs+ldni0LxjILJYMkvmw2UxOC4PtokAT0BDwF
         V/0jJSqfuj1eWoaUnglhITXa833czckdv8nlA//8h1/rq6ntUBSgOyHbyM5SDVmDRd9Z
         FH4g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IlHYoGDp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i14sor12110585otl.103.2019.07.16.19.29.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 19:29:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IlHYoGDp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Xha1gnu4k9Oy72ln0mL+F+SQtEp2dX0Dej1VFn9Byxc=;
        b=IlHYoGDprQ1xOzWMqON3a05nzYhFYMAfYY+PzndVmhk+L5azjE63rLAzWHCaDuwu8R
         Of4UQD6V2fJDBr9UCq/ZdnKPYgszELTUmF3dTGaKdC3LSbIfV2C/1F2jg8QUJMTvVQ2k
         PgTpQkgwGckGmJQvv+25I++JVfaO/COZAuj6W2UV5YeHvst26QRmfYJ79mYf0NjZKieV
         ovsu2HS+gICuc4kfGK5XDCcJI3pCe8z5+0QrXrt93xDSOIcUTlxxoCstyUToYXmtsDro
         662tsiQbhTYvFUo4yuYzMaURJwgFGLUf3W4Hv2qzgg/iIGG1omBV0rG5wK2641XjyzjH
         rWsw==
X-Google-Smtp-Source: APXvYqxMaFQwJqNDONSbr/N/VaB8L20422JmTVZPiPqGIb8xJFeJh37HfCl+fOz5CxTOl3NTc8LlU1vZPBemm3j1mKI=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr26898798otf.126.1563330546010;
 Tue, 16 Jul 2019 19:29:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190715081549.32577-1-osalvador@suse.de> <20190715081549.32577-3-osalvador@suse.de>
 <87tvbne0rd.fsf@linux.ibm.com> <1563225851.3143.24.camel@suse.de>
In-Reply-To: <1563225851.3143.24.camel@suse.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Jul 2019 19:28:54 -0700
Message-ID: <CAPcyv4gp18-CRADqrqAbR0SnjKBoPaTyL_oaEyyNPJOeLybayg@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
To: Oscar Salvador <osalvador@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	David Hildenbrand <david@redhat.com>, Pavel Tatashin <pasha.tatashin@soleen.com>, 
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 2:24 PM Oscar Salvador <osalvador@suse.de> wrote:
>
> On Mon, 2019-07-15 at 21:41 +0530, Aneesh Kumar K.V wrote:
> > Oscar Salvador <osalvador@suse.de> writes:
> >
> > > Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION
> > > granularity.
> > > The problem is that deactivation of the section occurs later on in
> > > sparse_remove_section, so pfn_valid()->pfn_section_valid() will
> > > always return
> > > true before we deactivate the {sub}section.
> >
> > Can you explain this more? The patch doesn't update section_mem_map
> > update sequence. So what changed? What is the problem in finding
> > pfn_valid() return true there?
>
> I realized that the changelog was quite modest, so a better explanation
>  will follow.
>
> Let us analize what shrink_{zone,node}_span does.
> We have to remember that shrink_zone_span gets called every time a
> section is to be removed.
>
> There can be three possibilites:
>
> 1) section to be removed is the first one of the zone
> 2) section to be removed is the last one of the zone
> 3) section to be removed falls in the middle
>
> For 1) and 2) cases, we will try to find the next section from
> bottom/top, and in the third case we will check whether the section
> contains only holes.
>
> Now, let us take the example where a ZONE contains only 1 section, and
> we remove it.
> The last loop of shrink_zone_span, will check for {start_pfn,end_pfn]
> PAGES_PER_SECTION block the following:
>
> - section is valid
> - pfn relates to the current zone/nid
> - section is not the section to be removed
>
> Since we only got 1 section here, the check "start_pfn == pfn" will make us to continue the loop and then we are done.
>
> Now, what happens after the patch?
>
> We increment pfn on subsection basis, since "start_pfn == pfn", we jump
> to the next sub-section (pfn+512), and call pfn_valid()-
> >pfn_section_valid().
> Since section has not been yet deactivded, pfn_section_valid() will
> return true, and we will repeat this until the end of the loop.
>
> What should happen instead is:
>
> - we deactivate the {sub}-section before calling
> shirnk_{zone,node}_span
> - calls to pfn_valid() will now return false for the sections that have
> been deactivated, and so we will get the pfn from the next activaded
> sub-section, or nothing if the section is empty (section do not contain
> active sub-sections).
>
> The example relates to the last loop in shrink_zone_span, but the same
> applies to find_{smalles,biggest}_section.
>
> Please, note that we could probably do some hack like replacing:
>
> start_pfn == pfn
>
> with
>
> pfn < end_pfn
>
> But the way to fix this is to 1) deactivate {sub}-section and 2) let
> shrink_{node,zone}_span find the next active {sub-section}.
>
> I hope this makes it more clear.

This makes it more clear that the problem is with the "start_pfn ==
pfn" check relative to subsections, but it does not clarify why it
needs to clear pfn_valid() before calling shrink_zone_span().
Sections were not invalidated prior to shrink_zone_span() in the
pre-subsection implementation and it seems all we need is to keep the
same semantic. I.e. skip the range that is currently being removed:

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 37d49579ac15..b69832db442b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -422,8 +422,8 @@ static void shrink_zone_span(struct zone *zone,
unsigned long start_pfn,
                if (page_zone(pfn_to_page(pfn)) != zone)
                        continue;

-                /* If the section is current section, it continues the loop */
-               if (start_pfn == pfn)
+                /* If the sub-section is current span being removed, skip */
+               if (pfn >= start_pfn && pfn < end_pfn)
                        continue;

                /* If we find valid section, we have nothing to do */


I otherwise don't follow why we would need to deactivate prior to
__remove_zone().

