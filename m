Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 732EDC76191
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CDB021926
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 02:32:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="TmwAzunX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CDB021926
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE38F6B0003; Sun, 21 Jul 2019 22:32:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B946A6B0006; Sun, 21 Jul 2019 22:32:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAA0F8E0001; Sun, 21 Jul 2019 22:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86CD86B0003
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:32:39 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id d18so28717390ywb.19
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 19:32:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=vM8Jy937nRvxwkL1bwsxA2+vqomr30+OXJGmeXYwzBo=;
        b=rci31xCYs9JrZa17ajz8hfCp1BCa9GWe5B7m0qgpCcom97vClvuyMNd1fABLisRcaR
         BWkPbYWfXHAWJYSwFzMqnijDNKMvi0gkF3IC5U1tS8qX3RKYwUt7rQNWLm5YBoNvD6Lr
         sTYgx8g0vszh0hgyRMnloajLE7Zk31wOztse/P6DJI3KXu0G8sWlEmcqVHnCrp9XOVqT
         7FzTFELWjYb6q8kzB0iVbILSc6e+xeL9x76mlsXSLd36Oi052DBl5Ea7Lj8iw7Vf6IlM
         x627FNyMI5Pv0dTUHMJlo5vKl3qbh4fLX//MKje3pKA5QPQeNk5Qh3go5rIUHFQywBo6
         Fv1g==
X-Gm-Message-State: APjAAAWLFPCRUI1hZ7ecUW/l3sC3FeRSXnr2JMKrA6FYI1AUGf9nZK3Q
	5ySJGEqxWffBdfo92jTwCW3HRZTxty3YtZuQJpvXAo/+ibSQYPAG2a6LuIjxOZVXCr2J7bz8akU
	hwJTYpDmsn+SUTVWCNjH+PwIQkpen4D+vm2rWJ4SkJ0cr3nCO3IhoRNW6uEtcCk4LSw==
X-Received: by 2002:a5b:50c:: with SMTP id o12mr40340788ybp.355.1563762759287;
        Sun, 21 Jul 2019 19:32:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyp2US26kv7r7vioi24bIGqPq3nu5sHxQxQwkquGf74SvgBB5OLto3gBud7LfOj3I4aZlNz
X-Received: by 2002:a5b:50c:: with SMTP id o12mr40340756ybp.355.1563762758593;
        Sun, 21 Jul 2019 19:32:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563762758; cv=none;
        d=google.com; s=arc-20160816;
        b=jnfu4w0/Hr0D7QEoXUkY+1Z2VAvw4VzU/w2WU0AOk7CsQkI4GFluWlw3/13Yk7S70E
         DsEqUj1jx+JhcoC+qdPvGmLz05pAMEg0Pd5PBo+7nWfc7BWq290ixG5RZ3OwWaSEAU7T
         pt3SD11dPGAlfJQPy+5w+kHJB80oAx+m/F4Z7vx2Pu8EGHabxR4AROSVUxFw9MRtAakx
         U5h3i/ONOlUMcy78c2H9q54J+P4svF/nWS4CqZBZ2zR3u77OoFXO/Jo+SAnk2I8g0gdC
         67V0Tc5eMgsVHWgsPsMrkt9xV+/psspwsH7IOdd0YPXSkcJl2OM08mdSchm4nR//B3UN
         CbXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=vM8Jy937nRvxwkL1bwsxA2+vqomr30+OXJGmeXYwzBo=;
        b=XXbttIsxEyf+pBTjEgkWOcJkDa1nGLMrMDSq62kgX+VWVpIk97vXO+twSJg7w8Oz1V
         UdnbDhGGaK1JMk0aM+ohmBpLZMQ6SmQptxHNq3diOH8ROTwq0VMjnti8IEcWtl6NjwlF
         WAGnvJsANHT2SFUg4xMNa4WhY8UTJOgQEUHvcBWQtzTDiQOjdrEEU9IeZ9W3At4iW3OI
         0WRaQAiQ4XoHzCRTRwuuBYBk4DhnTwp+u2alN747+pE2csmcndCWZzn33kQQN6ebpUMU
         TnOmXtueoCUsth6MHBCeiys8hv51qQb0RoG136UwMncqVlMZvat1yFJ44sj+A/vsRcNJ
         fihA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TmwAzunX;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id u21si15010769ywc.96.2019.07.21.19.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 19:32:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=TmwAzunX;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d35204c0000>; Sun, 21 Jul 2019 19:32:44 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Sun, 21 Jul 2019 19:32:37 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Sun, 21 Jul 2019 19:32:37 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 22 Jul
 2019 02:32:37 +0000
Subject: Re: [PATCH 3/3] sgi-gru: Use __get_user_pages_fast in
 atomic_pte_lookup
To: Bharath Vedartham <linux.bhar@gmail.com>, <arnd@arndb.de>,
	<sivanich@sgi.com>, <gregkh@linuxfoundation.org>
