Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 2A6426B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:38:13 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id n12so2865844oag.17
        for <linux-mm@kvack.org>; Wed, 15 May 2013 14:38:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130515090602.28109.90142.stgit@localhost6.localdomain6>
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090602.28109.90142.stgit@localhost6.localdomain6>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 15 May 2013 17:37:52 -0400
Message-ID: <CAHGf_=q-91cYOMPFfSGLsWWst7STgp6pxX4__9UMYUGh=Ef3oA@mail.gmail.com>
Subject: Re: [PATCH v6 4/8] vmalloc: make find_vm_area check in range
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: vgoyal@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>, Andrew Morton <akpm@linux-foundation.org>, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>

On Wed, May 15, 2013 at 5:06 AM, HATAYAMA Daisuke
<d.hatayama@jp.fujitsu.com> wrote:
> Currently, __find_vmap_area searches for the kernel VM area starting
> at a given address. This patch changes this behavior so that it
> searches for the kernel VM area to which the address belongs. This
> change is needed by remap_vmalloc_range_partial to be introduced in
> later patch that receives any position of kernel VM area as target
> address.
>
> This patch changes the condition (addr > va->va_start) to the
> equivalent (addr >= va->va_end) by taking advantage of the fact that
> each kernel VM area is non-overlapping.
>
> Signed-off-by: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
> ---
>
>  mm/vmalloc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index d365724..3875fa2 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -292,7 +292,7 @@ static struct vmap_area *__find_vmap_area(unsigned long addr)
>                 va = rb_entry(n, struct vmap_area, rb_node);
>                 if (addr < va->va_start)
>                         n = n->rb_left;
> -               else if (addr > va->va_start)
> +               else if (addr >= va->va_end)
>                         n = n->rb_right;

OK. This is natural definition. Looks good.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
