Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4BDE6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 09:59:26 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n13so41592596ita.7
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 06:59:26 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l26si28723811pli.24.2017.06.01.06.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 06:59:26 -0700 (PDT)
Received: from mail-ua0-f182.google.com (mail-ua0-f182.google.com [209.85.217.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8EF3A2395B
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 13:59:25 +0000 (UTC)
Received: by mail-ua0-f182.google.com with SMTP id x47so27939163uab.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 06:59:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170531150349.4816-1-jglisse@redhat.com>
References: <20170531150349.4816-1-jglisse@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 1 Jun 2017 06:59:04 -0700
Message-ID: <CALCETrVyY9zZz311i45Mh7284kf2vnoN0JTEvcPE1GOzosW_-Q@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: do not BUG_ON() on stall pgd entries
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, May 31, 2017 at 8:03 AM, J=C3=A9r=C3=B4me Glisse <jglisse@redhat.co=
m> wrote:
> Since af2cf278ef4f ("Don't remove PGD entries in remove_pagetable()")
> we no longer cleanup stall pgd entries and thus the BUG_ON() inside
> sync_global_pgds() is wrong.
>
> This patch remove the BUG_ON() and unconditionaly update stall pgd
> entries.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/mm/init_64.c | 7 +------
>  1 file changed, 1 insertion(+), 6 deletions(-)
>
> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index ff95fe8..36b9020 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -123,12 +123,7 @@ void sync_global_pgds(unsigned long start, unsigned =
long end)
>                         pgt_lock =3D &pgd_page_get_mm(page)->page_table_l=
ock;
>                         spin_lock(pgt_lock);
>
> -                       if (!p4d_none(*p4d_ref) && !p4d_none(*p4d))
> -                               BUG_ON(p4d_page_vaddr(*p4d)
> -                                      !=3D p4d_page_vaddr(*p4d_ref));
> -
> -                       if (p4d_none(*p4d))
> -                               set_p4d(p4d, *p4d_ref);
> +                       set_p4d(p4d, *p4d_ref);

If we have a mismatch in the vmalloc range, vmalloc_fault is going to
screw up and we'll end up using incorrect page tables.

What's causing the mismatch?  If you're hitting this BUG in practice,
I suspect we have a bug elsewhere.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
