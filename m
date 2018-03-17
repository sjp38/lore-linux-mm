Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id DDBCB6B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 23:30:21 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id y9so8032280qti.3
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 20:30:21 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w64si6187320qkd.292.2018.03.16.20.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 20:30:20 -0700 (PDT)
Subject: Re: [PATCH 06/14] mm/hmm: remove HMM_PFN_READ flag and ignore
 peculiar architecture
References: <20180316191414.3223-1-jglisse@redhat.com>
 <20180316191414.3223-7-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <8483b2a7-230c-eb05-0b23-eb15691070f0@nvidia.com>
Date: Fri, 16 Mar 2018 20:30:19 -0700
MIME-Version: 1.0
In-Reply-To: <20180316191414.3223-7-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>

On 03/16/2018 12:14 PM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> Only peculiar architecture allow write without read thus assume that
> any valid pfn do allow for read. Note we do not care for write only
> because it does make sense with thing like atomic compare and exchange
> or any other operations that allow you to get the memory value through
> them.
>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> ---
>  include/linux/hmm.h | 14 ++++++--------
>  mm/hmm.c            | 28 ++++++++++++++++++++++++----
>  2 files changed, 30 insertions(+), 12 deletions(-)
>=20
> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> index b65e527dd120..4bdc58ffe9f3 100644
> --- a/include/linux/hmm.h
> +++ b/include/linux/hmm.h
> @@ -84,7 +84,6 @@ struct hmm;
>   *
>   * Flags:
>   * HMM_PFN_VALID: pfn is valid

Maybe write it like this:

* HMM_PFN_VALID: pfn is valid. This implies that it has, at least, read per=
mission.

> - * HMM_PFN_READ:  CPU page table has read permission set
>   * HMM_PFN_WRITE: CPU page table has write permission set
>   * HMM_PFN_ERROR: corresponding CPU page table entry points to poisoned =
memory
>   * HMM_PFN_EMPTY: corresponding CPU page table entry is pte_none()
> @@ -97,13 +96,12 @@ struct hmm;
>  typedef unsigned long hmm_pfn_t;
> =20
>  #define HMM_PFN_VALID (1 << 0)

<snip>

> =20
> @@ -536,6 +534,17 @@ int hmm_vma_get_pfns(struct hmm_range *range)
>  	list_add_rcu(&range->list, &hmm->ranges);
>  	spin_unlock(&hmm->lock);
> =20
> +	if (!(vma->vm_flags & VM_READ)) {
> +		/*
> +		 * If vma do not allow read assume it does not allow write as
> +		 * only peculiar architecture allow write without read and this
> +		 * is not a case we care about (some operation like atomic no
> +		 * longer make sense).
> +		 */
> +		hmm_pfns_clear(range->pfns, range->start, range->end);
> +		return 0;

1. Shouldn't we return an error here? All is not well. No one has any pfns,=
 even
   though they tried to get some. :)

2. I think this check needs to be done much earlier, right after the "Sanit=
y
   check, this should not happen" code in this routine.

> +	}
> +
>  	hmm_vma_walk.fault =3D false;
>  	hmm_vma_walk.range =3D range;
>  	mm_walk.private =3D &hmm_vma_walk;
> @@ -690,6 +699,17 @@ int hmm_vma_fault(struct hmm_range *range, bool writ=
e, bool block)
>  	list_add_rcu(&range->list, &hmm->ranges);
>  	spin_unlock(&hmm->lock);
> =20
> +	if (!(vma->vm_flags & VM_READ)) {
> +		/*
> +		 * If vma do not allow read assume it does not allow write as
> +		 * only peculiar architecture allow write without read and this
> +		 * is not a case we care about (some operation like atomic no
> +		 * longer make sense).
> +		 */

For the comment wording (for this one, and the one above), how about:

/*
 * If the vma does not allow read access, then assume that=20
 * it does not allow write access, either.
 */

...and then leave the more extensive explanation to the commit log. Or,
if we really want a longer explananation right here, then:

/*
 * If the vma does not allow read access, then assume that=20
 * it does not allow write access, either. Architectures that
 * allow write without read access are not supported by HMM,
 * because operations such as atomic access would not work.
 */


> +		hmm_pfns_clear(range->pfns, range->start, range->end);
> +		return 0;
> +	}

Similar points as above: it seems like an error case, and the check should =
be right near=20
the beginning of the function.

thanks,
--=20
John Hubbard
NVIDIA
