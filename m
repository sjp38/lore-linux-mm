Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D33E76B0253
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 15:52:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 194so118622156pgd.7
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 12:52:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p8si1763118pll.261.2017.02.06.12.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 12:52:31 -0800 (PST)
From: "Xiong, Jinshan" <jinshan.xiong@intel.com>
Subject: Re: [lustre-devel] [PATCH] mm: Avoid returning VM_FAULT_RETRY from
 ->page_mkwrite handlers
Date: Mon, 6 Feb 2017 20:52:29 +0000
Message-ID: <4CD0030B-EA76-4E3D-B9F4-B2E96D05C5B6@intel.com>
References: <20170203150729.15863-1-jack@suse.cz>
In-Reply-To: <20170203150729.15863-1-jack@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4B149C28DCB76C4597D44E41B8BFBBD2@intel.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, "cluster-devel@redhat.com" <cluster-devel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>, "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>

looks good to me.

Reviewed-by: Jinshan Xiong <jinshan.xiong@intel.com>

> On Feb 3, 2017, at 7:07 AM, Jan Kara <jack@suse.cz> wrote:
>=20
> Some ->page_mkwrite handlers may return VM_FAULT_RETRY as its return
> code (GFS2 or Lustre can definitely do this). However VM_FAULT_RETRY
> from ->page_mkwrite is completely unhandled by the mm code and results
> in locking and writeably mapping the page which definitely is not what
> the caller wanted. Fix Lustre and block_page_mkwrite_ret() used by other
> filesystems (notably GFS2) to return VM_FAULT_NOPAGE instead which
> results in bailing out from the fault code, the CPU then retries the
> access, and we fault again effectively doing what the handler wanted.
>=20
> CC: lustre-devel@lists.lustre.org
> CC: cluster-devel@redhat.com
> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
> drivers/staging/lustre/lustre/llite/llite_mmap.c | 4 +---
> include/linux/buffer_head.h                      | 4 +---
> 2 files changed, 2 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/staging/lustre/lustre/llite/llite_mmap.c b/drivers/s=
taging/lustre/lustre/llite/llite_mmap.c
> index ee01f20d8b11..9afa6bec3e6f 100644
> --- a/drivers/staging/lustre/lustre/llite/llite_mmap.c
> +++ b/drivers/staging/lustre/lustre/llite/llite_mmap.c
> @@ -390,15 +390,13 @@ static int ll_page_mkwrite(struct vm_area_struct *v=
ma, struct vm_fault *vmf)
> 		result =3D VM_FAULT_LOCKED;
> 		break;
> 	case -ENODATA:
> +	case -EAGAIN:
> 	case -EFAULT:
> 		result =3D VM_FAULT_NOPAGE;
> 		break;
> 	case -ENOMEM:
> 		result =3D VM_FAULT_OOM;
> 		break;
> -	case -EAGAIN:
> -		result =3D VM_FAULT_RETRY;
> -		break;
> 	default:
> 		result =3D VM_FAULT_SIGBUS;
> 		break;
> diff --git a/include/linux/buffer_head.h b/include/linux/buffer_head.h
> index d67ab83823ad..79591c3660cc 100644
> --- a/include/linux/buffer_head.h
> +++ b/include/linux/buffer_head.h
> @@ -243,12 +243,10 @@ static inline int block_page_mkwrite_return(int err=
)
> {
> 	if (err =3D=3D 0)
> 		return VM_FAULT_LOCKED;
> -	if (err =3D=3D -EFAULT)
> +	if (err =3D=3D -EFAULT || err =3D=3D -EAGAIN)
> 		return VM_FAULT_NOPAGE;
> 	if (err =3D=3D -ENOMEM)
> 		return VM_FAULT_OOM;
> -	if (err =3D=3D -EAGAIN)
> -		return VM_FAULT_RETRY;
> 	/* -ENOSPC, -EDQUOT, -EIO ... */
> 	return VM_FAULT_SIGBUS;
> }
> --=20
> 2.10.2
>=20
> _______________________________________________
> lustre-devel mailing list
> lustre-devel@lists.lustre.org
> http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
