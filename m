Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09A07C10F07
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:28:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C397F20665
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 00:28:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C397F20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58A878E004E; Wed, 20 Feb 2019 19:28:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53A138E0002; Wed, 20 Feb 2019 19:28:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4295E8E004E; Wed, 20 Feb 2019 19:28:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1970B8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 19:28:15 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id e9so4004933qka.11
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 16:28:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vjyTOL7J4ZDxE6m9GwW8s41cXxahZLQgd3j9HhKCaeA=;
        b=C2FlB+NK1W5h7lFiONW5n4OLjTPeUHUQERgIZ4NdoPlq+oN9QjuLhlGNKgp7oVLQR5
         ghHoz78FQopgeE4gLnBfYC7elnwgxyYA78cA0xvpc8YJV8iM3T6cjtIzQKcNUG01rZaw
         L910EgIuhpj73t2PqGYHbvQ9irfPNIhIuieZMVYNU4i2qxPLuS0+0YU/9Gh4WLx4eYt4
         8J5T78cfqpsOyL0bp3UJzxKJvYgH54QroOAOuNERpJGgFB+QpRwWWOeQ6pAH3t1DWXBB
         C3vKPnoVT//LkAOFxX7lfJ24kkhOYjrIikAm2yrtjcFps7ou7VfPc2MYBhW1IspqkV6u
         LX6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZQ3P4DQBXlMmbiOlSGQGoUI0vCHxhReiG1wGalek8R0c8ePMgb
	EOcgpguS2RCJnlmvJmWphlWQKjARmZH7y1JPqDJfFcPuV496lsdOYL9n+lyEvWwzowUMVpjQp/+
	r0Lmjba8kBPDw4Z3FDDZC2KcHnC2cCRmvBCocr+4KID0TIpR0tIXeNfwA3tae5ZPihA==
X-Received: by 2002:a37:a883:: with SMTP id r125mr7978816qke.95.1550708894824;
        Wed, 20 Feb 2019 16:28:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iayylww6HWh4YsC22bGdoRvkJyEIEL6SVHieMCLO/lSL8uwy7iS3KnPPmVfkuR3um+Q6YOt
X-Received: by 2002:a37:a883:: with SMTP id r125mr7978769qke.95.1550708893383;
        Wed, 20 Feb 2019 16:28:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550708893; cv=none;
        d=google.com; s=arc-20160816;
        b=tszpzHtR1Zsyk03MRAsglA6ghGO8Pyte9ho/vZm5Qc6/FhRHhZ23Us9nXgQ/se4xQl
         0JXe6T7L1ui9LTcoXpgYS8pt3gUULX1NLd6OKDU0RDkaUk+HFcIv0k5fZlBp6tiYL0Rs
         A6TUjSl8br3U9bVZkhI6FlJy6ySI0bzkMaT1pl/1nzD0PnMNXFOkPZ/mGg06pi1Tmyd/
         LVoP+sMPPP6KLbj6b+LXK39Mc0/zGPsglkSrNBXFpq/6EZvGrtc9XNt0LWgjT2TvztQg
         GTufdGUR41pL7NFwyFFnLqlQXSwtwIyOsTD75eMEQ7VoGlpoke5b6GYrdtml2YR7+gag
         Upiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vjyTOL7J4ZDxE6m9GwW8s41cXxahZLQgd3j9HhKCaeA=;
        b=GQWXxjQmEThUpuHNEvjvJqbQvfnhcEmePkSKwwdA+0e/csvbs//nkGoVNC4PjDGyuK
         JTlruDb9bvQlnp7DxsG4RFLoS1ZbBLsG+DnY6gO6Q2IvehsUjOoCiflJlgslBn/PEJKi
         qUg07a2S6D+tu19zPQkYajOou2/65LdpBNgl0aU3v3ujdvYdj63osb1i6uNtgHLnGWSN
         JhXDcXW2J+7sGhSbkdq+B9V2MvLNUcyug427+h5dX00NGnIOJJHSk+y34EU1vJlVW/YL
         Kwk7g4GDpnhdCuRKqEsw1C+wcg+LW28rMyILuihu7fXCJ4hQtDsQLY1Yd41iTZIKAy4+
         cy6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 38si1250615qvt.60.2019.02.20.16.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 16:28:13 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8A0594E916;
	Thu, 21 Feb 2019 00:28:12 +0000 (UTC)
