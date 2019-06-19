Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 525A6C31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:40:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1AD0920665
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 03:40:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="BQ7vWgHm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1AD0920665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A63C56B0006; Tue, 18 Jun 2019 23:40:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A47628E0001; Tue, 18 Jun 2019 23:40:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 951168E0001; Tue, 18 Jun 2019 23:40:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CA4C6B0006
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:40:48 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id t198so5779033oih.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 20:40:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4V43vNNP9UR/YMy0iUrU7kUuUwSqcmG602S5hpOD5NE=;
        b=WlSRsbkyMcxd9VhyHrwjzpxB6PLh24tkS07MyRCvFPzTDyY3g/el9M6SJPN71Ubja0
         vCSY7yQstqJs4F/sKyoeR1ZcLORxx3FIygbiz5PKTqxKKVxwjls5Kp+UTKO4i/Rtza9/
         AuEgrGpF57hNqNiw10C0tQG1hYkCvLe+UG5UnIjCmRvQBnlGOG0vhQUwHUzpobzdCCxq
         NCOdq8nrLAiRPjcJ1CYDg4czQc3Md/fxtcEPQH2qTwlMbERClAOk/cOdXY/gsJVu6jUq
         but6G8ORKO7t4Z5uL9mWDVmsacBHWBUdtNIwfRvU3d+T0lo7sCtx4IkRlAxO46y/l3C0
         zRig==
X-Gm-Message-State: APjAAAXz7atT/zhR5h+Opp+0WmIzWdnHDNr32GIz2+j1auIyhMG29aXS
	R5SWpuy8Gb73eBETPVwLGd0t3l0X4ObYX0EfIMNDzu8KYej6BTUO1FM+3lNlcyE/wYzGm+P972n
	elMNpqeTUmbJwA/EfiyDGKfk2FhJF6zXEyDteRhfp6ZBmEJOIuQv4nJSX4pEhs4iFjA==
X-Received: by 2002:a9d:17e3:: with SMTP id j90mr16598449otj.314.1560915648085;
        Tue, 18 Jun 2019 20:40:48 -0700 (PDT)
X-Received: by 2002:a9d:17e3:: with SMTP id j90mr16598434otj.314.1560915647579;
        Tue, 18 Jun 2019 20:40:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560915647; cv=none;
        d=google.com; s=arc-20160816;
        b=inBXbdZ4cZ9PzqiywwpqXTMJtwlFDy053dcPdajxH2Qr8n/PrBovvRNIvLnBOApz+N
         Dle4Z+4jp0+UeeW1TGPktSkSVFx2NrYMLIq9biJgTErbYEBiOG+23y41y6Pm/lhvmjd2
         Dho7SuIFxdoyrgovkaX95jvGcXcvl0yzXTMOpVv+jAZuWo5JgLY4yzokwwUQQ+CpHD2B
         n+nQ0MmPTzWF2WQN1/80qkHaHCs0TCGKq0uh61xufxy7tXPTAW1lKjuNm+iGRXZmrOy6
         dXa75qWaRvABw5hXVmNm9sMeKqrG1aKFXz4twTLtd8lCmp+/RI3g2q1gAgrtem7WTjqB
         N45g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4V43vNNP9UR/YMy0iUrU7kUuUwSqcmG602S5hpOD5NE=;
        b=V9NrzTY7F5aNM0L9LyGVY/agOffREUoracLBnOhq/VA28ARXilaQPu8AbckCCjT3kG
         US0kzhV+xlgbD6wdQKu+54SJoXRIUhmH7sophzx3uWM35Eeh9TqXKo7hvHx64pRQeBvp
         i81tteuNJ/0ONaF/WT9eNzkU4YrSby26dP1gsSlXDfcV2Uxxz37PwrQncW2ptzdCobjj
         sijmKMYIStAd/2zJ/FtaG6EfraBsa5K4qiwbJLfVP6wveZ3/ajEeSdeJcuM7nS7u1tTz
         6ARYMKhEkie/yzX8WTLqDnVghr/2lfR+XM4rCmSl4iUJJja0hLfF+21zkOqGto0xTVed
         eh2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=BQ7vWgHm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor8321613oto.26.2019.06.18.20.40.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 20:40:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=BQ7vWgHm;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4V43vNNP9UR/YMy0iUrU7kUuUwSqcmG602S5hpOD5NE=;
        b=BQ7vWgHmVXoWfX5W8xsL12ik15mXugB0SaJil+xQI3I0WxyylMDSZVjeFIBqrMpPVJ
         Tgiut3d49qvcxdiNlr/Wuqhf5OYmZDTD6pJsL4uc8B7AvZ8wwh8aPM4n71HSolE5Oxc3
         FA9Ld6qDcf1gl5dm9y3qsfehBHljHi5HXuDdd7/icxI+t/oHdrlAmeDiUP/Kmr+DiaXd
         ygMke+1L3EJ6jv6Or7J7ka07JnJyzYJ6usnlq/hrYPaTv2PCenHPThlG9fXMEyQo3ktq
         qYnDyLZfzEglV0V7mhDK4JYNDdtBeedbRy3nXiodLZw2O63uvgAs/frjTUrFddu2fdwk
         1G9Q==
X-Google-Smtp-Source: APXvYqzSIN9dPRssFnDKf+ysKlqbDab6DghA3P8E1YBeqgXp36cJF4wdWJZxF+5DmxoFz1Yx1IYT0Jk4KmWR0apXjnU=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr59223453otn.71.1560915647227;
 Tue, 18 Jun 2019 20:40:47 -0700 (PDT)
MIME-Version: 1.0
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155977188458.2443951.9573565800736334460.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190618014223.GD18161@richard>
In-Reply-To: <20190618014223.GD18161@richard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 18 Jun 2019 20:40:36 -0700
Message-ID: <CAPcyv4gXzNgghUq337foa3ywB0R4g1e1atnXX-=KJCjCacv0TA@mail.gmail.com>
Subject: Re: [PATCH v9 03/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
To: Wei Yang <richardw.yang@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:42 PM Wei Yang <richardw.yang@linux.intel.com> wrote:
>
> On Wed, Jun 05, 2019 at 02:58:04PM -0700, Dan Williams wrote:
> >Sub-section hotplug support reduces the unit of operation of hotplug
> >from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
> >(PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
> >PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
> >valid_section(), can toggle.
> >
> >Cc: Michal Hocko <mhocko@suse.com>
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Logan Gunthorpe <logang@deltatee.com>
> >Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> >Reviewed-by: Oscar Salvador <osalvador@suse.de>
> >Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >---
> > mm/memory_hotplug.c |   29 ++++++++---------------------
> > 1 file changed, 8 insertions(+), 21 deletions(-)
> >
> >diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >index 7b963c2d3a0d..647859a1d119 100644
> >--- a/mm/memory_hotplug.c
> >+++ b/mm/memory_hotplug.c
> >@@ -318,12 +318,8 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
> >                                    unsigned long start_pfn,
> >                                    unsigned long end_pfn)
> > {
> >-      struct mem_section *ms;
> >-
> >-      for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
> >-              ms = __pfn_to_section(start_pfn);
> >-
> >-              if (unlikely(!valid_section(ms)))
> >+      for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUBSECTION) {
> >+              if (unlikely(!pfn_valid(start_pfn)))
> >                       continue;
>
> Hmm, we change the granularity of valid section from SECTION to SUBSECTION.
> But we didn't change the granularity of node id and zone information.
>
> For example, we found the node id of a pfn mismatch, we can skip the whole
> section instead of a subsection.
>
> Maybe this is not a big deal.

I don't see a problem.

