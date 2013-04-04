Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id E11776B0027
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 18:30:41 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 18:30:40 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id BEB6DC90025
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 18:30:38 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r34MUc31305592
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 18:30:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r34MUbOC005806
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 18:30:38 -0400
Message-ID: <515DFF08.3060005@linux.vnet.ibm.com>
Date: Thu, 04 Apr 2013 17:30:32 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv8 5/8] mm: break up swap_writepage() for frontswap backends
References: <1365113446-25647-1-git-send-email-sjenning@linux.vnet.ibm.com> <1365113446-25647-6-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1365113446-25647-6-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Bob Liu <lliubbo@gmail.com>

On 04/04/2013 05:10 PM, Seth Jennings wrote:
> swap_writepage() is currently where frontswap hooks into the swap
> write path to capture pages with the frontswap_store() function.
> However, if a frontswap backend wants to "resume" the writeback of
> a page to the swap device, it can't call swap_writepage() as
> the page will simply reenter the backend.
> 
> This patch separates swap_writepage() into a top and bottom half, the
> bottom half named __swap_writepage() to allow a frontswap backend,
> like zswap, to resume writeback beyond the frontswap_store() hook.
> 
> __add_to_swap_cache() is also made non-static so that the page for
> which writeback is to be resumed can be added to the swap cache.
> 
> Acked-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Adding Cc Bob Liu.

I just remembered that Bob had done a repost of the 5 and 6 patches,
outside the zswap thread,  with a small change to avoid a checkpatch
warning.  I didn't pull that change into my version, but I should have.

It doesn't make a functional difference, so this patch can still go
forward and the checkpatch warning can be cleaned up in a subsequent
patch.  If another revision of the patchset is needed for other
reasons, I'll pull this change into the next version.

I think Dan and Bob would be ok with their tags being applied to 5 and 6:

Acked-by: Bob Liu <bob.liu@oracle.com>
Reviewed-by: Dan Magenheimer <dan.magenheimer@oracle.com>

That ok?

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
