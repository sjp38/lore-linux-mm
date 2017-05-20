Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C60F0280753
	for <linux-mm@kvack.org>; Fri, 19 May 2017 20:34:53 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q125so71372263pgq.8
        for <linux-mm@kvack.org>; Fri, 19 May 2017 17:34:53 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 6si9639491pfn.104.2017.05.19.17.34.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 17:34:52 -0700 (PDT)
Subject: Re: [PATCH] x86/mm: synchronize pgd in vmemmap_free()
References: <1495216887-3175-1-git-send-email-jglisse@redhat.com>
 <1495216887-3175-2-git-send-email-jglisse@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <07058bfe-8b70-0d0f-24ce-2dc978fe347b@nvidia.com>
Date: Fri, 19 May 2017 17:34:51 -0700
MIME-Version: 1.0
In-Reply-To: <1495216887-3175-2-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@suse.de>

Hi Jerome,

On 05/19/2017 11:01 AM, J=C3=A9r=C3=B4me Glisse wrote:
> When we free kernel virtual map we should synchronize p4d/pud for
> all the pgds to avoid any stall entry in non canonical pgd.

"any stale entry in the non-canonical pgd", is what I think you meant to ty=
pe there.

Also, it would be nice to clarify that commit description a bit: I'm not su=
re what is meant here by=20
a "non-canonical pgd".

Also, it seems like the reshuffling of the internals of sync_global_pgds() =
deserves at least some=20
mention here. More below.

>=20
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mel Gorman <mgorman@suse.de>
> ---
>   arch/x86/mm/init_64.c | 17 ++++++++++-------
>   1 file changed, 10 insertions(+), 7 deletions(-)
>=20
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index ff95fe8..df753f8 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -108,8 +108,6 @@ void sync_global_pgds(unsigned long start, unsigned l=
ong end)
>   		BUILD_BUG_ON(pgd_none(*pgd_ref));
>   		p4d_ref =3D p4d_offset(pgd_ref, address);
>  =20
> -		if (p4d_none(*p4d_ref))
> -			continue;
>  =20
>   		spin_lock(&pgd_lock);
>   		list_for_each_entry(page, &pgd_list, lru) {
> @@ -123,12 +121,16 @@ void sync_global_pgds(unsigned long start, unsigned=
 long end)
>   			pgt_lock =3D &pgd_page_get_mm(page)->page_table_lock;
>   			spin_lock(pgt_lock);
>  =20
> -			if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
> -				BUG_ON(p4d_page_vaddr(*p4d)
> -				       !=3D p4d_page_vaddr(*p4d_ref));
> -
> -			if (p4d_none(*p4d))
> +			if (p4d_none(*p4d_ref)) {
>   				set_p4d(p4d, *p4d_ref);

Is the intention really to set p4d to a zeroed *p4d_ref, or is that a mista=
ke?

> +			} else {
> +				if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))

I think the code needs to be somewhat restructured, but as it stands, the a=
bove !p4d_none(*p4d_ref)=20
will always be true, because first part of the if/else checked for the oppo=
site case:=20
p4d_none(*p4d_ref).  This is a side effect of moving that block of code.

> +					BUG_ON(p4d_page_vaddr(*p4d)
> +					       !=3D p4d_page_vaddr(*p4d_ref));
> +
> +				if (p4d_none(*p4d))
> +					set_p4d(p4d, *p4d_ref);
> +			}
>  =20
>   			spin_unlock(pgt_lock);
>   		}
> @@ -1024,6 +1026,7 @@ remove_pagetable(unsigned long start, unsigned long=
 end, bool direct)
>   void __ref vmemmap_free(unsigned long start, unsigned long end)
>   {
>   	remove_pagetable(start, end, false);
> +	sync_global_pgds(start, end - 1);

This does fix the HMM crash that I was seeing in hmm-next.

thanks,
John Hubbard
NVIDIA

>   }
>  =20
>   #ifdef CONFIG_MEMORY_HOTREMOVE
> --=20
> 2.4.11
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
