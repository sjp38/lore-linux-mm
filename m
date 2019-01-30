Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F676C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:30:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26B712087F
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:30:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JKpyZVHw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26B712087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1D818E0002; Wed, 30 Jan 2019 13:30:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF4328E0001; Wed, 30 Jan 2019 13:30:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E3B68E0002; Wed, 30 Jan 2019 13:30:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E31C8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:30:29 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id w128so211457oie.20
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:30:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9j79+mJlVivCZg8r9eXgCwMYenun/QvjMBX1vH8qwVk=;
        b=MVHrlnKRmO6dumbS9xY6OzjjTBfxyLcTf9ENYN3JSmX7+ADv4nRoF7VnblAoog6pir
         4myG9gFU/oA2Q5/u43QhPd7nDCGPO7Du/VqHqiheXZwFDPsac2zRdtKY0KkbEW4Y54CF
         C+9rwTh96Mu2Nb/3rhEcCcez3ZkK9nhwOnid/NJ4I99wfOTPzf/LARFvfHj2yk0eOFEa
         7riMz/p2raXQrMEc4jgMaL4sjr1clMyKXhjV/UqeBqCC/kpVmNXNm2bl+L6byXODo/du
         9nK5uNltYiPzL8J/AudgFNQQlijzJEJQB5l1Ep5YF0mBjnrfSHkTslttXO9t8/0dZw/q
         4foA==
X-Gm-Message-State: AJcUuked17cLFB6yBjvQzTDYEdT0iVcv51wRbaLl82o7gasoWJWNLQm3
	aCDEOpjkrhP9ofP+cHH1h6Gdh0e531HsDAYSdaTn7owwi7b1q22a7ASjYyGAvotP3FX96iKa/qK
	0Cq85oDkzGv6hTCxj+bl0idjIQc9TDfN3RCArrw97N/fsiTzYOayGOTBL+PLVi0bEJ2DeMuMmqW
	vM4tnWf+l6DOLXvyX0yCzj/qTThdiKy1iiw5AZRX35ydK3I83Sgojx+rPtsAaHmjmL4TQ34BVeF
	/Crz86TLX9LOWPrQT19aVLcp7CDDAvyOjJfjDZ9V6p2QSdWMfHNMAsK31jqgJPPXlAQd2zLXsgt
	Yx6pOPnr4S4cyGBMzp/nsAbLEbYTeps0H+2PJ24LEf0OdAvM6hhuRXAgQhK3ldRTP0QgkYFdm2B
	L
X-Received: by 2002:a9d:23b5:: with SMTP id t50mr24919363otb.6.1548873029134;
        Wed, 30 Jan 2019 10:30:29 -0800 (PST)
X-Received: by 2002:a9d:23b5:: with SMTP id t50mr24919314otb.6.1548873028131;
        Wed, 30 Jan 2019 10:30:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548873028; cv=none;
        d=google.com; s=arc-20160816;
        b=jt9Vco3/Rrr4HEVcIMO7arS73ZPCziT+pzBLplavhaUfp1CWDnf97B0Mqy3w13S8JE
         1elqghF6XgvYkrHrfZZrb9RChlOmTKRGH5fWTPR543lwbE92GP6fU9bJQ3rdiudSglbo
         hhbdFAVmCYKU45KwSLqKL9ei2M/abjskqhlsBP8BY+SsYtxQV8EloDSHrzHoVnDz+6FK
         1tZWBgFZB6y8cgmz3dYpU4YoLyth3KByz5Q2ZzeY6GECR7ibglg7HsV7fLVQj/kLOxuH
         RPXefqjhc9K976i1mZ5TGCBnNAJknrBeceJUDVifN8cLRAWCTV7+9axk4pRAn6RZfgaJ
         7fiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9j79+mJlVivCZg8r9eXgCwMYenun/QvjMBX1vH8qwVk=;
        b=LTlnW9dfA9wy2puJAn+toKxOI4zVeWJWBeteRmd/jp1U9PldyVCUxtZADZ/NL96qp7
         u/RIpQXrSxzdTrzdk1e9unIqVTICem7x1g2hLEMeloOJ+CNxcnE+OwLzEQbPS8D0z90C
         hbTAIgaWJ5FUss378IXkEgipWo5Z3VFP8XVJWcWGSaiZZeV29TJOm06qmLiF4K2XC95E
         ancrM7gq1seZ+YTZw2hmEkmauLMrLJC7DEEAWM1BeJXFyKAdNyQsQjsnEBd+mPgcldf6
         AhW3Qpg5vVmKlfKbcVIbJd4XljFSIkEZhvkYhvMkO337nyIYpvdCo4ILiyV/TBFeX+OI
         CsCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JKpyZVHw;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor1292632otx.136.2019.01.30.10.30.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 10:30:28 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JKpyZVHw;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9j79+mJlVivCZg8r9eXgCwMYenun/QvjMBX1vH8qwVk=;
        b=JKpyZVHwBzbZoi3xFBOJzn2IbpF802PLabqHWw8ZD026IfIn5OszULaE+vwKkiPb3S
         o/QUb9/hfz1n2Y6gak73YSduWwoX9jik/GbhVfYtK/DSG7mHLVLqgU5vhonAtUF2jow+
         L/38FpMlBqKHRgq6Hjwk5QvfkmtLNTw8xGz2Vpt5n/zOeBgZhvmBRLGfqr4WkF6KlIaZ
         hnQABc+30eTr722VZw3wwe+YZYrwRrWZc/rtNP/K5itYlVAQIxPwxbER+yLhyf6viRHS
         rcnIOmtzVlVFjfhdTF0es0jpUzl2S7LVV+g4hHtsF2yIqjKyHavd7Bmbyp+TBQhRpdsF
         45HQ==
