Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id ADB6E6B0038
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 09:27:09 -0400 (EDT)
Date: Tue, 9 Apr 2013 15:27:04 +0200 (CEST)
From: =?ISO-8859-15?Q?Luk=E1=A8_Czerner?= <lczerner@redhat.com>
Subject: Re: [PATCH v3 08/18] gfs2: use ->invalidatepage() length argument
In-Reply-To: <686810645.4576872.1365512960001.JavaMail.root@redhat.com>
Message-ID: <alpine.LFD.2.00.1304091516210.22989@localhost>
References: <1365498867-27782-1-git-send-email-lczerner@redhat.com> <1365498867-27782-9-git-send-email-lczerner@redhat.com> <686810645.4576872.1365512960001.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: Lukas Czerner <lczerner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, cluster-devel@redhat.com

On Tue, 9 Apr 2013, Bob Peterson wrote:

> Date: Tue, 9 Apr 2013 09:09:20 -0400 (EDT)
> From: Bob Peterson <rpeterso@redhat.com>
> To: Lukas Czerner <lczerner@redhat.com>
> Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
>     linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
>     cluster-devel@redhat.com
> Subject: Re: [PATCH v3 08/18] gfs2: use ->invalidatepage() length argument
> 
> Hi,
> 
> ----- Original Message -----
> | ->invalidatepage() aop now accepts range to invalidate so we can make
> | use of it in gfs2_invalidatepage().
> | 
> | Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> | Cc: cluster-devel@redhat.com
> | ---
> |  fs/gfs2/aops.c |    9 +++++++--
> |  1 files changed, 7 insertions(+), 2 deletions(-)
> | 
> | diff --git a/fs/gfs2/aops.c b/fs/gfs2/aops.c
> | index 37093ba..ea920bf 100644
> | --- a/fs/gfs2/aops.c
> | +++ b/fs/gfs2/aops.c
> | @@ -947,24 +947,29 @@ static void gfs2_invalidatepage(struct page *page,
> | unsigned int offset,
> |  				unsigned int length)
> |  {
> |  	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
> | +	unsigned int stop = offset + length;
> | +	int partial_page = (offset || length < PAGE_CACHE_SIZE);
> |  	struct buffer_head *bh, *head;
> |  	unsigned long pos = 0;
> |  
> |  	BUG_ON(!PageLocked(page));
> | -	if (offset == 0)
> | +	if (!partial_page)
> |  		ClearPageChecked(page);
> |  	if (!page_has_buffers(page))
> |  		goto out;
> |  
> |  	bh = head = page_buffers(page);
> |  	do {
> | +		if (pos + bh->b_size > stop)
> | +			return;
> | +
> 
> I always regret it when I review something this early in the morning,
> or post before the caffeine has taken full effect. But...
> Shouldn't the statement above be (1) ">= stop" and (2) goto out;?

Hi,

1: No, because "stop = offset + length" and we're comparing it with
   "pos + bh->b_size". If it would be ">=" then we would always miss
   the last buffer. Let's assume pos = 0, b_size = 1024 and we're
   invalidating offset = 0 and length = 1024 .. the rest you can try
   for yourself :)

2: No, because if this condition is true, we can never have full page
   invalidate. With full page invalidation we'll walk all the
   buffers within the page hence we would jump our of the cycle when
   "bh == head".

Thanks!
-Lukas

> 
> |  		if (offset <= pos)
> |  			gfs2_discard(sdp, bh);
> |  		pos += bh->b_size;
> |  		bh = bh->b_this_page;
> |  	} while (bh != head);
> |  out:
> | -	if (offset == 0)
> | +	if (!partial_page)
> |  		try_to_release_page(page, 0);
> |  }
> 
> Regards,
> 
> Bob Peterson
> Red Hat File Systems
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
