Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA22249
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 14:49:36 -0700 (PDT)
Message-ID: <3DB4766F.D3AB15B9@digeo.com>
Date: Mon, 21 Oct 2002 14:49:35 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
References: <3DB472B6.BC5B8924@digeo.com> <309670000.1035236015@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> >> Nope, kept OOMing and killing everything .
> >
> > Something broke.
> 
> Even I worked that out ;-)

Well I'm feeling especially helpful today.

> > Blockdevices only use ZONE_NORMAL for their pagecache.  That cat will
> > selectively put pressure on the normal zone (and DMA zone, of course).
> 
> Ah, I recall that now. That's fundamentally screwed.

When filesystems want to access metadata, they will typically read
a block into a buffer_head and access the memory directly.

 mnm:/usr/src/25> grep -rI b_data fs | wc -l
    844

That's a lot of kmaps need adding.

So we constrain blockdev->bd_inode->i_mapping->gfp_mask so that
the blockdev's pagecache memory is always in the direct-addressed
region.

It would be possible to fix on a per-fs basis - teach a filesystem
to kmap bh->b_page appropriately and then set __GFP_HIGHMEM in the
blockdev's gfp_mask.

But it doesn't seem to cause a lot of trouble in practice.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
