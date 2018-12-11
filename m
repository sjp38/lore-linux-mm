Return-Path: <linux-kernel-owner@vger.kernel.org>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v2] userfaultfd: clear flag if remap event not enabled
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20181211053409.20317-1-peterx@redhat.com>
Date: Tue, 11 Dec 2018 06:46:13 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <FB9EEE4D-B2E6-44B9-9145-259E785AD3F4@oracle.com>
References: <20181211053409.20317-1-peterx@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Xu <peterx@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Pravin Shedge <pravin.shedge4linux@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



> On Dec 10, 2018, at 10:34 PM, Peter Xu <peterx@redhat.com> wrote:
>=20
> ---
> fs/userfaultfd.c | 10 +++++++++-
> 1 file changed, 9 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> index cd58939dc977..4567b5b6fd32 100644
> --- a/fs/userfaultfd.c
> +++ b/fs/userfaultfd.c
> @@ -736,10 +736,18 @@ void mremap_userfaultfd_prep(struct =
vm_area_struct *vma,
> 	struct userfaultfd_ctx *ctx;
>=20
> 	ctx =3D vma->vm_userfaultfd_ctx.ctx;
> -	if (ctx && (ctx->features & UFFD_FEATURE_EVENT_REMAP)) {
> +
> +	if (!ctx)
> +		return;
> +
> +	if (ctx->features & UFFD_FEATURE_EVENT_REMAP) {
> 		vm_ctx->ctx =3D ctx;
> 		userfaultfd_ctx_get(ctx);
> 		WRITE_ONCE(ctx->mmap_changing, true);
> +	} else {
> +		/* Drop uffd context if remap feature not enabled */
> +		vma->vm_userfaultfd_ctx =3D NULL_VM_UFFD_CTX;
> +		vma->vm_flags &=3D ~(VM_UFFD_WP | VM_UFFD_MISSING);
> 	}
> }
>=20
> --=20
> 2.17.1
>=20

Looks good.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>=
