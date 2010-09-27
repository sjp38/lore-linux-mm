Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 182156B0047
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 02:37:58 -0400 (EDT)
Received: by iwn33 with SMTP id 33so6217909iwn.14
        for <linux-mm@kvack.org>; Sun, 26 Sep 2010 23:37:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m1iq1t9z3y.fsf@fess.ebiederm.org>
References: <m1sk0x9z62.fsf@fess.ebiederm.org>
	<m1iq1t9z3y.fsf@fess.ebiederm.org>
Date: Mon, 27 Sep 2010 09:37:56 +0300
Message-ID: <AANLkTin4DKGhcZ4=os1-NxrQ65pEDZ+USG1xpW54y4_T@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm: Consolidate vma destruction into remove_vma.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Eric,

On Sun, Sep 26, 2010 at 2:34 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Consolidate vma destruction in remove_vma. =A0 This is slightly
> better for code size and for code maintenance. =A0Avoiding the pain
> of 3 copies of everything needed to tear down a vma.
>
> Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
> ---
> =A0mm/mmap.c | =A0 21 +++++----------------
> =A01 files changed, 5 insertions(+), 16 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 6128dc8..17dd003 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -643,16 +643,10 @@ again: =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0remov=
e_next =3D 1 + (end > next->vm_end);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock(&mapping->i_mmap_lock);
>
> =A0 =A0 =A0 =A0if (remove_next) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (file) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(file);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (next->vm_flags & VM_EXE=
CUTABLE)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 removed_exe=
_file_vma(mm);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (next->anon_vma)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0anon_vma_merge(vma, next);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 remove_vma(next);

remove_vma() does vma->vm_ops->close() but we don't do that here. Are
you sure the conversion is safe?

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mm->map_count--;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mpol_put(vma_policy(next));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmem_cache_free(vm_area_cachep, next);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * In mprotect's case 6 (see comments on v=
ma_merge),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * we must remove another next too. It wou=
ld clutter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
