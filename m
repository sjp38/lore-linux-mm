Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 849E4C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:25:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 361A020656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:25:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="niDOApxC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361A020656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C6ABB6B026F; Tue,  7 May 2019 17:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C1B476B0270; Tue,  7 May 2019 17:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ABBF46B0271; Tue,  7 May 2019 17:25:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 812246B026F
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:25:57 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id x193so1557241oix.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:25:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=WrWLvelkD+mNuwk6Y9UcbtBZNb2SYcW2Bv4WekgkKa4=;
        b=jEGxxvwjV/9aH9EYoh+MLLGgAm4QaOOHPXZ9yaLdQeOHEVap1++zrBH9IMyqAv+gMd
         aR1dMAw/JPZ0mgK0AjROGYkj4Ku1EO5nDj1ZScMjPcbOl5SAWwLtZv+j2iT49fPcsvwW
         JVCwEz7h7VVMKSodNOvskvbhqeb22CyUR65hV4ZA1/TmVNJglGC3iWY5Z5InXkZFpHKw
         rgdbQ8bzwRfs2wrkV62igyn/abtm7U5kAo1MKBqAVO7UpmRIG8+tJSHeGJQ/VVvZGpEj
         huYahKLvl6l54eNS7dlKlrH0vfAAApNDk7gkCcrHumGaBypf+gvP1c06jXmF0q/eHe6z
         oLWw==
X-Gm-Message-State: APjAAAXM0URWk4pmVYwQZiyCaQRcVrqlCtGh8xDo3/mctGIrc9lqy1sO
	f9RjPq/1KdNIDmgQvbGDixdNPL5gv1C9R1HWX6qJcH9ukAVNArTz2tQU1IwpR3D+Qb7XrfA2TbM
	kRLd+b8nbw9COZvyuEIcSUKXBKrFTtyYhoyXkEHhiU0BHHWtP5dMrJq+XKRNTjo6qkA==
X-Received: by 2002:aca:b7c5:: with SMTP id h188mr391213oif.130.1557264357184;
        Tue, 07 May 2019 14:25:57 -0700 (PDT)
X-Received: by 2002:aca:b7c5:: with SMTP id h188mr391174oif.130.1557264356281;
        Tue, 07 May 2019 14:25:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557264356; cv=none;
        d=google.com; s=arc-20160816;
        b=Ry+95o7Zc6JnCqIawolQMeK4c8x43E7RMclwiwZ7YWOuE+c+XAKqOHxAu3ugDNBLpk
         3Y5T66hioq+S0AYWFCoHmkGnPF3JhOXHyN0nRtpvVV6KD/9ZROEyKC5B0vk/8l1t56RL
         tkcEZAGAtH/BipPtrKjQmnZDuBaDuaavXUAA5Nn6X0G+DHE5QTz7S0AWraeMsIGhhZ61
         VM8w/cd/fwscp3Iz6EeTX82aS+goSSbElFPiBKqhJa+SS1r0ardtkBhmFdm38HHgfnbf
         I2uy5VvWkSEQ03IUYr7flJghYbIyf08sr6sla1izDtngTk/gitTjVDs74Y8WxBZ6mmmH
         2qJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=WrWLvelkD+mNuwk6Y9UcbtBZNb2SYcW2Bv4WekgkKa4=;
        b=YhN88FD2gRU3S4DoWqehckprRrFo2nctvQ9opE9FuCfFp2BxBb00BVV6xctCT3F4Xg
         h4KN8fYBzFhYrrk9ad6tPjgqNFuA7oqEYQ9UWjEFMYyuSpS46KgdTV6/e5xljEYtfUfF
         0DAzOTZzIUHfQrdmK+GjgBPPuPgbKZe341gjxgDc0ojfFs3dURLO4MayS6L3OGLE3Ymz
         kAOWNoqdYizT2JFxvYWQwOMy3A7R5WGKrHMLiEca7EDngGbvV4yFP4gFGk/vXeDBM7GA
         7EMhdIW0Oo1tBxkLWMM6DPDq67SdMssSRJGAkweE5ayngpyanksRRQGQlPCeZOkNfEew
         g9HQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=niDOApxC;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p5sor5955580oih.50.2019.05.07.14.25.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 14:25:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=niDOApxC;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=WrWLvelkD+mNuwk6Y9UcbtBZNb2SYcW2Bv4WekgkKa4=;
        b=niDOApxCFCnbMJ6JJnVXhAHXcDpvPX0VOIgX598FWvGb20NBKEjOLMGunPMCtT8w07
         CCUklL9XVIwM7XeXqt4R3SwqsQHc45UygSnPA7Vo5/Vcu6vZ67h+LQUBL4TP5gSuL9M8
         yOCXLz75NneW+bv+FADtD51VYmKLmjMo3ehqiItMgltR15OKUblt6t5oABGwZobyxZvY
         uoFoyjDvezyaKUeVwPy/0Ey+uAiBGDemhG0P5C7K98cYeXWIsdK4jIuVnW31DT+YwKBS
         axg9qxXBQfbqQqPbEvS+gX/40W5Qtk0I8uy1AfjO2oRgk00fIcb94S9PEZI5nxKZfbNK
         pzwA==
