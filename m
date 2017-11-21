Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D9A316B0038
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 17:45:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id 4so8695763wrt.8
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 14:45:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s14si8919192wrb.284.2017.11.21.14.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Nov 2017 14:45:31 -0800 (PST)
Date: Tue, 21 Nov 2017 14:45:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/10] remove mapping from balance_dirty_pages*()
Message-Id: <20171121144528.c44458f50738d73cab3aca4b@linux-foundation.org>
In-Reply-To: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
References: <1510696616-8489-1-git-send-email-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, jack@suse.cz, linux-fsdevel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, Josef Bacik <jbacik@fb.com>

On Tue, 14 Nov 2017 16:56:47 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> From: Josef Bacik <jbacik@fb.com>
> 
> The only reason we pass in the mapping is to get the inode in order to see if
> writeback cgroups is enabled, and even then it only checks the bdi and a super
> block flag.  balance_dirty_pages() doesn't even use the mapping.  Since
> balance_dirty_pages*() works on a bdi level, just pass in the bdi and super
> block directly so we can avoid using mapping.  This will allow us to still use
> balance_dirty_pages for dirty metadata pages that are not backed by an
> address_mapping.
>
> ...
> 
> @@ -71,7 +72,8 @@ static int _block2mtd_erase(struct block2mtd_dev *dev, loff_t to, size_t len)
>  				memset(page_address(page), 0xff, PAGE_SIZE);
>  				set_page_dirty(page);
>  				unlock_page(page);
> -				balance_dirty_pages_ratelimited(mapping);
> +				balance_dirty_pages_ratelimited(inode_to_bdi(inode),
> +								inode->i_sb);
>  				break;
>  			}

So we do a bunch more work in each caller and we pass two args rather
than one.  That doesn't make things better!

I see that this is enablement for "dirty metadata pages that are not
backed by an address_mapping" (address_space) so I look into [7/10] and
the changelog doesn't tell me much.

So color me confused.  What is this patchset actually *for*?  Is there
some filesystem which has non-address_space-backed metadata?  Or will
there be so soon?  Or what.

I think we need a [0/n] email please.  One which fully describes the
intent of the patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
