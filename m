Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id EE0206B0023
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 21:38:23 -0500 (EST)
Date: Fri, 1 Feb 2013 11:38:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCHv4 3/7] zswap: add to mm/
Message-ID: <20130201023821.GB6262@blaptop>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359495627-30285-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130131070716.GF23548@blaptop>
 <510AC0C6.4020705@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <510AC0C6.4020705@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Thu, Jan 31, 2013 at 01:06:46PM -0600, Seth Jennings wrote:
> On 01/31/2013 01:07 AM, Minchan Kim wrote:
> > On Tue, Jan 29, 2013 at 03:40:23PM -0600, Seth Jennings wrote:
> >> zswap is a thin compression backend for frontswap. It receives
> >> pages from frontswap and attempts to store them in a compressed
> >> memory pool, resulting in an effective partial memory reclaim and
> >> dramatically reduced swap device I/O.
> >>
> >> Additionally, in most cases, pages can be retrieved from this
> >> compressed store much more quickly than reading from tradition
> >> swap devices resulting in faster performance for many workloads.
> >>
> >> This patch adds the zswap driver to mm/
> >>
> >> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> >> ---
> >>  mm/Kconfig  |  15 ++
> >>  mm/Makefile |   1 +
> >>  mm/zswap.c  | 656 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >>  3 files changed, 672 insertions(+)
> >>  create mode 100644 mm/zswap.c
> >>
> >> diff --git a/mm/Kconfig b/mm/Kconfig
> >> index 278e3ab..14b9acb 100644
> >> --- a/mm/Kconfig
> >> +++ b/mm/Kconfig
> >> @@ -446,3 +446,18 @@ config FRONTSWAP
> >>  	  and swap data is stored as normal on the matching swap device.
> >>  
> >>  	  If unsure, say Y to enable frontswap.
> >> +
> >> +config ZSWAP
> >> +	bool "In-kernel swap page compression"
> >> +	depends on FRONTSWAP && CRYPTO
> >> +	select CRYPTO_LZO
> >> +	select ZSMALLOC
> > 
> > Again, I'm asking why zswap should have a dependent on CRPYTO?
> > Couldn't we support it as a option? I'd like to use zswap without CRYPTO
> > like zram.
> 
> The reason we need CRYPTO is that zswap uses it to support a pluggable
> compression model.  zswap can use any compressor that has a crypto API
> driver.  zswap has _symbol dependencies_ on CRYPTO.  If it isn't
> selected, the build breaks.

I think we can factor out compressoin part and remove dependency
at compile time by Kconfig. No? Of course, if we disable CRYPTO in Kconfig,
we lost pluggable model but not a problem for embedded system.
Anyway, If it's a burden for you at a moment, I'm not going to insist on it.
Will do it for myself.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
