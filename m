Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D182BC28EBD
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86FD720868
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 02:45:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="WbdgepJx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86FD720868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26C346B029D; Thu,  6 Jun 2019 22:45:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 21D016B02DD; Thu,  6 Jun 2019 22:45:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10B236B02FB; Thu,  6 Jun 2019 22:45:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id DBA2C6B029D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 22:45:04 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id o98so283761ota.11
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 19:45:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=CTx0CZF1eqGSR9YUaBnLK21ryxBUxrtYilDSKRTBU9s=;
        b=t+JnPOaOwu4B/BNK+NVa8kQkFprlaCVJmL0WcFxg9bsQT8bijoxjINvc04GbY7WTlW
         0JAXz7uIANrpn6/fm/9G3t4DFPD+BmK6y7uAyXbREVl48M+gttPxPm1fOXTkT5NHqriY
         Xt/TMGqe/uXGZLnPLjUT4F00/yR4MI0Rd4DeEp5Kuma1vC4nPTNCcEsb5HHb7GLuTiYl
         39NaKywFBZLuSTUUvweneSiNTyOSfJmXdKjWbEST+sSrMuo+o4VFP9E9Bvw6Ju3KUu5u
         Lnz3uugjc6dECShCHVaOun8+Q14lLJnHunuexhE2gx4EzHuwUQyfEBuMd9TgbTLaT+GO
         Al8g==
X-Gm-Message-State: APjAAAVC/dReT8Ytjjg6cuZcmzlbw/zYV+Ely2u6IoNRa1GgoK/HPHSw
	4QRzx1czhvCyCcIfvIGJFYOe3jrv74xjy1xlST6BPonsIR7qKRN0TvTXJuupDQcEPVSZ3mbiX+H
	3JRjJPLoAYDYRU+xmZP2L5sm4pGYztJB1ZygjpzndoozKu7oo5roEA4MVnpVe81INtw==
X-Received: by 2002:a9d:23ca:: with SMTP id t68mr16083866otb.98.1559875504499;
        Thu, 06 Jun 2019 19:45:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy77o1o8o2HHKDfROcXQgmpI8yQ/T99uTpp9vSMd25DVM4S+guLZG32ZdUAjTAgrXKQv/av
X-Received: by 2002:a9d:23ca:: with SMTP id t68mr16083842otb.98.1559875503773;
        Thu, 06 Jun 2019 19:45:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559875503; cv=none;
        d=google.com; s=arc-20160816;
        b=Gb4o7qC1MILBJiGb8ifNF+2A1nQcNfDLpwAaw3NP3fVIf8dRDEmNqjc0zC2KmQY687
         wJ45OQzC6Y7fUt5f7+3RkVtfJSibRtyKsELhN9ZWRlxa4rvPmYtehGEoW/qdgQzJ4hBv
         xQEl6kf9HHLX5XpxniGr5seUPf4jwm9FM/QLMbuGQq0wzh1iBtTf2r8krdS0Yk7V9vYo
         ydZIjQDnEfVH1ua7PNRAvcYQzmLoHA1ZWDQY9KfSW1dDpB8ouMIYpz10wnQUnqngs+G8
         yqs9gQ0sP1qW54L6g9GKnuTX+FbcJneBWRlqjko9k5+fVoX+UQkh9epP2ArLCg65NndG
         StYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=CTx0CZF1eqGSR9YUaBnLK21ryxBUxrtYilDSKRTBU9s=;
        b=vq4g8hpISjdiGo3m0DOGJFhGHWGSbYnppGkcYFjTyppqsIjQKRqQxbEP0CXUF2X7g6
         fmXFXa8Vp4KNuTfB1aWLl0xNkReSRpv4fB2ZjlXArGuTWPeARHFusX+vcoqWmVsOlI+V
         6smnB8XuNIkxMilyJtiVBvbYTO6WmA9zKEEMDk/4OuYhudDq85bZZk5fMxbLnz7Q8Wza
         YpsthWYtSRk1dDQMFj8SBvB+ELoQLdLmMQjwPr4h9wudPZwOFbfkZ19re0+Q+RG2qHpM
         YPtKzKpZnY1uqnvuTWWeQrUtBQ4DiRo9alo5AhjiI2WKDMkb+fkUmujlSr9T0RBjg53N
         +Nqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WbdgepJx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id z20si570011oid.186.2019.06.06.19.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 19:45:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WbdgepJx;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf9cfac0000>; Thu, 06 Jun 2019 19:45:00 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Thu, 06 Jun 2019 19:45:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Thu, 06 Jun 2019 19:45:02 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 7 Jun
 2019 02:44:59 +0000
Subject: Re: [PATCH v2 hmm 03/11] mm/hmm: Hold a mmgrab from hmm to mm
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>, "Ralph
 Campbell" <rcampbell@nvidia.com>, <Felix.Kuehling@amd.com>
CC: <linux-rdma@vger.kernel.org>, <linux-mm@kvack.org>, Andrea Arcangeli
	<aarcange@redhat.com>, <dri-devel@lists.freedesktop.org>,
	<amd-gfx@lists.freedesktop.org>, Jason Gunthorpe <jgg@mellanox.com>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-4-jgg@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <48fcaa19-6ac3-59d0-cd51-455abeca7cdb@nvidia.com>