X-Google-Smtp-Source: ALg8bN50PZrZSvg9p519hj+hk5qFch5Xc+sgKgpSmNfdxTt09IU1nK4fd3JVClOirb4JtDKnB6nQh9pcLz+sNphIw58=
X-Received: by 2002:a9d:394:: with SMTP id f20mr22353389otf.98.1548873027799;
 Wed, 30 Jan 2019 10:30:27 -0800 (PST)
MIME-Version: 1.0
References: <154882453052.1338686.16411162273671426494.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154882453604.1338686.15108059741397800728.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190130064856.GB17937@rapoport-lnx>
In-Reply-To: <20190130064856.GB17937@rapoport-lnx>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Jan 2019 10:30:16 -0800
Message-ID: <CAPcyv4jLFQ_ZGqBJK_xaVctMopdhdXEi7BzD=MA_VRucoNhKXQ@mail.gmail.com>
Subject: Re: [PATCH v9 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, 
	Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:49 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> On Tue, Jan 29, 2019 at 09:02:16PM -0800, Dan Williams wrote:
> > Randomization of the page allocator improves the average utilization of
> > a direct-mapped memory-side-cache. Memory side caching is a platform
> > capability that Linux has been previously exposed to in HPC
> > (high-performance computing) environments on specialty platforms. In
> > that instance it was a smaller pool of high-bandwidth-memory relative to
> > higher-capacity / lower-bandwidth DRAM. Now, this capability is going to
> > be found on general purpose server platforms where DRAM is a cache in
> > front of higher latency persistent memory [1].
>
> [ ... ]
>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Dave Hansen <dave.hansen@linux.intel.com>
> > Cc: Mike Rapoport <rppt@linux.ibm.com>
> > Reviewed-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  include/linux/list.h    |   17 ++++
> >  include/linux/mmzone.h  |    4 +
> >  include/linux/shuffle.h |   45 +++++++++++
> >  init/Kconfig            |   23 ++++++
> >  mm/Makefile             |    7 ++
> >  mm/memblock.c           |    1
> >  mm/memory_hotplug.c     |    3 +
> >  mm/page_alloc.c         |    6 +-
> >  mm/shuffle.c            |  188 +++++++++++++++++++++++++++++++++++++++++++++++
> >  9 files changed, 292 insertions(+), 2 deletions(-)
> >  create mode 100644 include/linux/shuffle.h
> >  create mode 100644 mm/shuffle.c
>
> ...
>
> > diff --git a/mm/memblock.c b/mm/memblock.c
> > index 022d4cbb3618..c0cfbfae4a03 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -17,6 +17,7 @@
> >  #include <linux/poison.h>
> >  #include <linux/pfn.h>
> >  #include <linux/debugfs.h>
> > +#include <linux/shuffle.h>
>
> Nit: does not seem to be required
>
> >  #include <linux/kmemleak.h>
> >  #include <linux/seq_file.h>
> >  #include <linux/memblock.h>

Good catch. Notch one more line saved in the incremental diffstat from
v8. I'll wait for Michal's thumbs up on the rest before re-spinning,
or perhaps Andrew can drop this line on applying?

