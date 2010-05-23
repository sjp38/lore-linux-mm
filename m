Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 224AE6002CC
	for <linux-mm@kvack.org>; Sun, 23 May 2010 11:19:53 -0400 (EDT)
Message-ID: <4BF94792.5030405@redhat.com>
Date: Sun, 23 May 2010 18:19:46 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net> <1274551731-4534-3-git-send-email-cesarb@cesarb.net>
In-Reply-To: <1274551731-4534-3-git-send-email-cesarb@cesarb.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 05/22/2010 09:08 PM, Cesar Eduardo Barros wrote:
> Add support for checksumming the swap pages written to disk, using the
> same checksum as btrfs (crc32c). Since the contents of the swap do not
> matter after a shutdown, the checksum is kept in memory only.
>
> Note that this code does not checksum the software suspend image.
>
>
>
>   #define SWAP_FLAG_PREFER	0x8000	/* set if swap priority specified */
>   #define SWAP_FLAG_PRIO_MASK	0x7fff
> @@ -180,6 +183,10 @@ struct swap_info_struct {
>   	struct swap_extent *curr_swap_extent;
>   	struct swap_extent first_swap_extent;
>   	struct block_device *bdev;	/* swap device or bdev of swap file */
> +#ifdef CONFIG_SWAP_CHECKSUM
> +	unsigned short *csum_count;	/* usage count of a csum page */
> +	u32 **csum;			/* vmalloc'ed array of swap csums */
> +#endif
>   	struct file *swap_file;		/* seldom referenced */
>   	unsigned int old_block_size;	/* seldom referenced */
>   };
>    

On 64-bit, we may be able to store the checksum in the pte, if the swap 
device is small enough.

If we take the trouble to touch the page, we may as well compare it 
against zero, and if so drop it instead of swapping it out.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
