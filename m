Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DE13C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2383E20C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:35:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2383E20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9791F6B027D; Fri,  9 Aug 2019 12:35:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 929866B027E; Fri,  9 Aug 2019 12:35:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F0B46B0280; Fri,  9 Aug 2019 12:35:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2CB6B027D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:35:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id r15so10746084qtt.6
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:35:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=YhvrJzpR4+4p7WCerKoitdUksf85FlotCeHMjio/X+0=;
        b=NqRlBnL9yFaeeVyl6QrD3OkoJ8nSpHjG6ahA5vHzcJJBsVxVCRTX/XPuiTFpghujzr
         dKi1c4WuzYyI90e4cr2T7Y61t0Zs+2a1pP2dfstS4v81cNpRBxB+YB4KuiHDryshQQWs
         nzSdK+WnIDn782xsMUfJyWgpMoALe/x1m+8C6xS8tfDCoBMM7YIsjyEeLXIDH8D5MbIc
         jSQ+d+okkHvBj38Y+R3Y1iz1xuWOu5djQkFf8yjTg05jyjCjIZCtXrC2wg994LE/1MBg
         SCLstkXKoYhNH6FoQNJvoELxJF+xujkGqzW9s9FXAN8zgkHEhbF9tb7m2YfZK1FSZmlk
         WDKg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWLBqEyVKQgDWiupttaD107ngs1t9YjRg/rDxCrLcRaVwNYk/Ci
	MNVmJbq8517W5CfS3Wo9iwR/FEQ2Ui6Ybna7o3izWjMtReI9xt3f2JWyg8ZYmq7g7niIoHTfGsr
	NuFoAvochM2DOpPyHZlMrsPtllK0yB180vMErnoe9TUUtWe3nDtC8Z/uW2rtXQN1icQ==
X-Received: by 2002:a05:620a:1242:: with SMTP id a2mr2473031qkl.480.1565368556137;
        Fri, 09 Aug 2019 09:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHO5UYH8v1sm+p9L7MMYb/O59migkhdqkkn0I7TV2h5QnfG775t90nSIMpc1T5HLDImCl7
X-Received: by 2002:a05:620a:1242:: with SMTP id a2mr2472984qkl.480.1565368555517;
        Fri, 09 Aug 2019 09:35:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565368555; cv=none;
        d=google.com; s=arc-20160816;
        b=JX3+yNF3ZCdYOQrCCib2aqhBteRSObPhlRq2vAzZh5dyYxXLSwdz+cvdEz0j+76dXe
         yaqUq51ud2oda2nfGSFpNcQ1PB/KBiEyJRA4sXjF2/Y/7u2qx0eCxEjGrvHxjcZiEKFZ
         zvYCNeMXxGAsZsXg//CbOCa62u2N/zALthgCPNcic1TkKkWKAo7+MAKv/XdbmG+cJRpp
         x48kp0Z5oesgvXCttWpCg6ptP1mB41jkIbXv7h1xaG4DU87mJW8854jxtwK1T4jNUGPq
         nadkJetrP7InryW0HXq0ciuy61pVXrOrgPudGYIKRzDIRnabRGcftsd8g7YR9N5sAyPG
         4y9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=YhvrJzpR4+4p7WCerKoitdUksf85FlotCeHMjio/X+0=;
        b=okRrHIlInW07e/DgO3jarKd6sVhcPGhiJNaf9caHe5pyRcWLFlAdwFD3VIcobXgjKK
         S6S7SlkK+rKlJ5CqFaqPIV0aL3yXDDcvmdChCkyGwFT+PdwtBs6LFj/tzXCN+CDLAC39
         /rWztHYLrjyM2lpUfDV5bQTeo5yTP36DS1MZI9HLs93s6if4vM5u1JiEGmBxXTh0wIY8
         4AroLfTShLUai19IDMIerLuKB4HBfczWFIkKJu6ijVkH5SyM98BJzbeG1fE+/OMdEZ/m
         3C0aRWmeTRN/Fm1Ns7K/MZuURVGwtkH2RqPWVzy+00AWlVTalBD2BtTyxKAI+Yd75wW/
         F8qw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w50si11741729qta.271.2019.08.09.09.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:35:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BEBED300BEAC;
	Fri,  9 Aug 2019 16:35:54 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id 00E1B19C70;
	Fri,  9 Aug 2019 16:35:52 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Fri,  9 Aug 2019 18:35:54 +0200 (CEST)
Date: Fri, 9 Aug 2019 18:35:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"matthew.wilcox@oracle.com" <matthew.wilcox@oracle.com>,
	"kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>,
	Kernel Team <Kernel-team@fb.com>,
	"william.kucharski@oracle.com" <william.kucharski@oracle.com>,
	"srikar@linux.vnet.ibm.com" <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v12 3/6] mm, thp: introduce FOLL_SPLIT_PMD
Message-ID: <20190809163551.GB21489@redhat.com>
References: <20190807233729.3899352-1-songliubraving@fb.com>
 <20190807233729.3899352-4-songliubraving@fb.com>
 <20190808163745.GC7934@redhat.com>
 <48316E06-10B2-439C-AD10-3EC8C86C259C@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48316E06-10B2-439C-AD10-3EC8C86C259C@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 09 Aug 2019 16:35:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 08/08, Song Liu wrote:
>
> > On Aug 8, 2019, at 9:37 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > On 08/07, Song Liu wrote:
> >>
> >> @@ -399,7 +399,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
> >> 		spin_unlock(ptl);
> >> 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
> >> 	}
> >> -	if (flags & FOLL_SPLIT) {
> >> +	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
> >> 		int ret;
> >> 		page = pmd_page(*pmd);
> >> 		if (is_huge_zero_page(page)) {
> >> @@ -408,7 +408,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
> >> 			split_huge_pmd(vma, pmd, address);
> >> 			if (pmd_trans_unstable(pmd))
> >> 				ret = -EBUSY;
> >> -		} else {
> >> +		} else if (flags & FOLL_SPLIT) {
> >> 			if (unlikely(!try_get_page(page))) {
> >> 				spin_unlock(ptl);
> >> 				return ERR_PTR(-ENOMEM);
> >> @@ -420,6 +420,10 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
> >> 			put_page(page);
> >> 			if (pmd_none(*pmd))
> >> 				return no_page_table(vma, flags);
> >> +		} else {  /* flags & FOLL_SPLIT_PMD */
> >> +			spin_unlock(ptl);
> >> +			split_huge_pmd(vma, pmd, address);
> >> +			ret = pte_alloc(mm, pmd) ? -ENOMEM : 0;
> >> 		}
> >
> > Can't resist, let me repeat that I do not like this patch because imo
> > it complicates this code for no reason.
>
> Personally, I don't think this is more complicated than your version.

I do, but of course this is subjective.

> Also, if some code calls follow_pmd_mask() with flags contains both
> FOLL_SPLIT and FOLL_SPLIT_PMD, we should honor FOLL_SPLIT and split the
> huge page.

Heh. why not other way around?

> Of course, there is no code that sets both flags.

and of course, nobody should ever pass both FOLL_SPLIT and FOLL_SPLIT_PMD,
perhaps this deserves a warning.

Not to mention that it would be nice to kill FOLL_SPLIT which has a single
user, but this is another story.

Oleg.

