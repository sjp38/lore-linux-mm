Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DD9DF6B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 17:52:28 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 17:52:27 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id E042A6E801D
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 17:52:22 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IMqMmr269992
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 17:52:22 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IMsmsp015183
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 15:54:49 -0700
Message-ID: <5122B0A0.3090401@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 16:52:16 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 4/8] zswap: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-5-git-send-email-sjenning@linux.vnet.ibm.com> <511F0536.5030802@gmail.com> <51227FDA.7040000@linux.vnet.ibm.com> <0fb2af92-575f-4f5d-a115-829a3cf035e5@default> <5122918A.8090307@linux.vnet.ibm.com> <2c81050d-72b0-4a93-aecb-900171a019d0@default>
In-Reply-To: <2c81050d-72b0-4a93-aecb-900171a019d0@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Ric Mason <ric.masonn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/18/2013 03:59 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCHv5 4/8] zswap: add to mm/
>>
>> On 02/18/2013 01:55 PM, Dan Magenheimer wrote:
>>>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>>>> Subject: Re: [PATCHv5 4/8] zswap: add to mm/
>>>>
>>>> On 02/15/2013 10:04 PM, Ric Mason wrote:
>>>>>> + * certain event is occurring.
>>>>>> +*/
>>>>>> +static u64 zswap_pool_limit_hit;
>>>>>> +static u64 zswap_reject_compress_poor;
>>>>>> +static u64 zswap_reject_zsmalloc_fail;
>>>>>> +static u64 zswap_reject_kmemcache_fail;
>>>>>> +static u64 zswap_duplicate_entry;
>>>>>> +
>>>>>> +/*********************************
>>>>>> +* tunables
>>>>>> +**********************************/
>>>>>> +/* Enable/disable zswap (disabled by default, fixed at boot for
>>>>>> now) */
>>>>>> +static bool zswap_enabled;
>>>>>> +module_param_named(enabled, zswap_enabled, bool, 0);
>>>>>
>>>>> please document in Documentation/kernel-parameters.txt.
>>>>
>>>> Will do.
>>>
>>> Is that a good idea?  Konrad's frontswap/cleancache patches
>>> to fix frontswap/cleancache initialization so that backends
>>> can be built/loaded as modules may be merged for 3.9.
>>> AFAIK, module parameters are not included in kernel-parameters.txt.
>>
>> This is true.  However, the frontswap/cleancache init stuff isn't the
>> only reason zswap is built-in only.  The writeback code depends on
>> non-exported kernel symbols:
>>
>> swapcache_free
>> __swap_writepage
>> __add_to_swap_cache
>> swapcache_prepare
>> swapper_space
>> end_swap_bio_write
>>
>> I know a fix is as trivial as exporting them, but I didn't want to
>> take on that debate right now.
> 
> Hmmm... I wonder if exporting these might be the best solution
> as it (unnecessarily?) exposes some swap subsystem internals.
> I wonder if a small change to read_swap_cache_async might
> be more acceptable.

Yes, I'm not saying that I'm for exporting them; just that that would
be an easy and probably improper fix.

As I recall, the only thing I really needed to change in my adaption
of read_swap_cache_async(), zswap_get_swap_cache_page() in zswap, was
the assumption built in that it is swapping in a page on behalf of a
userspace program with the vma argument and alloc_page_vma().  Maybe
if we change it to just use alloc_page when vma is NULL, that could
work.  In a non-NUMA kernel alloc_page_vma() equals alloc_page() so I
wouldn't expect weird things doing that.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
