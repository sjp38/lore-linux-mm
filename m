Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 964106B0005
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 21:50:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g62so208141558pfb.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 18:50:24 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id j18si1435299pfk.49.2016.06.30.18.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 18:50:23 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id hf6so8471083pac.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 18:50:23 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 6/6] x86: Fix stray A/D bit setting into non-present PTEs
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20160701001218.3D316260@viggo.jf.intel.com>
Date: Thu, 30 Jun 2016 18:50:21 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <5A585093-4E0D-49BC-A9CA-0072BB83A71C@gmail.com>
References: <20160701001209.7DA24D1C@viggo.jf.intel.com> <20160701001218.3D316260@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, dave.hansen@linux.intel.com

Dave Hansen <dave@sr71.net> wrote:

> +pte_t ptep_clear_flush(struct vm_area_struct *vma, unsigned long =
address,
> +		       pte_t *ptep)
> +{
> +	struct mm_struct *mm =3D vma->vm_mm;
> +	pte_t pte;
> +
> +	pte =3D ptep_get_and_clear(mm, address, ptep);
> +	if (pte_accessible(mm, pte)) {
> +		flush_tlb_page(vma, address);
> +		/*
> +		 * Ensure that the compiler orders our set_pte()
> +		 * after the flush_tlb_page() no matter what.
> +		 */
> +		barrier();

I don=E2=80=99t think such a barrier (after remote TLB flush) is needed.
Eventually, if a remote flush takes place, you get csd_lock_wait() to be
called, and then smp_rmb() is called (which is essentially a barrier()
call on x86).

Regards,
Nadav


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
