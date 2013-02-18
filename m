Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id AA07E6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:04:20 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 14:04:19 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id B80EF6E801E
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:04:14 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IJ4G2u271914
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:04:16 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IJ4F8l020157
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 14:04:15 -0500
Message-ID: <51227B29.4020909@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 13:04:09 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 1/8] zsmalloc: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-2-git-send-email-sjenning@linux.vnet.ibm.com> <511EFC5A.3030408@gmail.com>
In-Reply-To: <511EFC5A.3030408@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/15/2013 09:26 PM, Ric Mason wrote:
> On 02/14/2013 02:38 AM, Seth Jennings wrote:
>> =========
>> DO NOT MERGE, FOR REVIEW ONLY
>> This patch introduces zsmalloc as new code, however, it already
>> exists in drivers/staging.  In order to build successfully, you
>> must select EITHER to driver/staging version OR this version.
>> Once zsmalloc is reviewed in this format (and hopefully accepted),
>> I will create a new patchset that properly promotes zsmalloc from
>> staging.
>> =========
>>
>> This patchset introduces a new slab-based memory allocator,
>> zsmalloc, for storing compressed pages.  It is designed for
>> low fragmentation and high allocation success rate on
>> large object, but <= PAGE_SIZE allocations.
>>
>> zsmalloc differs from the kernel slab allocator in two primary
>> ways to achieve these design goals.
>>
>> zsmalloc never requires high order page allocations to back
>> slabs, or "size classes" in zsmalloc terms. Instead it allows
>> multiple single-order pages to be stitched together into a
>> "zspage" which backs the slab.  This allows for higher allocation
>> success rate under memory pressure.
>>
>> Also, zsmalloc allows objects to span page boundaries within the
>> zspage.  This allows for lower fragmentation than could be had
>> with the kernel slab allocator for objects between PAGE_SIZE/2
>> and PAGE_SIZE.  With the kernel slab allocator, if a page compresses
>> to 60% of it original size, the memory savings gained through
>> compression is lost in fragmentation because another object of
>> the same size can't be stored in the leftover space.
> 
> Why you say so? slab/slub allocator both have policies to setup
> suitable order of pages in each slab cache in order to reduce
> fragmentation. Which codes show you slab object can't span page
> boundaries? Could you pointed out to me?

I might need to reword this. What I meant to say is "non-contiguous
page boundaries".

zsmalloc allows an object to span non-contiguous page boundaries
within a zspage.  This obviously can't be done by slab/slub since they
give addresses directly to users and the object data must be
contiguous.  This is one reason why zsmalloc allocations require
mapping to obtain a usable address.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
