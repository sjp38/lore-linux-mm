Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id D56EB6B0254
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 07:17:48 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so66313068wme.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 04:17:48 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id s18si11669559wjw.150.2016.02.11.04.17.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Feb 2016 04:17:47 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 11 Feb 2016 12:17:47 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id D9817219005C
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:17:29 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1BCHi7416121928
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 12:17:44 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1BCHhkD006973
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 05:17:43 -0700
Subject: Re: [PATCH v2 2/5] mm/slub: query dynamic DEBUG_PAGEALLOC setting
References: <1455163501-9341-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1455163501-9341-3-git-send-email-iamjoonsoo.kim@lge.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56BC7BE6.7000802@de.ibm.com>
Date: Thu, 11 Feb 2016 13:17:42 +0100
MIME-Version: 1.0
In-Reply-To: <1455163501-9341-3-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Takashi Iwai <tiwai@suse.com>, Chris Metcalf <cmetcalf@ezchip.com>, Christoph Lameter <cl@linux.com>, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 02/11/2016 05:04 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> We can disable debug_pagealloc processing even if the code is compiled
> with CONFIG_DEBUG_PAGEALLOC. This patch changes the code to query
> whether it is enabled or not in runtime.
> 
> v2: clean up code, per Christian.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Christian Borntraeger <borntraeger@de.ibm.com>

> ---
>  mm/slub.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 606488b..a1874c2 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -250,11 +250,10 @@ static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
>  {
>  	void *p;
> 
> -#ifdef CONFIG_DEBUG_PAGEALLOC
> +	if (!debug_pagealloc_enabled())
> +		return get_freepointer(s, object);
> +
>  	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
> -#else
> -	p = get_freepointer(s, object);
> -#endif
>  	return p;
>  }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
