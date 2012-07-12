Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 490466B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 21:15:53 -0400 (EDT)
Date: Thu, 12 Jul 2012 10:15:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/4] zsmalloc: add details to zs_map_object boiler plate
Message-ID: <20120712011555.GB5503@bbox>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <4FFB94FF.8030401@kernel.org>
 <4FFC478C.4050505@linux.vnet.ibm.com>
 <4FFD2E65.5080307@kernel.org>
 <4FFD8A8F.6030603@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FFD8A8F.6030603@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Wed, Jul 11, 2012 at 09:15:43AM -0500, Seth Jennings wrote:
> On 07/11/2012 02:42 AM, Minchan Kim wrote:
> > On 07/11/2012 12:17 AM, Seth Jennings wrote:
> >> On 07/09/2012 09:35 PM, Minchan Kim wrote:
> >>> Maybe we need local_irq_save/restore in zs_[un]map_object path.
> >>
> >> I'd rather not disable interrupts since that will create
> >> unnecessary interrupt latency for all users, even if they
> > 
> > Agreed.
> > Although we guide k[un]map atomic is so fast, it isn't necessary
> > to force irq_[enable|disable]. Okay.
> > 
> >> don't need interrupt protection.  If a particular user uses
> >> zs_map_object() in an interrupt path, it will be up to that
> >> user to disable interrupts to ensure safety.
> > 
> > Nope. It shouldn't do that.
> > Any user in interrupt context can't assume that there isn't any other user using per-cpu buffer
> > right before interrupt happens.
> > 
> > The concern is that if such bug happens, it's very hard to find a bug.
> > So, how about adding this?
> > 
> > void zs_map_object(...)
> > {
> > 	BUG_ON(in_interrupt());
> > }
> 
> I not completely following you, but I think I'm following
> enough.  Your point is that the per-cpu buffers are shared
> by all zsmalloc users and one user doesn't know if another
> user is doing a zs_map_object() in an interrupt path.

And vise versa is yes.

> 
> However, I think what you are suggesting is to disallow
> mapping in interrupt context.  This is a problem for zcache
> as it already does mapping in interrupt context, namely for
> page decompression in the page fault handler.

I don't get it.
Page fault handler isn't interrupt context.

> 
> What do you think about making the per-cpu buffers local to
> each zsmalloc pool? That way each user has their own per-cpu
> buffers and don't step on each other's toes.

Maybe, It could be a solution if you really need it in interrupt context.
But the concern is it could hurt zsmalloc's goal which is memory
space efficiency if your system has lots of CPUs.

> 
> Thanks,
> Seth
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
