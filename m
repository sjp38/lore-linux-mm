Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 288836B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 09:40:31 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id k15so7986412qaq.12
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:40:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f186si893451qhe.32.2015.02.26.06.40.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 06:40:30 -0800 (PST)
Message-ID: <54EF302D.3020607@redhat.com>
Date: Thu, 26 Feb 2015 15:39:41 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz> <1424958666-18241-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1424958666-18241-3-git-send-email-vbabka@suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="x69MNc9CAotLIveb9QpeuxLk0NKIRUiwR"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--x69MNc9CAotLIveb9QpeuxLk0NKIRUiwR
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/26/2015 02:51 PM, Vlastimil Babka wrote:
> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for shmem-back=
ed
> mappings, even if the mapped portion does contain pages that were swapp=
ed out.
> This is because unlike private anonymous mappings, shmem does not chang=
e pte
> to swap entry, but pte_none when swapping the page out. In the smaps pa=
ge
> walk, such page thus looks like it was never faulted in.
>=20
> This patch changes smaps_pte_entry() to determine the swap status for s=
uch
> pte_none entries for shmem mappings, similarly to how mincore_page() do=
es it.
> Swapped out pages are thus accounted for.
>=20
> The accounting is arguably still not as precise as for private anonymou=
s
> mappings, since now we will count also pages that the process in questi=
on never
> accessed, but only another process populated them and then let them bec=
ome
> swapped out. I believe it is still less confusing and subtle than not s=
howing
> any swap usage by shmem mappings at all. Also, swapped out pages only b=
ecomee a
> performance issue for future accesses, and we cannot predict those for =
neither
> kind of mapping.
>=20
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---
>  Documentation/filesystems/proc.txt |  3 ++-
>  fs/proc/task_mmu.c                 | 20 ++++++++++++++++++++
>  2 files changed, 22 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesys=
tems/proc.txt
> index d4f56ec..8b30543 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -437,7 +437,8 @@ indicates the amount of memory currently marked as =
referenced or accessed.
>  a mapping associated with a file may contain anonymous pages: when MAP=
_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymo=
us copy.
>  "Swap" shows how much would-be-anonymous memory is also used, but out =
on
> -swap.
> +swap. For shmem mappings, "Swap" shows how much of the mapped portion =
of the
> +underlying shmem object is on swap.
> =20
>  "VmFlags" field deserves a separate description. This member represent=
s the kernel
>  flags associated with the particular virtual memory area in two letter=
 encoded
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 956b75d..0410309 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -13,6 +13,7 @@
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
>  #include <linux/mmu_notifier.h>
> +#include <linux/shmem_fs.h>
> =20
>  #include <asm/elf.h>
>  #include <asm/uaccess.h>
> @@ -496,6 +497,25 @@ static void smaps_pte_entry(pte_t *pte, unsigned l=
ong addr,
>  			mss->swap +=3D PAGE_SIZE;
>  		else if (is_migration_entry(swpent))
>  			page =3D migration_entry_to_page(swpent);
> +	} else if (IS_ENABLED(CONFIG_SHMEM) && IS_ENABLED(CONFIG_SWAP) &&
> +					pte_none(*pte) && vma->vm_file) {
> +		struct address_space *mapping =3D
> +			file_inode(vma->vm_file)->i_mapping;
> +
> +		/*
> +		 * shmem does not use swap pte's so we have to consult
> +		 * the radix tree to account for swap
> +		 */
> +		if (shmem_mapping(mapping)) {
> +			page =3D find_get_entry(mapping, pgoff);
> +			if (page) {
> +				if (radix_tree_exceptional_entry(page))
> +					mss->swap +=3D PAGE_SIZE;
> +				else
> +					page_cache_release(page);
> +			}
> +			page =3D NULL;
> +		}

Hi Vlastimil,

I'm afraid that isn't enough. Without walking the pte holes too, big
chunks of swapped out shmem pages may be missed.

Jerome

>  	}
> =20
>  	if (!page)
>=20



--x69MNc9CAotLIveb9QpeuxLk0NKIRUiwR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU7zAtAAoJEHTzHJCtsuoCmYgH/jPt+dg/koiW8YDPRAm/KqRh
y9HLxw4eAiNLleCoanjKod4mJ2VUczb+ZNANJCNJabiOfr6mkgSGArWz2QCHUZtW
q/VBwvJCKSZqG+u1aiF2KpHRGPzWMbk/pRc4o/vwHFq1hBdNDg8jDsv2/fxK0G+K
OcOibXdq10e/k/bpN99rkPI9/nssM9SAKS/fgW0e9obFJK6GvrlGSengcDLxD/xB
FAewDt+OnnmwxwoJXC3p4sZnO9oEuDnmQ1UoLZYOIo4COIeIBkMQa9II8cQjm3d0
/6bHDR+j4PUs8fRHEchS6UXf/G+nqeR2I2UVmQpeEXCM8UI9mWnO/XELbD2kEo4=
=FZN2
-----END PGP SIGNATURE-----

--x69MNc9CAotLIveb9QpeuxLk0NKIRUiwR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
