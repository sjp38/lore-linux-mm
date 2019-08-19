Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57A84C3A5A2
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A7CA22D6D
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 19:07:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H3pRQ1dC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A7CA22D6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 831206B0006; Mon, 19 Aug 2019 15:07:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B9E76B0007; Mon, 19 Aug 2019 15:07:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 680E06B0008; Mon, 19 Aug 2019 15:07:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0155.hostedemail.com [216.40.44.155])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6676B0006
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 15:07:28 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id DB35E55F83
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:07:27 +0000 (UTC)
X-FDA: 75840110934.30.fifth54_5e32b5b05e336
X-HE-Tag: fifth54_5e32b5b05e336
X-Filterd-Recvd-Size: 5833
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:07:27 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id i30so1714128pfk.9
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 12:07:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=WHGqZLDt9a+Qw4mTuhWg8ibFrzx8EVTAEIo7NN7uUto=;
        b=H3pRQ1dCM/eJk1TgtiVsp73U6nYHv753LJCykk1urL3AFHndUAwUr5EvkEljG01GxN
         HMBSgFvyVOHnP1biKu+2paoz5lO/CyMIkU6sS8zA1YZcVsXhHbag8ZnwqH8MGdD8/4zD
         08MwjIyWz6aDP1NjGJenI7R5Cgepa01wuc+Qy/7kum0lfetrYMxySJnRdqV5U0VeiIf4
         gTJUYzVjqNoTzTKgQHNnbkpT7SHOow9P84BqkAyLyG9/1T4y4yS0ROWBLqiLu4F7SHY0
         u5ajIyRXZGPwhWiIvSkev9LgmOndRTOY09WTs3hurB1sJIPOYDr0PaJ49ObuT14Jcm9J
         VhuA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=WHGqZLDt9a+Qw4mTuhWg8ibFrzx8EVTAEIo7NN7uUto=;
        b=t5eQq/G6C+oYgwe3W+K13JvH1jE5Fc3oGFBnQvrRSLdfeb1fzzR+GMrVwzDVBvjxIm
         2WJeWSA85YmMJ5gwTlmQeAFEj3g31s+9fSFeJFhWu7HqUw4kOIl119ELZ0y/lppmbT43
         Ndlsc714IIy12oK2SuXD0NxVKf9DlIGekdN+5BlqqDYHnBWqxvZsm+SpKZF5AkOQd/0o
         Cwp2yn5mLxytoUcRvpWD4Q3WZ6AzTgqBEzzwwxxIodWRtLPbuE7t3R/5r5NV7XeTvFYM
         bA/32ILKQGXdcaTm2K4pecbhFG5EeXzmpjyQLiDFhzJkgeTpkN/RpII/BlcdpYqtoj66
         URQw==
X-Gm-Message-State: APjAAAV854fGNh8N/uBu8gzW3qoF8q0fmIqyaqy4/SCgjRQHBN5IPQ52
	fOk0QPI3lSk39PrL7mFbuQc=
X-Google-Smtp-Source: APXvYqyXUC4nhUMvLsEyoD3Ye6bi/qwluhAFtXBp9B7pM6+hMAj67CWmgFPDCKhaBvy8Rnjjm61TRQ==
X-Received: by 2002:aa7:938d:: with SMTP id t13mr24796850pfe.180.1566241646311;
        Mon, 19 Aug 2019 12:07:26 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id v8sm19123293pjb.6.2019.08.19.12.07.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Aug 2019 12:07:25 -0700 (PDT)
Date: Tue, 20 Aug 2019 00:37:15 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Dimitri Sivanich <sivanich@hpe.com>
Cc: jhubbard@nvidia.com, jglisse@redhat.com, ira.weiny@intel.com,
	gregkh@linuxfoundation.org, arnd@arndb.de,
	william.kucharski@oracle.com, hch@lst.de, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [Linux-kernel-mentees][PATCH 2/2] sgi-gru: Remove uneccessary
 ifdef for CONFIG_HUGETLB_PAGE
Message-ID: <20190819190714.GB6261@bharath12345-Inspiron-5559>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-3-git-send-email-linux.bhar@gmail.com>
 <20190819130057.GC5808@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190819130057.GC5808@hpe.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 08:00:57AM -0500, Dimitri Sivanich wrote:
> Reviewed-by: Dimitri Sivanich <sivanich@hpe.com>
Thanks!=20
> On Mon, Aug 19, 2019 at 01:08:55AM +0530, Bharath Vedartham wrote:
> > is_vm_hugetlb_page will always return false if CONFIG_HUGETLB_PAGE is
> > not set.
> >=20
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: Dimitri Sivanich <sivanich@sgi.com>
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: William Kucharski <william.kucharski@oracle.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel-mentees@lists.linuxfoundation.org
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> > Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> > Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> > ---
> >  drivers/misc/sgi-gru/grufault.c | 21 +++++++++++----------
> >  1 file changed, 11 insertions(+), 10 deletions(-)
> >=20
> > diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/g=
rufault.c
> > index 61b3447..bce47af 100644
> > --- a/drivers/misc/sgi-gru/grufault.c
> > +++ b/drivers/misc/sgi-gru/grufault.c
> > @@ -180,11 +180,11 @@ static int non_atomic_pte_lookup(struct vm_area=
_struct *vma,
> >  {
> >  	struct page *page;
> > =20
> > -#ifdef CONFIG_HUGETLB_PAGE
> > -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> > -#else
> > -	*pageshift =3D PAGE_SHIFT;
> > -#endif
> > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > +		*pageshift =3D HPAGE_SHIFT;
> > +	else
> > +		*pageshift =3D PAGE_SHIFT;
> > +
> >  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=
=3D 0)
> >  		return -EFAULT;
> >  	*paddr =3D page_to_phys(page);
> > @@ -238,11 +238,12 @@ static int atomic_pte_lookup(struct vm_area_str=
uct *vma, unsigned long vaddr,
> >  		return 1;
> > =20
> >  	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> > -#ifdef CONFIG_HUGETLB_PAGE
> > -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> > -#else
> > -	*pageshift =3D PAGE_SHIFT;
> > -#endif
> > +
> > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > +		*pageshift =3D HPAGE_SHIFT;
> > +	else
> > +		*pageshift =3D PAGE_SHIFT;
> > +
> >  	return 0;
> > =20
> >  err:
> > --=20
> > 2.7.4
> >=20