Received: from redhat.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id AE2E61001DC8;
	Thu, 21 Feb 2019 00:28:11 +0000 (UTC)
Date: Wed, 20 Feb 2019 19:28:09 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH 03/10] mm/hmm: improve and rename hmm_vma_get_pfns() to
 hmm_range_snapshot()
Message-ID: <20190221002809.GC24489@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-4-jglisse@redhat.com>
 <cc2d909c-37c6-4239-7755-4383a8eca0df@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cc2d909c-37c6-4239-7755-4383a8eca0df@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 21 Feb 2019 00:28:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 04:25:07PM -0800, John Hubbard wrote:
> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > Rename for consistency between code, comments and documentation. Also
> > improves the comments on all the possible returns values. Improve the
> > function by returning the number of populated entries in pfns array.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >   include/linux/hmm.h |  4 ++--
> >   mm/hmm.c            | 23 ++++++++++-------------
> >   2 files changed, 12 insertions(+), 15 deletions(-)
> > 
> 
> Hi Jerome,
> 
> After applying the entire patchset, I still see a few hits of the old name,
> in Documentation:
> 
> $ git grep -n hmm_vma_get_pfns
> Documentation/vm/hmm.rst:192:  int hmm_vma_get_pfns(struct vm_area_struct *vma,
> Documentation/vm/hmm.rst:205:The first one (hmm_vma_get_pfns()) will only
> fetch present CPU page table
> Documentation/vm/hmm.rst:224:      ret = hmm_vma_get_pfns(vma, &range,
> start, end, pfns);
> include/linux/hmm.h:145: * HMM pfn value returned by hmm_vma_get_pfns() or
> hmm_vma_fault() will be:
> 
> 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index bd6e058597a6..ddf49c1b1f5e 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -365,11 +365,11 @@ void hmm_mirror_unregister(struct hmm_mirror *mirror);
> >    * table invalidation serializes on it.
> >    *
> >    * YOU MUST CALL hmm_vma_range_done() ONCE AND ONLY ONCE EACH TIME YOU CALL
> > - * hmm_vma_get_pfns() WITHOUT ERROR !
> > + * hmm_range_snapshot() WITHOUT ERROR !
> >    *
> >    * IF YOU DO NOT FOLLOW THE ABOVE RULE THE SNAPSHOT CONTENT MIGHT BE INVALID !
> >    */
> > -int hmm_vma_get_pfns(struct hmm_range *range);
> > +long hmm_range_snapshot(struct hmm_range *range);
> >   bool hmm_vma_range_done(struct hmm_range *range);
> > diff --git a/mm/hmm.c b/mm/hmm.c
> > index 74d69812d6be..0d9ecd3337e5 100644
> > --- a/mm/hmm.c
> > +++ b/mm/hmm.c
> > @@ -706,23 +706,19 @@ static void hmm_pfns_special(struct hmm_range *range)
> >   }
> >   /*
> > - * hmm_vma_get_pfns() - snapshot CPU page table for a range of virtual addresses
> > - * @range: range being snapshotted
> > + * hmm_range_snapshot() - snapshot CPU page table for a range
> > + * @range: range
> >    * Returns: -EINVAL if invalid argument, -ENOMEM out of memory, -EPERM invalid
> 
> Channeling Mike Rapoport, that should be @Return: instead of Returns: , but...
> 
> 
> > - *          vma permission, 0 success
> > + *          permission (for instance asking for write and range is read only),
> > + *          -EAGAIN if you need to retry, -EFAULT invalid (ie either no valid
> > + *          vma or it is illegal to access that range), number of valid pages
> > + *          in range->pfns[] (from range start address).
> 
> ...actually, that's a little hard to spot that we're returning number of
> valid pages. How about:
> 
>  * @Returns: number of valid pages in range->pfns[] (from range start
>  *           address). This may be zero. If the return value is negative,
>  *           then one of the following values may be returned:
>  *
>  *           -EINVAL  range->invalid is set, or range->start or range->end
>  *                    are not valid.
>  *           -EPERM   For example, asking for write, when the range is
>  *      	      read-only
>  *           -EAGAIN  Caller needs to retry
>  *           -EFAULT  Either no valid vma exists for this range, or it is
>  *                    illegal to access the range
> 
> (caution: my white space might be wrong with respect to tabs)

Will do a documentation patch to improve things and remove leftover.

Cheers,
Jérôme

