Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0ADD16B0087
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:22:55 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 88DE282C5A1
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:36:34 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Zhjb4NvsCqFQ for <linux-mm@kvack.org>;
	Wed, 20 May 2009 14:36:34 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 84D5D82C5A5
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:36:30 -0400 (EDT)
Date: Wed, 20 May 2009 14:23:00 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm/slub.c: Use print_hex_dump and remove unnecessary
 cast
In-Reply-To: <1242840314-25635-1-git-send-email-joe@perches.com>
Message-ID: <alpine.DEB.1.10.0905201420050.17511@qirst.com>
References: <1242840314-25635-1-git-send-email-joe@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, H Hartley Sweeten <hartleys@visionengravers.com>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, David Rientjes <rientjes@google.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

This was discussed before.

http://lkml.indiana.edu/hypermail/linux/kernel/0705.3/2671.html

Was hexdump changed? How does the output look after this change?

On Wed, 20 May 2009, Joe Perches wrote:

> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  mm/slub.c |   34 ++++------------------------------
>  1 files changed, 4 insertions(+), 30 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 65ffda5..5b616d6 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -328,36 +328,10 @@ static char *slub_debug_slabs;
>  /*
>   * Object debugging
>   */
> -static void print_section(char *text, u8 *addr, unsigned int length)
> +static void print_section(const char *text, u8 *addr, unsigned int length)
>  {
> -	int i, offset;
> -	int newline = 1;
> -	char ascii[17];
> -
> -	ascii[16] = 0;
> -
> -	for (i = 0; i < length; i++) {
> -		if (newline) {
> -			printk(KERN_ERR "%8s 0x%p: ", text, addr + i);
> -			newline = 0;
> -		}
> -		printk(KERN_CONT " %02x", addr[i]);
> -		offset = i % 16;
> -		ascii[offset] = isgraph(addr[i]) ? addr[i] : '.';
> -		if (offset == 15) {
> -			printk(KERN_CONT " %s\n", ascii);
> -			newline = 1;
> -		}
> -	}
> -	if (!newline) {
> -		i %= 16;
> -		while (i < 16) {
> -			printk(KERN_CONT "   ");
> -			ascii[i] = ' ';
> -			i++;
> -		}
> -		printk(KERN_CONT " %s\n", ascii);
> -	}
> +	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1,
> +		       addr, length, true);
>  }
>
>  static struct track *get_track(struct kmem_cache *s, void *object,
> @@ -794,7 +768,7 @@ static void trace(struct kmem_cache *s, struct page *page, void *object,
>  			page->freelist);
>
>  		if (!alloc)
> -			print_section("Object", (void *)object, s->objsize);
> +			print_section("Object", object, s->objsize);
>
>  		dump_stack();
>  	}
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
