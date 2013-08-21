Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 472DE6B0095
	for <linux-mm@kvack.org>; Wed, 21 Aug 2013 06:27:17 -0400 (EDT)
Message-ID: <521495E5.7010109@oracle.com>
Date: Wed, 21 Aug 2013 18:26:45 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 0/5] zram/zsmalloc promotion
References: <1377065791-2959-1-git-send-email-minchan@kernel.org> <52148730.4000709@oracle.com>
In-Reply-To: <52148730.4000709@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>, lliubbo@gmail.com

On 08/21/2013 05:24 PM, Bob Liu wrote:
> Hi Minchan,
> 
> On 08/21/2013 02:16 PM, Minchan Kim wrote:
>> It's 7th trial of zram/zsmalloc promotion.
>> I rewrote cover-letter totally based on previous discussion.
>>
>> The main reason to prevent zram promotion was no review of
>> zsmalloc part while Jens, block maintainer, already acked
>> zram part.
>>
>> At that time, zsmalloc was used for zram, zcache and zswap so
>> everybody wanted to make it general and at last, Mel reviewed it
>> when zswap was submitted to merge mainline a few month ago.
>> Most of review was related to zswap writeback mechanism which
>> can pageout compressed page in memory into real swap storage
>> in runtime and the conclusion was that zsmalloc isn't good for
>> zswap writeback so zswap borrowed zbud allocator from zcache to
>> replace zsmalloc. The zbud is bad for memory compression ratio(2)
>> but it's very predictable behavior because we can expect a zpage
>> includes just two pages as maximum. Other reviews were not major. 
>> http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
>>
>> Zcache doesn't use zsmalloc either so zsmalloc's user is only
>> zram now so this patchset moves it into zsmalloc directory.
>> Recently, Bob tried to move zsmalloc under mm directory to unify
>> zram and zswap with adding pseudo block device in zswap(It's
>> very weired to me) but he was simple ignoring zram's block device
>> (a.k.a zram-blk) feature and considered only swap usecase of zram,
>> in turn, it lose zram's good concept.
>>
> 
> Yes, I didn't notice the feature that zram can be used as a normal block
> device.
> 
> 
>> Mel raised an another issue in v6, "maintainance headache".
>> He claimed zswap and zram has a similar goal that is to compresss
>> swap pages so if we promote zram, maintainance headache happens
>> sometime by diverging implementaion between zswap and zram
>> so that he want to unify zram and zswap. For it, he want zswap
>> to implement pseudo block device like Bob did to emulate zram so
>> zswap can have an advantage of writeback as well as zram's benefit.
> 
> If consider zram as a swap device only, I still think it's better to add
> a pseudo block device to zswap and just disable the writeback of zswap.
> 
> But I have no idea of zram's block device feature.
> 

BTW: I think the original/main purpose that zram was introduced is for
swapping. Is there any real users using zram as a normal block device
instead of swap?
For normal usage, maybe we can extend ramdisk with compression feature.

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
