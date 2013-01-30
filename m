Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 8EDCA6B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:28:49 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 30 Jan 2013 11:28:47 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id ADF5438C8047
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:28:44 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0UGSiZ2294390
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 11:28:44 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0UGShRk009654
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 14:28:44 -0200
Message-ID: <51094A39.8050206@linux.vnet.ibm.com>
Date: Wed, 30 Jan 2013 10:28:41 -0600
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
> 
> - kmap_atomic() returns a void* - there's no need to cast its return value.
> 
> - Remove private MAX(), use the (much better implemented) max().
> 
> - It says "This was one of the major issues with its predecessor
>   (xvmalloc)", but drivers/staging/ramster/xvmalloc.c is still in the tree.
> 
> - USE_PGTABLE_MAPPING should be done via Kconfig.
> 
> - USE_PGTABLE_MAPPING is interesting and the changelog should go into
>   some details.  What are the pros and cons here?  Why do the two
>   options exist?  Can we eliminate one mode or the other?
> 
> - Various functions are obscure and would benefit from explanatory
>   comments.  Good comments explain "why it exists", more than "what it
>   does".
> 
>   These include get_size_class_index, get_fullness_group,
>   insert_zspage, remove_zspage, fix_fullness_group.
> 
>   Also a description of this handle encoding thing - what do these
>   "handles" refer to?  Why is stuff being encoded into them and how?
> 
> - I don't understand how the whole thing works :( If I allocate a
>   16 kbyte object with zs_malloc(), what do I get?  16k of
>   contiguous memory?  How can it do that if
>   USE_PGTABLE_MAPPING=false?  Obviously it can't so it's doing
>   something else.  But what?
> 
> - What does zs_create_pool() do and how do I use it?  It appears
>   to create a pool of all possible object sizes.  But why do we need
>   more than one such pool kernel-wide?
> 
> - I tried to work out the actual value of ZS_SIZE_CLASSES but it
>   made my head spin.
> 
> - We really really don't want to merge zsmalloc!  It would be far
>   better to use an existing allocator (perhaps after modifying it)
>   than to add yet another new one.  The really-good-changelog should
>   be compelling on this point, please.
> 
> See, I (and I assume others) are totally on first base here and we need
> to get through this before we can get onto zswap.  Sorry. 
> drivers/staging is where code goes to be ignored :(

I've noticed :-/

Thank you very much for your review!  I'll work with Nitin and Minchan
to beef up the documentation so that the answers to your questions are
more readily apparent in the code/comments.

I'll also convert the zsmalloc promotion patch back into a full-diff
patch rather than a rename patch so that people can review and comment
inline.

Question, are you saying that you'd like to see the zsmalloc promotion
in a separate patch?

My reason for including the zsmalloc promotion inside the zswap
patches was that it promoted and introduced a user all together.
However, I don't have an issue with breaking it out.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
