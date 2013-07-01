Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8103D6B0031
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 11:49:55 -0400 (EDT)
Date: Mon, 1 Jul 2013 15:49:54 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm/slab: Fix /proc/slabinfo unwriteable for slab
In-Reply-To: <1372069394-26167-3-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <0000013f9aed0ce5-ff542635-3074-4f9b-842e-d04492ed3e90-000000@email.amazonses.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com> <1372069394-26167-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 24 Jun 2013, Wanpeng Li wrote:

>  1 file changed, 10 insertions(+)
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index d161b81..7fdde79 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -631,10 +631,20 @@ static const struct file_operations proc_slabinfo_operations = {
>  	.release	= seq_release,
>  };
>
> +#ifdef CONFIG_SLAB
> +static int __init slab_proc_init(void)
> +{
> +	proc_create("slabinfo", S_IWUSR | S_IRUSR, NULL, &proc_slabinfo_operations);
> +	return 0;
> +}
> +#endif
> +#ifdef CONFIG_SLUB
>  static int __init slab_proc_init(void)
>  {
>  	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
>  	return 0;
>  }

It may be easier to define a macro SLABINFO_RIGHTS and use #ifdefs to
assign the correct one. That way we have only one slab_proc_init().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
