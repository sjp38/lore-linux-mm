Received: by rv-out-0910.google.com with SMTP id l15so2236602rvb
        for <linux-mm@kvack.org>; Sun, 02 Dec 2007 10:23:35 -0800 (PST)
Message-ID: <84144f020712021023w7137bafbw9e9d114e68ce524d@mail.gmail.com>
Date: Sun, 2 Dec 2007 20:23:35 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [BUG 2.6.24-rc3-git6] SLUB's ksize() fails for size > 2048.
In-Reply-To: <19f34abd0712020843m1dccfa3bu38388e1a53b05fc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200712021939.HHH18792.FLQSOOtFOFJVHM@I-love.SAKURA.ne.jp>
	 <19f34abd0712020830y4825691atdfc9dac07ce4cb35@mail.gmail.com>
	 <19f34abd0712020843m1dccfa3bu38388e1a53b05fc@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Vegard,

On 12/2/07, Vegard Nossum <vegard.nossum@gmail.com> wrote:
> diff --git a/mm/slub.c b/mm/slub.c
> index 9acb413..b9f37cb 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2558,8 +2558,12 @@ size_t ksize(const void *object)
>         if (unlikely(object == ZERO_SIZE_PTR))
>                 return 0;
>
> -       page = get_object_page(object);
> +       page = virt_to_head_page(object);
>         BUG_ON(!page);
> +
> +       if (unlikely(!PageSlab(page)))
> +               return PAGE_SIZE << compound_order(page);
> +
>         s = page->slab;
>         BUG_ON(!s);

Looks good to me.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
