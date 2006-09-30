Date: Sat, 30 Sep 2006 13:08:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] Get rid of zone_table V2
Message-Id: <20060930130811.2a7c0009.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
	<20060924030643.e57f700c.akpm@osdl.org>
	<20060927021934.9461b867.akpm@osdl.org>
	<451A6034.20305@shadowen.org>
	<Pine.LNX.4.64.0609301135430.4012@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 30 Sep 2006 11:47:48 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> There is still a problem after Andy's patch in connection with Optional 
> ZONE DMA that I pointed out earlier. If we only have a single zone then 
> ZONEID_PGSHIFT == 0. This is fine for the non NUMA case in which we have 
> only a single zone and ZONEID_MASK == 0 too. page_zone_id() will always be 
> 0.
> 
> In the NUMA case we still have one zone per node. Thus we need to have a 
> correct ZONEID_PGSHIFT in order to isolate the node number from page 
> flags. Right now we take NODES_SHIFT bits starting from 0!
> 
> I am not exactly sure how to fix that the right way given the complex
> nested macros. Andy may know.
> 
> The following patch checks for that condition. We can only allow 
> ZONEID_PGSHIFT to be zero if the ZONEID_MASK is also zero. (We cannot 
> check that with an #if because ZONEID_SHIFT contains a "sizeof(...)" 
> element)
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.18-mm2/include/linux/mm.h
> ===================================================================
> --- linux-2.6.18-mm2.orig/include/linux/mm.h	2006-09-30 13:22:27.732989275 -0500
> +++ linux-2.6.18-mm2/include/linux/mm.h	2006-09-30 13:23:06.604463587 -0500
> @@ -447,6 +447,7 @@ static inline enum zone_type page_zonenu
>   */
>  static inline int page_zone_id(struct page *page)
>  {
> +	BUG_ON(ZONEID_PGSHIFT == 0 && ZONEID_MASK);
>  	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
>  }
>  

BUILD_BUG_ON()?

What patch is this patch patching?  get-rid-of-zone_table.patch or one of
the ZONE_DMA-optionality ones?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
