Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED4F9C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 04:34:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EB69217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 04:34:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Occ+ZVvn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EB69217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E71576B0005; Thu, 25 Apr 2019 00:34:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E21A56B0006; Thu, 25 Apr 2019 00:34:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE90E6B0007; Thu, 25 Apr 2019 00:34:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A05236B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:34:02 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id f11so11945313otl.20
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:34:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=jJtlgM+LwfAvNu2EDOj4s3A18h6lrPGqDuRQRlrYCbc=;
        b=QAwzxpIfsN9C2m8Zl+BJUcLacXZXREXyHfrb5BThQURTliWWJc2PcEOdk5jfl9xk3z
         Q3nQ7arGZJWeuQJ8tL8HSFbssmbPiMFW2xB54Q6N8B/9XRVIqIvfSWDXnIaWRgAnQnO5
         msNU4Gl3wC0chGlPLzCppdvEB3PirXa3doGQhq0GIJMGlVUItGyNDStAgEswfEWVg2Gt
         WQSSoZWzubi9KWC3ofrEexMwcyxgTjgzM8ucCnddLM8X1kSKKOX4z9fk3X7VIZn280n2
         JQSI8KvOMHeW3zPikFF5jm8GdVQE15/SSVNNLsxa534TTdT2KwqXT+XEstRg3Zh9cOZY
         43cg==
X-Gm-Message-State: APjAAAVzUCE9P304zuPr7izRYVpTbBVEENqFNq9A/ciDA43jnY1V4lVL
	ipJyWVPUvP5aUVQ+upkSFEAjUu0OniNpL1LyL4sT18iy11zIgq/BGSObnp8Lva1uAQqQGo4EWh/
	+coEhR7+WwwAW3s7jYTsHV7w5QKrp1OauKiB93iVRDFokB2AbokXIvGU9IYRPgHKMhw==
X-Received: by 2002:a9d:4d91:: with SMTP id u17mr17924499otk.356.1556166842222;
        Wed, 24 Apr 2019 21:34:02 -0700 (PDT)
X-Received: by 2002:a9d:4d91:: with SMTP id u17mr17924457otk.356.1556166841261;
        Wed, 24 Apr 2019 21:34:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556166841; cv=none;
        d=google.com; s=arc-20160816;
        b=w1QFRtDOgJWTOQ/99LUoGY4AFYxPaHRcR727baU598FNrkPvDtBZrF/7kwQ1pIERIJ
         z17zeQujiRQ40wX20l7GRsij+uOxhETEyU25toplUqZ/szTGeNUiNGM7WTnQgXTHq720
         b3I3KfY3B4RVg9Vzz2+1EJHoTBdjxaztzdrS+I3gfafHoRp0r/yzi63H4EA3G8vYzNdN
         2+h7YNwgADo2WmuHW+0wBE6TydXEwr8G5oKgLb41FwkrTYKl+OaMqwqC8agEYTLBz84Y
         B62VfuP3dRFo27saoSp4DCq5gUA90bbqJhFhbKPhrRFsv1NxQM/aBCW9MWzy3VLIlp+q
         Q+nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=jJtlgM+LwfAvNu2EDOj4s3A18h6lrPGqDuRQRlrYCbc=;
        b=QZ5rXQIC2XSlatOuloOsEJCJhJP2jhfArXY2nWzrbFUU0mW0ZbcBoWGz+H7TieGFyf
         cGACRcH/mkBmh836rjv9EbO16urBcfORsw9xz8Pb0ilaT5umHlYF7DL/RbRbmxBWEaFy
         r6THsvuW4aVGdXJnpx/oE9Vffo1L091ckpvZq5QS6yLXpMTGkQjrvbN7HOtFrs+41nCj
         YEuwOmSmFi4BbrK4wL34CqY+plGIkwzjOsPFwhQEfbheZ3RxEEe5ANoTwOiaRVA/G91n
         MOsOjilcR3BS+FCUFxLYj+4bRwST/YN6pjUw9rUAFa4atJ+T/r8Zh/rjrBPi3S5Cke+T
         md8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Occ+ZVvn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q63sor9572966oig.92.2019.04.24.21.34.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 21:34:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Occ+ZVvn;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jJtlgM+LwfAvNu2EDOj4s3A18h6lrPGqDuRQRlrYCbc=;
        b=Occ+ZVvnra0nOKbAXzS/qYzJINSE/JVG8Gm5SbhA3iX31jg0J/gz91Hh7K4tzFENwo
         7ZNjfnL0zwM7Fie5yIU2/mGcD5/Rx5LNy1kREspLapy+AWMB9zWO5O3uin8BAjpDZmah
         K/uSqWRZz1EhT9WzAyyDEOW4/VFjSAsFoC/yBvWRHB8cVVABJbBDZnBxK9BzXLHQzsSr
         5bQwW4tn5dvOnhHmoTpCGYBdc8OfjLHTf8ekfo+O6k9byftz+zs1L6QaW+97Tp95mdw9
         w/jJuFE7b64TJXdR9mUgeImjxKCS31YpCOSYHGlFhCCTKwhABoy50ex+7HRCHA+gpGh9
         R+iA==
