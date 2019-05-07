Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C88BC04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:38:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA70420825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 20:38:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="n2cLf9Qv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA70420825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49E8D6B0003; Tue,  7 May 2019 16:38:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4505B6B0006; Tue,  7 May 2019 16:38:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33F1E6B0007; Tue,  7 May 2019 16:38:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0787E6B0003
	for <linux-mm@kvack.org>; Tue,  7 May 2019 16:38:56 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id 1so1436979oin.3
        for <linux-mm@kvack.org>; Tue, 07 May 2019 13:38:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6pfRHejW3cZFOE77y3IUUX4go4AGbYiRoY6juBt94WE=;
        b=cH2ZhDxx9pE8Ox+jhq0hMaU8ph0p32JQ8Htdw6ltkJ9ugCk0fr5fM65+32vmD+wmJz
         hrLOia8G+9JRfRept2Gy9c24URj2S9nrJ5E7hIxnp6/A/Ml5sduLeVZvIj5GdwAagw6Y
         5zKxz/y3/yLETwjTIGp1s3S5/CggO1KM7E4WBECdQKa0wUuzh00MEq3ha0TGldxo9zIY
         mlkQRjIPLlXhlSKv/XoBTvgd7GHPqaXoNIQuWIgD2H+gPBGLtngQCipqZRRv14vhfoH4
         z2jnPseb5Y20ziHACo19WW+sdLt6x5Fy9oFwnr1KbZuA15dqHFnPwVTlNYuXl/yBwjgi
         GjmA==
X-Gm-Message-State: APjAAAXn30Pn9jfxZ8lPFJnkFoMUpZLabrj2gg9W9cmQ/MEzqxRZGWJx
	UdUCxWcKuVV7gVIGnI+P1oMDs/6TUIMIxwywYYQc3Hxs98xn+rYPbw2NXFc1H781CwICEMNu95+
	PjoE2KzdYISPzf9Lak8A6rRXHRkesNvsNg5Mgj8itKqji5ZWoEWlcafuTtr+I+hdObA==
X-Received: by 2002:a9d:7346:: with SMTP id l6mr24155568otk.139.1557261535721;
        Tue, 07 May 2019 13:38:55 -0700 (PDT)
X-Received: by 2002:a9d:7346:: with SMTP id l6mr24155538otk.139.1557261535058;
        Tue, 07 May 2019 13:38:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557261535; cv=none;
        d=google.com; s=arc-20160816;
        b=AnVLKHXT6lhd8Hr5deNh+IRr5CmScIovjFY2Y3sWtWC5r2lEc4zeUwIp0GufYPLT/V
         UTIA3wm+DmwTDNw9CIMz+GLlJakM4wZ/VnYLmDtl7QW6ijNqKqd68pXmyaru2DkjGphc
         W3MSiwEKzwYRDru5aJuhztJ+HZrRjgOLVYH8bwafIvTzu6jg+c9PsUf3pHie54cqKJhn
         mcp6JowX5XcnjQcRUMU3bgSlpHUKUMJuC0O2y/07z9eEjBldfYQdKcF+FOHpzSG638OZ
         qpTDzYHPueI3gcFMzIMMHWehwgyp9EKD7ezgKaYuP71MJUQevq7Eq+nZnm2GGOxwIz9k
         wcXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6pfRHejW3cZFOE77y3IUUX4go4AGbYiRoY6juBt94WE=;
        b=mUtkFugmlussM1AdXR06kERFlTQ0aZ8AdY/dyL0cPm2RA2cIl4n5FJC/QFoK54m3CC
         FYOOy7aUjoGuZuTfoSp6DWR5B6ElFhY8+pr+OKKCGgC/9/EMp9LwmXEBEzUduv4e/P8A
         6Lea5nC9AnN1OPp0vd5hQyGyZsSwC7cIQeH4MO3gU3/akbyTps2Mzo/bWibcfCJzuSSC
         jjHLna33Fhb+lYo0OEEJQW+KstfUX9BxEJTh/IJ1FCSSEQ0Uujn9Hj/ixlv/NbiuWHWL
         oJlBu7/fbGYSKS94PtWZK7aV9lzWVo86AsDAFWBWq2rTFIN6t3cXptK5YtFaS8+4D4W+
         SgSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=n2cLf9Qv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor701248otk.42.2019.05.07.13.38.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 13:38:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=n2cLf9Qv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6pfRHejW3cZFOE77y3IUUX4go4AGbYiRoY6juBt94WE=;
        b=n2cLf9QvpatFw6Fx6Im50C3lqxaAWG43jr2hC2ev1xZpfJ6J8FUzxhXEUavTl94SZm
         SVHlKHKIcM/ZhfovCw4MijKPgzW/E+HLz4qZ175x7tfNV+dQC05A0tETwYssL7clan9W
         UsEpcZNB+TJeQSbZEqorEcfiOUdbu+Sy8m9YAZ3S+el0grhl2bD78JddE66O4Q+1avuY
         KR225hZ12kjGn4PRHpeZLqKoFnuS+tJCq4z76VyCpIv4O/vr+Au5mfwKYyPGTxiEapDr
         R3GKFkX289EisuP8nBoU3VOoPxvd3l0FVJ+ulJz6IltOlc4nobKQXXstnEsx5ZFdmsTb
         rEdA==
X-Google-Smtp-Source: APXvYqyoyS46mGkeS8xfe2+s5llXVwHTTrq4TjXi1ZN6I2Su0aHjvxJMNj2Psjrwn9yCamOWlD6+DD7mFrLZ6kZfD1Q=
X-Received: by 2002:a9d:5cc1:: with SMTP id r1mr21322434oti.229.1557261534468;
 Tue, 07 May 2019 13:38:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190507183804.5512-1-david@redhat.com> <20190507183804.5512-2-david@redhat.com>
In-Reply-To: <20190507183804.5512-2-david@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 13:38:43 -0700
Message-ID: <CAPcyv4jCtOYLCtAhRPhGrHZKyvHZmE8i1aGsRRBWk+G0v4EGAg@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] mm/memory_hotplug: Simplify and fix check_hotplug_memory_range()
To: David Hildenbrand <david@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, 
	Wei Yang <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, 
	Mathieu Malaterre <malat@debian.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>
> By converting start and size to page granularity, we actually ignore
> unaligned parts within a page instead of properly bailing out with an
> error.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Dan Williams <dan.j.williams@intel.com>

