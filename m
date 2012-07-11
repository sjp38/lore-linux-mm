Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E0AA46B0062
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:20:20 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 11 Jul 2012 10:19:56 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 43EA838C84D7
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:15:49 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6BEFmdd265554
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:15:48 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6BEFlxX016055
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 10:15:48 -0400
Message-ID: <4FFD8A8F.6030603@linux.vnet.ibm.com>
Date: Wed, 11 Jul 2012 09:15:43 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] zsmalloc: add details to zs_map_object boiler plate
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com> <1341263752-10210-4-git-send-email-sjenning@linux.vnet.ibm.com> <4FFB94FF.8030401@kernel.org> <4FFC478C.4050505@linux.vnet.ibm.com> <4FFD2E65.5080307@kernel.org>
In-Reply-To: <4FFD2E65.5080307@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On 07/11/2012 02:42 AM, Minchan Kim wrote:
> On 07/11/2012 12:17 AM, Seth Jennings wrote:
>> On 07/09/2012 09:35 PM, Minchan Kim wrote:
>>> Maybe we need local_irq_save/restore in zs_[un]map_object path.
>>
>> I'd rather not disable interrupts since that will create
>> unnecessary interrupt latency for all users, even if they
> 
> Agreed.
> Although we guide k[un]map atomic is so fast, it isn't necessary
> to force irq_[enable|disable]. Okay.
> 
>> don't need interrupt protection.  If a particular user uses
>> zs_map_object() in an interrupt path, it will be up to that
>> user to disable interrupts to ensure safety.
> 
> Nope. It shouldn't do that.
> Any user in interrupt context can't assume that there isn't any other user using per-cpu buffer
> right before interrupt happens.
> 
> The concern is that if such bug happens, it's very hard to find a bug.
> So, how about adding this?
> 
> void zs_map_object(...)
> {
> 	BUG_ON(in_interrupt());
> }

I not completely following you, but I think I'm following
enough.  Your point is that the per-cpu buffers are shared
by all zsmalloc users and one user doesn't know if another
user is doing a zs_map_object() in an interrupt path.

However, I think what you are suggesting is to disallow
mapping in interrupt context.  This is a problem for zcache
as it already does mapping in interrupt context, namely for
page decompression in the page fault handler.

What do you think about making the per-cpu buffers local to
each zsmalloc pool? That way each user has their own per-cpu
buffers and don't step on each other's toes.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
