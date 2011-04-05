Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B4A508D003B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2011 02:42:58 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p356gtWQ022338
	for <linux-mm@kvack.org>; Mon, 4 Apr 2011 23:42:56 -0700
Received: from qwf7 (qwf7.prod.google.com [10.241.194.71])
	by kpbe11.cbf.corp.google.com with ESMTP id p356g3Zu017111
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 4 Apr 2011 23:42:54 -0700
Received: by qwf7 with SMTP id 7so38801qwf.24
        for <linux-mm@kvack.org>; Mon, 04 Apr 2011 23:42:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c4f5166f98cb703742191eb74f583bb8011f9cdf.1301984663.git.michael@ellerman.id.au>
References: <c4f5166f98cb703742191eb74f583bb8011f9cdf.1301984663.git.michael@ellerman.id.au>
Date: Mon, 4 Apr 2011 23:42:54 -0700
Message-ID: <BANLkTi=RJ2GHvHQ3mZiQ-L-MTVUQH-V-eA@mail.gmail.com>
Subject: Re: [PATCH] mm: Check we have the right vma in access_process_vm()
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <michael@ellerman.id.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, aarcange@redhat.com, riel@redhat.com, Andrew Morton <akpm@osdl.org>, linuxppc-dev@ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Mon, Apr 4, 2011 at 11:24 PM, Michael Ellerman
<michael@ellerman.id.au> wrote:
> In access_process_vm() we need to check that we have found the right
> vma, not the following vma, before we try to access it. Otherwise
> we might call the vma's access routine with an address which does
> not fall inside the vma.
>
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>

Please note that the code has moved into __access_remote_vm() in
current linus tree. Also, should len be truncated before calling
vma->vm_ops->access() so that we can guarantee it won't overflow past
the end of the vma ?

> diff --git a/mm/memory.c b/mm/memory.c
> index 5823698..7e6f17b 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3619,7 +3619,7 @@ int access_process_vm(struct task_struct *tsk, unsi=
gned long addr, void *buf, in
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0#ifdef CONFIG_HAVE_IOREMAP_PROT
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0vma =3D find_vma(mm, addr)=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vma)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!vma || vma->vm_start >=
 addr)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (vma->vm_ops && vma->vm=
_ops->access)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D vm=
a->vm_ops->access(vma, addr, buf,
> --
> 1.7.1

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
