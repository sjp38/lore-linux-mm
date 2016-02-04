Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3834D4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 03:31:22 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l66so105788610wml.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 00:31:22 -0800 (PST)
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com. [195.75.94.101])
        by mx.google.com with ESMTPS id ff13si16279194wjc.41.2016.02.04.00.31.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 04 Feb 2016 00:31:21 -0800 (PST)
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 4 Feb 2016 08:31:20 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D65261B0805F
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 08:31:26 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u148VF7F8782266
	for <linux-mm@kvack.org>; Thu, 4 Feb 2016 08:31:15 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u148VFbi005547
	for <linux-mm@kvack.org>; Thu, 4 Feb 2016 03:31:15 -0500
Subject: Re: [PATCH 2/5] mm/slub: query dynamic DEBUG_PAGEALLOC setting
References: <1454565386-10489-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1454565386-10489-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56B30C52.7040907@de.ibm.com>
Date: Thu, 4 Feb 2016 09:31:14 +0100
MIME-Version: 1.0
In-Reply-To: <1454565386-10489-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/04/2016 06:56 AM, Joonsoo Kim wrote:
> We can disable debug_pagealloc processing even if the code is complied
> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
> whether it is enabled or not in runtime.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> ---
>  mm/slub.c | 11 ++++++-----
>  1 file changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 7d4da68..7b5a965 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -256,11 +256,12 @@ static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
>  {
>  	void *p;
> 
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> -	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
> -#else
> -	p = get_freepointer(s, object);
> -#endif
> +	if (debug_pagealloc_enabled()) {
> +		probe_kernel_read(&p,
> +			(void **)(object + s->offset), sizeof(p));

Hmm, this might be a good case for a line longer than 80 chars....

As an alternative revert the logic and return early:


	if (!debug_pagealloc_enabled())
		return get_freepointer(s, object);
	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
	return p;

?


> +	} else
> +		p = get_freepointer(s, object);
> +
>  	return p;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
