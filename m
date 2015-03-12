Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A5A138299B
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 11:26:42 -0400 (EDT)
Received: by pdbnh10 with SMTP id nh10so20935321pdb.4
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 08:26:42 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id t8si13687426pdj.194.2015.03.12.08.26.41
        for <linux-mm@kvack.org>;
        Thu, 12 Mar 2015 08:26:41 -0700 (PDT)
Date: Thu, 12 Mar 2015 11:26:40 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4] Allow compaction of unevictable pages
Message-ID: <20150312152640.GB2310@akamai.com>
References: <1426173776-23471-1-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Bn2rw/3z4jIqBvZU"
Content-Disposition: inline
In-Reply-To: <1426173776-23471-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--Bn2rw/3z4jIqBvZU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 12 Mar 2015, Eric B Munson wrote:

> Currently, pages which are marked as unevictable are protected from
> compaction, but not from other types of migration.  The mlock
> desctription does not promise that all page faults will be avoided, only
> major ones so this protection is not necessary.  This extra protection
> can cause problems for applications that are using mlock to avoid
> swapping pages out, but require order > 0 allocations to continue to
> succeed in a fragmented environment.  This patch adds a sysctl entry
> that will be used to allow root to enable compaction of unevictable
> pages.
>=20
> To illustrate this problem I wrote a quick test program that mmaps a
> large number of 1MB files filled with random data.  These maps are
> created locked and read only.  Then every other mmap is unmapped and I
> attempt to allocate huge pages to the static huge page pool.  When the
> compact_unevictable sysctl is 0, I cannot allocate hugepages after
> fragmenting memory.  When the value is set to 1, allocations succeed.
>=20
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
> Changes from V3:
> Instead of removing the ISOLATE_UNEVICTABLE mode and checks, allow the
> sysadmin to control if compaction of unevictable pages is allowable.
>=20
>  include/linux/compaction.h |    1 +
>  kernel/sysctl.c            |    7 +++++++
>  mm/compaction.c            |    3 +++
>  3 files changed, 11 insertions(+)
>=20
> diff --git a/include/linux/compaction.h b/include/linux/compaction.h
> index a014559..9dd7e7c 100644
> --- a/include/linux/compaction.h
> +++ b/include/linux/compaction.h
> @@ -34,6 +34,7 @@ extern int sysctl_compaction_handler(struct ctl_table *=
table, int write,
>  extern int sysctl_extfrag_threshold;
>  extern int sysctl_extfrag_handler(struct ctl_table *table, int write,
>  			void __user *buffer, size_t *length, loff_t *ppos);
> +extern int sysctl_compact_unevictable;
> =20
>  extern int fragmentation_index(struct zone *zone, unsigned int order);
>  extern unsigned long try_to_compact_pages(gfp_t gfp_mask, unsigned int o=
rder,
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 88ea2d6..cc1a678 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1313,6 +1313,13 @@ static struct ctl_table vm_table[] =3D {
>  		.extra1		=3D &min_extfrag_threshold,
>  		.extra2		=3D &max_extfrag_threshold,
>  	},
> +	{
> +		.procname	=3D "compact_unevictable",
> +		.data		=3D &sysctl_compact_unevictable,
> +		.maxlen		=3D sizeof(int),
> +		.mode		=3D 0644,
> +		.proc_handler	=3D proc_dointvec,
> +	},
> =20
>  #endif /* CONFIG_COMPACTION */
>  	{
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 8c0d945..b2c1e4e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1046,6 +1046,8 @@ typedef enum {
>  	ISOLATE_SUCCESS,	/* Pages isolated, migrate */
>  } isolate_migrate_t;
> =20
> +int sysctl_compact_unevictable;
> +
>  /*
>   * Isolate all pages that can be migrated from the first suitable block,
>   * starting at the block pointed to by the migrate scanner pfn within
> @@ -1057,6 +1059,7 @@ static isolate_migrate_t isolate_migratepages(struc=
t zone *zone,
>  	unsigned long low_pfn, end_pfn;
>  	struct page *page;
>  	const isolate_mode_t isolate_mode =3D
> +		(sysctl_compact_unevictable ? ISOLATE_UNEVICTABLE: 0) |

Sorry, missed the space following the :, if this idea is acceptable, I
will send a patch with the correct whitespace.

>  		(cc->mode =3D=3D MIGRATE_ASYNC ? ISOLATE_ASYNC_MIGRATE : 0);
> =20
>  	/*
> --=20
> 1.7.9.5
>=20

--Bn2rw/3z4jIqBvZU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVAbAwAAoJELbVsDOpoOa9Wj0P/2/U+9D6w2NCBBxO2HYUwUBb
QQb/1HdA8RNMfsL84C6m8Bk9TCWgtpx/3atekUZgNm2fFRHAIPZleuSg9HQ9AhrT
4XPRyo8FOYxP4fy2/OVIMgPs4YYStYydYqN2KKol2L1UBRhMqwof8nkrrHkRCR2M
vVMH6O/MvTMS75OKTmdYKuftEKj6LKo9923eMJ+OVT/tZbeq8+RoTktLmZgSxhRN
zcUYrlQn8v+M0jSwdTBh3njPfxfsseO5003R+GrmRTIDjhTPWQE0dbtqK8KdHOWi
vvkyXiTAKYNC8vT9z3hZ4iskbfUWmh5z+21/MFI0nzd3/naRekHM+U5BXMhBgw64
XuJAr30L5BOlQn7Pxha9fFvXrqbq5W7qj4lv4vpqJQIzqntK8DWuvOYZQw5BUOe6
c0ng4iIfS3hcNsGUXn02SkJyHgIBZW1gnM+Rcd3jg9Y3AFunmT5GLcYt2Ll59h5i
bM4zT17Y8RiTn4dLbixe25dKOYoz0qhY9KHrop9VCyEbAC3Gde9reRtzdla80zPN
c8tRBLZAmW1Fd/ShqxAtU3CPtweNdTS7kZTnaIbbOrJapaTRglsLKiaBA1UX8gyU
3EgNW4z3lPoLqO53T/xwEruXU+aXXW0Rwrgfs+W46oie0UpZwtT9F7dIChvoKsxz
HD0UycIDTJgeYH/CVLzb
=NqTU
-----END PGP SIGNATURE-----

--Bn2rw/3z4jIqBvZU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