Date: Thu, 6 Jun 2019 19:44:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190606184438.31646-4-jgg@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559875501; bh=CTx0CZF1eqGSR9YUaBnLK21ryxBUxrtYilDSKRTBU9s=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=WbdgepJxjCHukIhBJ337H26udHrSAKLUnbPQYX01omNSCrQ4fChLraSIVS8BdQztY
	 y4HSS82fWGqhCo05fjhDYEDdSq1PaJ4ub4bBnNrfIjyV3AtMVD/rdGCLHbnXn7BVZr
	 3EFPvF0FE7KTfTwY0aOOZ6HXEp2eoCLm3QlHH3PYW0iEfIIYDBMotKjfdI9+2mrboJ
	 xcwswKfBDrDosV24wiz5GIj+6DDKbooE/KHh75+F17jnsGUKSVgHbYgV3D1Ho3yWOF
	 ftxVH4bh2uBdUMQ7pou1FfierCA1ZvJnx2039/gk7jyWsEixyV9Daz6598bhPfjFsU
	 yQqrp+fujdKEg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/6/19 11:44 AM, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
>=20
> So long a a struct hmm pointer exists, so should the struct mm it is
> linked too. Hold the mmgrab() as soon as a hmm is created, and mmdrop() i=
t
> once the hmm refcount goes to zero.
>=20
> Since mmdrop() (ie a 0 kref on struct mm) is now impossible with a !NULL
> mm->hmm delete the hmm_hmm_destroy().
>=20
> Signed-off-by: Jason Gunthorpe <jgg@mellanox.com>
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> ---
> v2:
>  - Fix error unwind paths in hmm_get_or_create (Jerome/Jason)
> ---
>  include/linux/hmm.h |  3 ---
>  kernel/fork.c       |  1 -
>  mm/hmm.c            | 22 ++++------------------
>  3 files changed, 4 insertions(+), 22 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index 2d519797cb134a..4ee3acabe5ed22 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -586,14 +586,11 @@ static inline int hmm_vma_fault(struct hmm_mirror *=
mirror,
>  }
> =20
>  /* Below are for HMM internal use only! Not to be used by device driver!=
 */
> -void hmm_mm_destroy(struct mm_struct *mm);
> -
>  static inline void hmm_mm_init(struct mm_struct *mm)
>  {
>  	mm->hmm =3D NULL;
>  }
>  #else /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> -static inline void hmm_mm_destroy(struct mm_struct *mm) {}
>  static inline void hmm_mm_init(struct mm_struct *mm) {}
>  #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
> =20
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b2b87d450b80b5..588c768ae72451 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -673,7 +673,6 @@ void __mmdrop(struct mm_struct *mm)
>  	WARN_ON_ONCE(mm =3D=3D current->active_mm);
>  	mm_free_pgd(mm);
>  	destroy_context(mm);
> -	hmm_mm_destroy(mm);


This is particularly welcome, not to have an "HMM is special" case
in such a core part of process/mm code.=20


>  	mmu_notifier_mm_destroy(mm);
>  	check_mm(mm);
>  	put_user_ns(mm->user_ns);
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 8796447299023c..cc7c26fda3300e 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -29,6 +29,7 @@
>  #include <linux/swapops.h>
>  #include <linux/hugetlb.h>
>  #include <linux/memremap.h>
> +#include <linux/sched/mm.h>
>  #include <linux/jump_label.h>
>  #include <linux/dma-mapping.h>
>  #include <linux/mmu_notifier.h>
> @@ -82,6 +83,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct *=
mm)
>  	hmm->notifiers =3D 0;
>  	hmm->dead =3D false;
>  	hmm->mm =3D mm;
> +	mmgrab(hmm->mm);
> =20
>  	spin_lock(&mm->page_table_lock);
>  	if (!mm->hmm)
> @@ -109,6 +111,7 @@ static struct hmm *hmm_get_or_create(struct mm_struct=
 *mm)
>  		mm->hmm =3D NULL;
>  	spin_unlock(&mm->page_table_lock);
>  error:
> +	mmdrop(hmm->mm);
>  	kfree(hmm);
>  	return NULL;
>  }
> @@ -130,6 +133,7 @@ static void hmm_free(struct kref *kref)
>  		mm->hmm =3D NULL;
>  	spin_unlock(&mm->page_table_lock);
> =20
> +	mmdrop(hmm->mm);
>  	mmu_notifier_call_srcu(&hmm->rcu, hmm_free_rcu);
>  }
> =20
> @@ -138,24 +142,6 @@ static inline void hmm_put(struct hmm *hmm)
>  	kref_put(&hmm->kref, hmm_free);
>  }
> =20
> -void hmm_mm_destroy(struct mm_struct *mm)
> -{
> -	struct hmm *hmm;
> -
> -	spin_lock(&mm->page_table_lock);
> -	hmm =3D mm_get_hmm(mm);
> -	mm->hmm =3D NULL;
> -	if (hmm) {
> -		hmm->mm =3D NULL;
> -		hmm->dead =3D true;
> -		spin_unlock(&mm->page_table_lock);
> -		hmm_put(hmm);
> -		return;
> -	}
> -
> -	spin_unlock(&mm->page_table_lock);
> -}
> -
>  static void hmm_release(struct mmu_notifier *mn, struct mm_struct *mm)
>  {
>  	struct hmm *hmm =3D container_of(mn, struct hmm, mmu_notifier);
>=20

Failed to find any problems with this. :)

    Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

