Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AB94C282E0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 23:13:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E673A2183F
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 23:13:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="u3c+KcLK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E673A2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9768A6B0003; Fri, 19 Apr 2019 19:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 926D96B0006; Fri, 19 Apr 2019 19:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8162B6B0007; Fri, 19 Apr 2019 19:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5795F6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 19:13:53 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id k90so3505893otk.21
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 16:13:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IRzO3kj6mXZFzP66LK/VZmTpLamHoofRF3P1lpxxpGo=;
        b=Po5aYF5uGFOXLGafUdDn7CAiL3TNU8Xu0mNA7eZX50ejSK5ZNqoiqq85QVwzjmExJx
         0fsei/bfQlGoolVbiDf0Snydv0rJExZ8cTwGHJwzz0ZpAXIZZTkAbDsoQAOx7ALLB6CV
         LxhDMebSu+tU/c1AGyaohR0II/dCRIb/h8WfoSOrcAhBYENOgw9ZbJgVkDXLceCNeSBH
         4BQSGGjXBabGOPrODwS0XuP0grL4mO9xP97sEuvPoLt4bSk3IWgQ7467Nk5gxB2dujuA
         5RQf16Y46pQ2Cu4QBPsTyd4RwXMziLlxvPG6gI96vmqE5U3Rf/8pfKd/Uv/iH+3NxLoP
         eKGw==
X-Gm-Message-State: APjAAAXuHq1Z6riTmJ0hAG2kWFA0gQp14O0MuFmo+Khg36ObNV0LuLRc
	9AxZPg0E3lS0lWcV5W6IZDaI758CYwjlaLpwRXqlqFtKzGRuTcgJHS0QshZxPZUqutTzN72zNX4
	PfI/RwdERw8wWLELjTQdZcGGRakaVeytdvS8secJyOYH7x1ayXQO/p2sr5P5yTPg4iw==
X-Received: by 2002:a9d:2281:: with SMTP id y1mr3785325ota.196.1555715632824;
        Fri, 19 Apr 2019 16:13:52 -0700 (PDT)
X-Received: by 2002:a9d:2281:: with SMTP id y1mr3785312ota.196.1555715632340;
        Fri, 19 Apr 2019 16:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555715632; cv=none;
        d=google.com; s=arc-20160816;
        b=cAeWojXRQ3c/QSdWCqYGrAN6YJUMZ4IZEVuZcTf+benX2whoW4sChnfOg7XUHWB9qU
         /LfsLM/R9G8682UtwYKnRsw5Ywm1kp/Pvkra5jDE6T3B+I8mPppPBu6J0Nl+JZ1lTubr
         cgEbbyzLp+NwglMZIuq2qBUQJ8mGAOH6FAubiHaPdEMrXpfru2wzEqsXtSaJwEQhTCb3
         7K+/Nw/+RgOkShEM1FY57pMBQ9iGXcEinQSF3gJTl60pIOIfW9rK2DLKuEoX79hf9v1Y
         obJokuRk2REBMqHYraWD2QyPpnmzuy84xU1MLH8aKTP0I3gshc0UuSKhKHOX8k/xI5US
         i79w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IRzO3kj6mXZFzP66LK/VZmTpLamHoofRF3P1lpxxpGo=;
        b=PcVxOMXzXKKev+rT2nRcvyJGRDwy6+k7hnYcVmHEKV60nk1TfWggijkyg/UmBVi/4p
         s50YVrqdYlMvI5NRgaxdwpJFQhpErHtDreIQVfMn8/4bFcVFYMhAliO92EgtamyrBGjD
         Cb7kFRScx2JBPqpSaACUqBVwXJpcVwOt32FCvDcbeOWlaWSsWz59hGRy4oTDBO3w7h27
         Kb19j+xFVE76h+Sox0oq+2DhpquXi//O/xQhNnIXNRSyjht4UbsuPdULVv2R9BGzMHFH
         Uu51O4ukrNAbwJWCCRBIY+tu2PEGi/gRxo617BgBw7PoWth6WF5zPVxEJwOsZnYwwPNt
         5I8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=u3c+KcLK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor2847229otq.142.2019.04.19.16.13.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 16:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=u3c+KcLK;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IRzO3kj6mXZFzP66LK/VZmTpLamHoofRF3P1lpxxpGo=;
        b=u3c+KcLKfuS31rxHOPJxOD+jAkIBsldGNjGasuIi0wgt7f5oKRgsaMeKAnGB2KIsNq
         7uuPfbutEc4z2PWsgoMoylAi/wRziuHnuEV8vVz7OVUoDfM1/cmnzQAOeiHy+As93QkW
         WbRM2kxeKyzLorg6m+qy6nGCBVr0cILsoEt/NP3FQc8oO+pY1RNDg8cX/brf9JMk29WC
         R0eTIcNlR8TqzKAtpd6T/YSGl2w5NsJshHc3TRXpg9xBH8XXDrKhlKIJkNHW5BpFxChv
         go8IMdTQSHIuk76qcPTCXnL5vgM9XcrqQn8exBUc+oHOieBfLjpXBOpbNxnB31HgMo1p
         RtCQ==
X-Google-Smtp-Source: APXvYqxea/pSlbqQQY6zsjv6dAASN05Ch5VZf2vs5gMd48EOK+tb9ggPNRINmdcSMieFjfEJaGDwcTy/eWYwCeif7ig=
X-Received: by 2002:a9d:7749:: with SMTP id t9mr3635314otl.229.1555715631703;
 Fri, 19 Apr 2019 16:13:51 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
 <001f15a6-26bb-cbab-587f-d897b2dc9094@nvidia.com>
In-Reply-To: <001f15a6-26bb-cbab-587f-d897b2dc9094@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 19 Apr 2019 16:13:40 -0700
Message-ID: <CAPcyv4iCg8v2+-qG-p9bruM+CZs3dG-P=q+f5KdKEy3jn4S5OQ@mail.gmail.com>
Subject: Re: [PATCH v6 04/12] mm/hotplug: Prepare shrink_{zone, pgdat}_span
 for sub-section removal
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 4:09 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
[..]
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 8b7415736d21..d5874f9d4043 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -327,10 +327,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
> >   {
> >       struct mem_section *ms;
> >
> > -     for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
> > +     for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUB_SECTION) {
> >               ms = __pfn_to_section(start_pfn);
> >
> > -             if (unlikely(!valid_section(ms)))
> > +             if (unlikely(!pfn_valid(start_pfn)))
> >                       continue;
>
> Note that "struct mem_section *ms;" is now set but not used.
> You can remove the definition and initialization of "ms".

Good eye, yes, will clean up.

