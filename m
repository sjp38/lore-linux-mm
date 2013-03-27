Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id C38E96B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 13:20:35 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 27 Mar 2013 11:20:34 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 5853E1FF004C
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 11:14:34 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2RHJNBe096234
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 11:19:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2RHJDxr000522
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 11:19:13 -0600
Message-ID: <51532A0F.3010402@linux.vnet.ibm.com>
Date: Wed, 27 Mar 2013 12:19:11 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: remove swapcache page early
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1364350932-12853-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>

On 03/26/2013 09:22 PM, Minchan Kim wrote:
> Swap subsystem does lazy swap slot free with expecting the page
> would be swapped out again so we can't avoid unnecessary write.
> 
> But the problem in in-memory swap is that it consumes memory space
> until vm_swap_full(ie, used half of all of swap device) condition
> meet. It could be bad if we use multiple swap device, small in-memory swap
> and big storage swap or in-memory swap alone.
> 
> This patch changes vm_swap_full logic slightly so it could free
> swap slot early if the backed device is really fast.

Great idea!

> For it, I used SWP_SOLIDSTATE but It might be controversial.

The comment for SWP_SOLIDSTATE is that "blkdev seeks are cheap". Just
because seeks are cheap doesn't mean the read itself is also cheap.
For example, QUEUE_FLAG_NONROT is set for mmc devices, but some of
them can be pretty slow.

> So let's add Ccing Shaohua and Hugh.
> If it's a problem for SSD, I'd like to create new type SWP_INMEMORY
> or something for z* family.

Afaict, setting SWP_SOLIDSTATE depends on characteristics of the
underlying block device (i.e. blk_queue_nonrot()).  zram is a block
device but zcache and zswap are not.

Any idea by what criteria SWP_INMEMORY would be set?

Also, frontswap backends (zcache and zswap) are a caching layer on top
of the real swap device, which might actually be rotating media.  So
you have the issue of to different characteristics, in-memory caching
on top of rotation media, present in a single swap device.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
