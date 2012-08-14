Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id E15286B005D
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 13:39:39 -0400 (EDT)
Received: from /spool/local
	by e4.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 14 Aug 2012 13:39:36 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id A8B0038C8079
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 13:39:33 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7EHdWDK097964
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 13:39:33 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7EHdSlr022922
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 11:39:29 -0600
Message-ID: <502A8D4D.3080101@linux.vnet.ibm.com>
Date: Tue, 14 Aug 2012 12:39:25 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/7] zram/zsmalloc promotion
References: <1344406340-14128-1-git-send-email-minchan@kernel.org> <20120814023530.GA9787@kroah.com> <5029E3EF.9080301@vflare.org>
In-Reply-To: <5029E3EF.9080301@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nitin Gupta <ngupta@vflare.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>

On 08/14/2012 12:36 AM, Nitin Gupta wrote:
> On 08/13/2012 07:35 PM, Greg Kroah-Hartman wrote:
>> On Wed, Aug 08, 2012 at 03:12:13PM +0900, Minchan Kim wrote:
>>> This patchset promotes zram/zsmalloc from staging.
>>> Both are very clean and zram is used by many embedded product
>>> for a long time.
>>>
>>> [1-3] are patches not merged into linux-next yet but needed
>>> it as base for [4-5] which promotes zsmalloc.
>>> Greg, if you merged [1-3] already, skip them.
>>
>> I've applied 1-3 and now 4, but that's it, I can't apply the rest
>> without getting acks from the -mm maintainers, sorry.  Please work with
>> them to get those acks, and then I will be glad to apply the rest (after
>> you resend them of course...)
>>
> 
> On a second thought, I think zsmalloc should stay in drivers/block/zram
> since zram is now the only user of zsmalloc since zcache and ramster are
> moving to another allocator.

The removal of zsmalloc from zcache has not been agreed upon
yet.

Dan _suggested_ removing zsmalloc as the persistent
allocator for zcache in favor of zbud to solve "flaws" in
zcache.  However, zbud has large deficiencies.

A zero-filled 4k page will compress with LZO to 103 bytes.
zbud can only store two compressed pages in each memory pool
page, resulting in 95% fragmentation (i.e. 95% of the memory
pool page goes unused).  While this might not be a typical
case, it is the worst case and absolutely does happen.

zbud's design also effectively limits the useful page
compression to 50%. If pages are compressed beyond that, the
added space savings is lost in memory pool fragmentation.
For example, if two pages compress to 30% of their original
size, those two pages take up 60% of the zbud memory pool
page, and 40% is lost to fragmentation because zbud can't
store anything in the remaining space.

To say it another way, for every two page cache pages that
cleancache stores in zcache, zbud _must_ allocate a memory
pool page, regardless of how well those pages compress.
This reduces the efficiency of the page cache reclaim
mechanism by half.

I have posted some work (zsmalloc shrinker interface, user
registered alloc/free functions for the zsmalloc memory
pool) that begins to make zsmalloc a suitable replacement
for zbud, but that work was put on hold until the path out
of staging was established.

I'm hoping to continue this work once the code is in
mainline.  While zbud has deficiencies, it doesn't prevent
zcache from having value as I have already demonstrated.
However, replacing zsmalloc with zbud would step backward
for the reasons mentioned above.

I do not support the removal of zsmalloc from zcache.  As
such, I think the zsmalloc code should remain independent.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