X-Google-Smtp-Source: APXvYqx4X1rED4ag/iCBqdoQfuMFALGSYZtppDpW7HxJZCfMthGgpn5KlRxa9nhY2r/51Mm2aPykjEFyhXiur/X1vYc=
X-Received: by 2002:aca:d513:: with SMTP id m19mr1852513oig.73.1556166840821;
 Wed, 24 Apr 2019 21:34:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190402115125.18803-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4hzRj5yxVJ5-7AZgzzBxEL02xf2xwhDv-U9_osWFm9kiA@mail.gmail.com>
 <20190424173833.GE19031@bombadil.infradead.org> <CAPcyv4gLGUa69svQnwjvruALZ0ChqUJZHQJ1Mt_Cjr1Jh_6vbQ@mail.gmail.com>
 <444ca26b-ec38-ae4b-512b-7e915c575098@linux.ibm.com>
In-Reply-To: <444ca26b-ec38-ae4b-512b-7e915c575098@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Apr 2019 21:33:49 -0700
Message-ID: <CAPcyv4isw_qht_BGUmTcawLD4YYFQVztF1EAn_m8WHKHZcbphw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Fix modifying of page protection by insert_pfn_pmd()
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, stable <stable@vger.kernel.org>, 
	Chandan Rajendra <chandan@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 6:37 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> On 4/24/19 11:43 PM, Dan Williams wrote:
> > On Wed, Apr 24, 2019 at 10:38 AM Matthew Wilcox <willy@infradead.org> wrote:
> >>
> >> On Wed, Apr 24, 2019 at 10:13:15AM -0700, Dan Williams wrote:
> >>> I think unaligned addresses have always been passed to
> >>> vmf_insert_pfn_pmd(), but nothing cared until this patch. I *think*
> >>> the only change needed is the following, thoughts?
> >>>
> >>> diff --git a/fs/dax.c b/fs/dax.c
> >>> index ca0671d55aa6..82aee9a87efa 100644
> >>> --- a/fs/dax.c
> >>> +++ b/fs/dax.c
> >>> @@ -1560,7 +1560,7 @@ static vm_fault_t dax_iomap_pmd_fault(struct
> >>> vm_fault *vmf, pfn_t *pfnp,
> >>>                  }
> >>>
> >>>                  trace_dax_pmd_insert_mapping(inode, vmf, PMD_SIZE, pfn, entry);
> >>> -               result = vmf_insert_pfn_pmd(vma, vmf->address, vmf->pmd, pfn,
> >>> +               result = vmf_insert_pfn_pmd(vma, pmd_addr, vmf->pmd, pfn,
> >>>                                              write);
> >>
> >> We also call vmf_insert_pfn_pmd() in dax_insert_pfn_mkwrite() -- does
> >> that need to change too?
> >
> > It wasn't clear to me that it was a problem. I think that one already
> > happens to be pmd-aligned.
> >
>
> How about vmf_insert_pfn_pud()?

That is currently not used by fsdax, only devdax, but it does seem
that it passes the unaligned fault address rather than the pud aligned
address. I'll add that to the proposed fix.