X-Google-Smtp-Source: APXvYqzSvx7ljHyQCsbhoL+yq/IdpsbLQ8T4Uq4lItlX5+hsXeerJKyAq6+adzcHddCXxdDwo8WpxyHJeKyxh7hOkws=
X-Received: by 2002:aca:220f:: with SMTP id b15mr357563oic.73.1557264355934;
 Tue, 07 May 2019 14:25:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-6-david@redhat.com>
 <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com> <d83fec16-ceff-2f6f-72e1-48996187d5ba@redhat.com>
In-Reply-To: <d83fec16-ceff-2f6f-72e1-48996187d5ba@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 14:25:45 -0700
Message-ID: <CAPcyv4iRQteuT9yESvbUyhp3KVVgTXDiGAo+TwPCM_4f0CzBgg@mail.gmail.com>
Subject: Re: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 2:24 PM David Hildenbrand <david@redhat.com> wrote:
>
> On 07.05.19 23:19, Dan Williams wrote:
> > On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
> >>
> >> No longer needed, the callers of arch_add_memory() can handle this
> >> manually.
> >>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Cc: David Hildenbrand <david@redhat.com>
> >> Cc: Michal Hocko <mhocko@suse.com>
> >> Cc: Oscar Salvador <osalvador@suse.com>
> >> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> >> Cc: Wei Yang <richard.weiyang@gmail.com>
> >> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >> Cc: Qian Cai <cai@lca.pw>
> >> Cc: Arun KS <arunks@codeaurora.org>
> >> Cc: Mathieu Malaterre <malat@debian.org>
> >> Signed-off-by: David Hildenbrand <david@redhat.com>
> >> ---
> >>  include/linux/memory_hotplug.h | 8 --------
> >>  mm/memory_hotplug.c            | 9 +++------
> >>  2 files changed, 3 insertions(+), 14 deletions(-)
> >>
> >> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> >> index 2d4de313926d..2f1f87e13baa 100644
> >> --- a/include/linux/memory_hotplug.h
> >> +++ b/include/linux/memory_hotplug.h
> >> @@ -128,14 +128,6 @@ extern void arch_remove_memory(int nid, u64 start, u64 size,
> >>  extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
> >>                            unsigned long nr_pages, struct vmem_altmap *altmap);
> >>
> >> -/*
> >> - * Do we want sysfs memblock files created. This will allow userspace to online
> >> - * and offline memory explicitly. Lack of this bit means that the caller has to
> >> - * call move_pfn_range_to_zone to finish the initialization.
> >> - */
> >> -
> >> -#define MHP_MEMBLOCK_API               (1<<0)
> >> -
> >>  /* reasonably generic interface to expand the physical pages */
> >>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
> >>                        struct mhp_restrictions *restrictions);
> >> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> >> index e1637c8a0723..107f72952347 100644
> >> --- a/mm/memory_hotplug.c
> >> +++ b/mm/memory_hotplug.c
> >> @@ -250,7 +250,7 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
> >>  #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
> >>
> >>  static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
> >> -               struct vmem_altmap *altmap, bool want_memblock)
> >> +                                  struct vmem_altmap *altmap)
> >>  {
> >>         int ret;
> >>
> >> @@ -293,8 +293,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
> >>         }
> >>
> >>         for (i = start_sec; i <= end_sec; i++) {
> >> -               err = __add_section(nid, section_nr_to_pfn(i), altmap,
> >> -                               restrictions->flags & MHP_MEMBLOCK_API);
> >> +               err = __add_section(nid, section_nr_to_pfn(i), altmap);
> >>
> >>                 /*
> >>                  * EEXIST is finally dealt with by ioresource collision
> >> @@ -1066,9 +1065,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
> >>   */
> >>  int __ref add_memory_resource(int nid, struct resource *res)
> >>  {
> >> -       struct mhp_restrictions restrictions = {
> >> -               .flags = MHP_MEMBLOCK_API,
> >> -       };
> >> +       struct mhp_restrictions restrictions = {};
> >
> > With mhp_restrictions.flags no longer needed, can we drop
> > mhp_restrictions and just go back to a plain @altmap argument?
> >
>
> Oscar wants to use it to configure from where to allocate vmemmaps. That
> was the original driver behind it.
>

Ah, ok, makes sense.

