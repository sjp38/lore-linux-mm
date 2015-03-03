Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC716B006E
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 07:36:22 -0500 (EST)
Received: by lbiv13 with SMTP id v13so18112808lbi.1
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 04:36:20 -0800 (PST)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id zp8si441857lbc.62.2015.03.03.04.36.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 04:36:19 -0800 (PST)
Received: by lbdu10 with SMTP id u10so36705449lbd.7
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 04:36:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
References: <1425384142-5064-1-git-send-email-chianglungyu@gmail.com>
Date: Tue, 3 Mar 2015 16:36:18 +0400
Message-ID: <CALYGNiOAEp71wG6XagLuY+6xqVSuPTHGvb2X-HdwYhD3PMqsVg@mail.gmail.com>
Subject: Re: [PATCH] mm: fix anon_vma->degree underflow in anon_vma endless
 growing prevention
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Leon Yu <chianglungyu@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stable <stable@vger.kernel.org>

On Tue, Mar 3, 2015 at 3:02 PM, Leon Yu <chianglungyu@gmail.com> wrote:
> I have constantly stumbled upon "kernel BUG at mm/rmap.c:399!" after upgrading
> to 3.19 and had no luck with 4.0-rc1 neither.
>
> So, after looking into new logic introduced by commit 7a3ef208e662, ("mm:
> prevent endless growth of anon_vma hierarchy"), I found chances are that
> unlink_anon_vmas() is called without incrementing dst->anon_vma->degree in
> anon_vma_clone() due to allocation failure. If dst->anon_vma is not NULL in
> error path, its degree will be incorrectly decremented in unlink_anon_vmas()
> and eventually underflow when exiting as a result of another call to
> unlink_anon_vmas(). That's how "kernel BUG at mm/rmap.c:399!" is triggered
> for me.
>
> This patch fixes the underflow by dropping dst->anon_vma when allocation
> fails. It's safe to do so regardless of original value of dst->anon_vma
> because dst->anon_vma doesn't have valid meaning if anon_vma_clone() fails.
> Besides, callers don't care dst->anon_vma in such case neither.
>
> Signed-off-by: Leon Yu <chianglungyu@gmail.com>
> Fixes: 7a3ef208e662 ("mm: prevent endless growth of anon_vma hierarchy")
> Cc: stable@vger.kernel.org # v3.19

Good catch.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>

That thing already backported into various stable branches so this's
not only for v3.19.

As I see other error paths are fine.

> ---
>  mm/rmap.c | 7 +++++++
>  1 file changed, 7 insertions(+)
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 5e3e090..bed3cf2 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -287,6 +287,13 @@ int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
>         return 0;
>
>   enomem_failure:
> +       /*
> +        * dst->anon_vma is dropped here otherwise its degree can be incorrectly
> +        * decremented in unlink_anon_vmas().
> +        * We can safely do this because calllers of anon_vma_clone() wouldn't
> +        * care dst->anon_vma if anon_vma_clone() failed.
> +        */
> +       dst->anon_vma = NULL;
>         unlink_anon_vmas(dst);
>         return -ENOMEM;
>  }
> --
> 2.3.1
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
