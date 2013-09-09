Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 936F56B0032
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 12:48:58 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 9 Sep 2013 10:48:58 -0600
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 00730C90042
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 12:48:53 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp23032.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r89GmqV439714854
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 16:48:52 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r89GlqiE021824
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 13:47:52 -0300
Date: Mon, 9 Sep 2013 11:47:50 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 4/4] mm/zswap: use GFP_NOIO instead of GFP_KERNEL
Message-ID: <20130909164750.GC4701@variantweb.net>
References: <000601ceaac0$5be39f90$13aadeb0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000601ceaac0$5be39f90$13aadeb0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
> To avoid zswap store and reclaim functions called recursively,
> use GFP_NOIO instead of GFP_KERNEL
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

I agree with Bob to some degree that GFP_NOIO is a broadsword here.
Ideally, we'd like to continue allowing writeback of dirty file pages
and the like.  However, I don't agree that a mutex is the way to do
this.

My first thought was to use the PF_MEMALLOC task flag, but it is already
set for kswapd and any task doing direct reclaim.  A new task flag would
work but I'm not sure how acceptable that would be.

In the meantime, this does do away with the possibility of very deep
recursion between the store and reclaim paths.

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
