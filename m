Return-Path: <SRS0=q2Op=WO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF0DCC3A589
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:51:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 870D0206BB
	for <linux-mm@archiver.kernel.org>; Sun, 18 Aug 2019 19:51:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bYzjO4m8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 870D0206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 395736B026A; Sun, 18 Aug 2019 15:51:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345A66B026B; Sun, 18 Aug 2019 15:51:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 20D426B026C; Sun, 18 Aug 2019 15:51:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0132.hostedemail.com [216.40.44.132])
	by kanga.kvack.org (Postfix) with ESMTP id F2FBE6B026A
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 15:51:49 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 96AD48248AA7
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:51:49 +0000 (UTC)
X-FDA: 75836593938.15.can76_844c5118a371d
X-HE-Tag: can76_844c5118a371d
X-Filterd-Recvd-Size: 5561
Received: from mail-pg1-f195.google.com (mail-pg1-f195.google.com [209.85.215.195])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 18 Aug 2019 19:51:48 +0000 (UTC)
Received: by mail-pg1-f195.google.com with SMTP id o13so5624451pgp.12
        for <linux-mm@kvack.org>; Sun, 18 Aug 2019 12:51:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=Q4h4AAkSwtddxhD1rcEhxl/4C2CCtZRHzKErT0Cnp1c=;
        b=bYzjO4m8Pz5KgkK1Fzm0xdlan5DrBx5ZIGvOjNDe8zywDUCBOwaEYG6c9rbyYeOfkV
         RL4ivE6SiZra9nJ809T4SHEpPX8Jw5tMYR7FDiwLWbB5QyzwRSh4MroTKW06LgybptFh
         eDYTpCf7SFSF36WRuOq3s0rdK/zMVA/wvYp34jbzuSvxDd0ylhEpW2VyACu3IYsXsW0t
         ONJVqY3NI8N6UbQYpUL9Lx/etqSsJA6dCXb0OkM7UoQt5Q4GqeJI0yRUxDAKgPvoHhN6
         rXP78biQicwZesBcaTCRScaO3OFzqS6SnQtfk1PlzqIMxoaD5z/d2AEsRRXhYClBwZAx
         l9Iw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=Q4h4AAkSwtddxhD1rcEhxl/4C2CCtZRHzKErT0Cnp1c=;
        b=iDe6MDvhbr86KI6kwI/9RVz1gxgdoxuVACJVvmXCPdicyZlufpwFI6+pEHLrzJsu09
         ZlWhbYRXApl8AVGkfmqrG1C51a8o8cYopGOEPczrU3VJesu1hlmbVK69n2wYPOlKXbq6
         v0b11a9wgGaAdtFMi1svvQVx7CH9mWIfCyibyBa5ixYTinWO0apwGQRYOcGNxi5Gze8t
         pex7nJ7xLNrVk+PEENoeU4IEAz2ybAD+7UEZHhQ579XE18WwzcIsS+qT1+smPDuCXvGE
         ecGgES7Z+DfvB1m8k/CGFCkcSzQdYm/Bve4XVivH+I+YbHQdtOWQ2gpSeOONRHGpb3wB
         7vbQ==
X-Gm-Message-State: APjAAAUn9keIKB29CNk78gQM8kt+jPeENlew1/+cCj2s2PlPH63VRNZp
	nq3uHYi9JDC4vYP1oMVr5ik=
X-Google-Smtp-Source: APXvYqyB4mZN3GlDyvJdXkICz5BRy65BhfRAC8N/94OuA2dp6JDNM2regMC1kAMDyvg5+0O6i9VXZg==
X-Received: by 2002:a65:518a:: with SMTP id h10mr14874008pgq.117.1566157908156;
        Sun, 18 Aug 2019 12:51:48 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id 16sm23529953pfc.66.2019.08.18.12.51.43
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Aug 2019 12:51:47 -0700 (PDT)
Date: Mon, 19 Aug 2019 01:21:40 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com, jhubbard@nvidia.com
Cc: jglisse@redhat.com, ira.weiny@intel.com, gregkh@linuxfoundation.org,
	arnd@arndb.de, william.kucharski@oracle.com, hch@lst.de,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel-mentees@lists.linuxfoundation.org
Subject: Re: [Linux-kernel-mentees][PATCH 2/2] sgi-gru: Remove uneccessary
 ifdef for CONFIG_HUGETLB_PAGE
Message-ID: <20190818195140.GC4487@bharath12345-Inspiron-5559>
References: <1566157135-9423-1-git-send-email-linux.bhar@gmail.com>
 <1566157135-9423-3-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1566157135-9423-3-git-send-email-linux.bhar@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

CC'ing lkml.

On Mon, Aug 19, 2019 at 01:08:55AM +0530, Bharath Vedartham wrote:
> is_vm_hugetlb_page will always return false if CONFIG_HUGETLB_PAGE is
> not set.
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=E9r=F4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: William Kucharski <william.kucharski@oracle.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel-mentees@lists.linuxfoundation.org
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: William Kucharski <william.kucharski@oracle.com>
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/misc/sgi-gru/grufault.c | 21 +++++++++++----------
>  1 file changed, 11 insertions(+), 10 deletions(-)
>=20
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/gru=
fault.c
> index 61b3447..bce47af 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -180,11 +180,11 @@ static int non_atomic_pte_lookup(struct vm_area_s=
truct *vma,
>  {
>  	struct page *page;
> =20
> -#ifdef CONFIG_HUGETLB_PAGE
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift =3D HPAGE_SHIFT;
> +	else
> +		*pageshift =3D PAGE_SHIFT;
> +
>  	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <=3D=
 0)
>  		return -EFAULT;
>  	*paddr =3D page_to_phys(page);
> @@ -238,11 +238,12 @@ static int atomic_pte_lookup(struct vm_area_struc=
t *vma, unsigned long vaddr,
>  		return 1;
> =20
>  	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> -#ifdef CONFIG_HUGETLB_PAGE
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> -#else
> -	*pageshift =3D PAGE_SHIFT;
> -#endif
> +
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift =3D HPAGE_SHIFT;
> +	else
> +		*pageshift =3D PAGE_SHIFT;
> +
>  	return 0;
> =20
>  err:
> --=20
> 2.7.4
>=20

