Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 23F3A6B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 20:10:06 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wp18so5680338obc.1
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 17:10:05 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id ej6si12708737obb.33.2015.01.13.17.10.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 17:10:04 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/1] mm: pagemap: limit scan to virtual region being
 asked
Date: Wed, 14 Jan 2015 01:08:40 +0000
Message-ID: <20150114010830.GA16100@hori1.linux.bs1.fc.nec.co.jp>
References: <1421152024-6204-1-git-send-email-shashim@codeaurora.org>
In-Reply-To: <1421152024-6204-1-git-send-email-shashim@codeaurora.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D1A14A54079C204688E385502014D5D0@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shiraz Hashim <shashim@codeaurora.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "oleg@redhat.com" <oleg@redhat.com>, "gorcunov@openvz.org" <gorcunov@openvz.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jan 13, 2015 at 05:57:04PM +0530, Shiraz Hashim wrote:
> pagemap_read scans through the virtual address space of a
> task till it prepares 'count' pagemaps or it reaches end
> of task.
>=20
> This presents a problem when the page walk doesn't happen
> for vma with VM_PFNMAP set. In which case walk is silently
> skipped and no pagemap is prepare, in turn making
> pagemap_read to scan through task end, even crossing beyond
> 'count', landing into a different vma region. This leads to
> wrong presentation of mappings for that vma.
>=20
> Fix this by limiting end_vaddr to the end of the virtual
> address region being scanned.
>=20
> Signed-off-by: Shiraz Hashim <shashim@codeaurora.org>

This patch works in some case, but there still seems a problem in another c=
ase.

Consider that we have two vmas within some narrow (PAGEMAP_WALK_SIZE) regio=
n.
One vma in lower address is VM_PFNMAP, and the other vma in higher address =
is not.
Then a single call of walk_page_range() skips the first vma and scans the
second vma, but the pagemap record of the second vma will be stored on the
wrong offset in the buffer, because we just skip vma(VM_PFNMAP) without cal=
ling
any callbacks (within which add_to_pagemap() increments pm.pos).

So calling pte_hole() for vma(VM_PFNMAP) looks a better fix to me.

Thanks,
Naoya Horiguchi

> ---
>  fs/proc/task_mmu.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 246eae8..04362e4 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1270,7 +1270,9 @@ static ssize_t pagemap_read(struct file *file, char=
 __user *buf,
>  	src =3D *ppos;
>  	svpfn =3D src / PM_ENTRY_BYTES;
>  	start_vaddr =3D svpfn << PAGE_SHIFT;
> -	end_vaddr =3D TASK_SIZE_OF(task);
> +	end_vaddr =3D start_vaddr + ((count / PM_ENTRY_BYTES) << PAGE_SHIFT);
> +	if ((end_vaddr > TASK_SIZE_OF(task)) || (end_vaddr < start_vaddr))
> +		end_vaddr =3D TASK_SIZE_OF(task);
> =20
>  	/* watch out for wraparound */
>  	if (svpfn > TASK_SIZE_OF(task) >> PAGE_SHIFT)
> --=20
>=20
> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
> member of the Code Aurora Forum, hosted by The Linux Foundation
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