CC: <ira.weiny@intel.com>, <jglisse@redhat.com>,
	<linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
References: <1563724685-6540-1-git-send-email-linux.bhar@gmail.com>
 <1563724685-6540-4-git-send-email-linux.bhar@gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c508330d-a5d0-fba3-9dd0-eb820a96ee09@nvidia.com>
Date: Sun, 21 Jul 2019 19:32:36 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1563724685-6540-4-git-send-email-linux.bhar@gmail.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563762764; bh=vM8Jy937nRvxwkL1bwsxA2+vqomr30+OXJGmeXYwzBo=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=TmwAzunX+5qzu07CrqhvBJCCV0jq5HpocZtWwYm//UJko8hKWxee+N31cImnRhrin
	 EyrgXUGITres3QieKC34H3xI8rXLDQPlsVzu/llAAo3hCd41vJy8AyIPDVAn/Y69Ou
	 Zm4yF5W0MsP7IKNY6LukPPWyYWc8+eNoYpR9YZPqtI9ttKO0fsWkmuArrVBf2U+sgQ
	 7wUrLDXfymWp/nPaElRVD6YtlVin5Q/u3+QC9rn7EBa+LLskeHBPMH65V+5SE2TLOB
	 wXsYIPbTNp7Pk0SsrBayUEyKeHliV6b8W0pVWuTGY84yZ3zCXoYaspXINWJlNlZI5I
	 t5GvpgJ3qo7fQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/21/19 8:58 AM, Bharath Vedartham wrote:
> *pte_lookup functions get the physical address for a given virtual
> address by getting a physical page using gup and use page_to_phys to get
> the physical address.
>=20
> Currently, atomic_pte_lookup manually walks the page tables. If this
> function fails to get a physical page, it will fall back too
> non_atomic_pte_lookup to get a physical page which uses the slow gup
> path to get the physical page.
>=20
> Instead of manually walking the page tables use __get_user_pages_fast
> which does the same thing and it does not fall back to the slow gup
> path.
>=20
> This is largely inspired from kvm code. kvm uses __get_user_pages_fast
> in hva_to_pfn_fast function which can run in an atomic context.
>=20
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Dimitri Sivanich <sivanich@sgi.com>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
> ---
>  drivers/misc/sgi-gru/grufault.c | 39 +++++------------------------------=
----
>  1 file changed, 5 insertions(+), 34 deletions(-)
>=20
> diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufa=
ult.c
> index 75108d2..121c9a4 100644
> --- a/drivers/misc/sgi-gru/grufault.c
> +++ b/drivers/misc/sgi-gru/grufault.c
> @@ -202,46 +202,17 @@ static int non_atomic_pte_lookup(struct vm_area_str=
uct *vma,
>  static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long v=
addr,
>  	int write, unsigned long *paddr, int *pageshift)
>  {
> -	pgd_t *pgdp;
> -	p4d_t *p4dp;
> -	pud_t *pudp;
> -	pmd_t *pmdp;
> -	pte_t pte;
> -
> -	pgdp =3D pgd_offset(vma->vm_mm, vaddr);
> -	if (unlikely(pgd_none(*pgdp)))
> -		goto err;
> -
> -	p4dp =3D p4d_offset(pgdp, vaddr);
> -	if (unlikely(p4d_none(*p4dp)))
> -		goto err;
> -
> -	pudp =3D pud_offset(p4dp, vaddr);
> -	if (unlikely(pud_none(*pudp)))
> -		goto err;
> +	struct page *page;
> =20
> -	pmdp =3D pmd_offset(pudp, vaddr);
> -	if (unlikely(pmd_none(*pmdp)))
> -		goto err;
> -#ifdef CONFIG_X86_64
> -	if (unlikely(pmd_large(*pmdp)))
> -		pte =3D *(pte_t *) pmdp;
> -	else
> -#endif
> -		pte =3D *pte_offset_kernel(pmdp, vaddr);
> +	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> =20
> -	if (unlikely(!pte_present(pte) ||
> -		     (write && (!pte_write(pte) || !pte_dirty(pte)))))
> +	if (!__get_user_pages_fast(vaddr, 1, write, &page))
>  		return 1;

Let's please use numeric, not boolean comparison, for the return value of=20
gup.

Also, optional: as long as you're there, atomic_pte_lookup() ought to
either return a bool (true =3D=3D success) or an errno, rather than a
numeric zero or one.

Other than that, this looks like a good cleanup, I wonder how many
open-coded gup implementations are floating around like this.=20

thanks,
--=20
John Hubbard
NVIDIA

> =20
> -	*paddr =3D pte_pfn(pte) << PAGE_SHIFT;
> -
> -	*pageshift =3D is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
> +	*paddr =3D page_to_phys(page);
> +	put_user_page(page);
> =20
>  	return 0;
> -
> -err:
> -	return 1;
>  }
> =20
>  static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>=20

