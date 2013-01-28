Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 72B276B0007
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:38:48 -0500 (EST)
Date: Tue, 29 Jan 2013 08:38:46 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 1/4] staging: zsmalloc: add gfp flags to zs_create_pool
Message-ID: <20130128233846.GB4752@blaptop>
References: <1359135978-15119-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1359135978-15119-2-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130128033944.GB3321@blaptop>
 <5106AEE8.4060003@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5106AEE8.4060003@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Jan 28, 2013 at 11:01:28AM -0600, Seth Jennings wrote:
> On 01/27/2013 09:39 PM, Minchan Kim wrote:
> > Hi Seth,
> > 
> > On Fri, Jan 25, 2013 at 11:46:15AM -0600, Seth Jennings wrote:
> >> zs_create_pool() currently takes a gfp flags argument
> >> that is used when growing the memory pool.  However
> >> it is not used in allocating the metadata for the pool
> >> itself.  That is currently hardcoded to GFP_KERNEL.
> >>
> >> zswap calls zs_create_pool() at swapon time which is done
> >> in atomic context, resulting in a "might sleep" warning.
> >>
> >> This patch changes the meaning of the flags argument in
> >> zs_create_pool() to mean the flags for the metadata allocation,
> >> and adds a flags argument to zs_malloc that will be used for
> >> memory pool growth if required.
> > 
> > As I mentioned, I'm not strongly against with this patch but it
> > should be last resort in case of not being able to address
> > frontswap's init routine's dependency with swap_lock.
> > 
> > I sent a patch and am waiting reply of Konrand or Dan.
> > If we can fix frontswap, it would be better rather than
> > changing zsmalloc.
> 
> I agree that moving the call to frontswap_init() out of the swap_lock
> would be a good thing.  However, it doesn't mean that we still
> shouldn't allow the users to control the gfp mask for the allocation
> done by zs_create_pool(). While moving the frontswap_init() outside
> the lock removes the _need_ for this patch, I think that is it good
> API design to allow the user to specify the gfp mask.

I agree but we can do it when we have needs.
If we can remove swap_lock dependency of frontswap, your needs would go away
so we could add gfp argument next time if someone give us their needs.

> 
> Seth
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
