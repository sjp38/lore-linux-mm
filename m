Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 0FAF56B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 11:03:40 -0500 (EST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 13 Feb 2013 09:01:44 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 8C7783E4006D
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:01:19 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1DG1Ew9500494
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:01:16 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1DG18fd007042
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 09:01:10 -0700
Message-ID: <511BB8A7.9040305@linux.vnet.ibm.com>
Date: Wed, 13 Feb 2013 10:00:39 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv4 2/7] zsmalloc: promote to lib/
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com> <1359495627-30285-3-git-send-email-sjenning@linux.vnet.ibm.com> <20130129145134.813672cf.akpm@linux-foundation.org>
In-Reply-To: <20130129145134.813672cf.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 01/29/2013 04:51 PM, Andrew Morton wrote:
> On Tue, 29 Jan 2013 15:40:22 -0600
> Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:
> 
>> This patch promotes the slab-based zsmalloc memory allocator
>> from the staging tree to lib/
> 
> Hate to rain on the parade, but...  we haven't reviewed zsmalloc
> yet.  At least, I haven't, and I haven't seen others do so.
> 
> So how's about we forget that zsmalloc was previously in staging and
> send the zsmalloc code out for review?  With a very good changelog
> explaining why it exists, what problems it solves, etc.
> 
> 
> I peeked.
> 
> Don't answer any of the below questions - they are examples of
> concepts which should be accessible to readers of the
> hopefully-forthcoming very-good-changelog.

I know you just said "don't answer", but I wanted to say why certain
points aren't included in the new patchset I'm about to post later today.

> 
> - kmap_atomic() returns a void* - there's no need to cast its return value.

In places where we do pointer arithmetic, we do the cast to avoid
incrementing a void *, which is acceptable for gcc, but not everyone.

> 
> - Remove private MAX(), use the (much better implemented) max().

We can't use max() or max_t() because ZS_SIZE_CLASSES, which uses
ZS_MIN_ALLOC_SIZE, is used to define and array size in struct zs_pool.
So the expression must be able to be fully evaluated by the precompiler.

> 
> - It says "This was one of the major issues with its predecessor
>   (xvmalloc)", but drivers/staging/ramster/xvmalloc.c is still in the tree.

Yes, this was a little mess.  I think you'll find that isn't the case
anymore.  Dan has removed those files from zcache/ramster.

> 
> - USE_PGTABLE_MAPPING should be done via Kconfig.

Minchan did this work and will be included in the next version of the
patchset.

I've added more documentation/comments in the new patchset.  Hopefully,
it will help with understanding the more complicated parts of the code.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
