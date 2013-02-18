Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id A14926B0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 15:40:05 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 18 Feb 2013 15:40:03 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4561638C801A
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 15:39:42 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1IKdf5U306770
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 15:39:41 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1IKdeXk030405
	for <linux-mm@kvack.org>; Mon, 18 Feb 2013 15:39:41 -0500
Message-ID: <5122918A.8090307@linux.vnet.ibm.com>
Date: Mon, 18 Feb 2013 14:39:38 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCHv5 4/8] zswap: add to mm/
References: <1360780731-11708-1-git-send-email-sjenning@linux.vnet.ibm.com> <1360780731-11708-5-git-send-email-sjenning@linux.vnet.ibm.com> <511F0536.5030802@gmail.com> <51227FDA.7040000@linux.vnet.ibm.com> <0fb2af92-575f-4f5d-a115-829a3cf035e5@default>
In-Reply-To: <0fb2af92-575f-4f5d-a115-829a3cf035e5@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Ric Mason <ric.masonn@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 02/18/2013 01:55 PM, Dan Magenheimer wrote:
>> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
>> Subject: Re: [PATCHv5 4/8] zswap: add to mm/
>>
>> On 02/15/2013 10:04 PM, Ric Mason wrote:
>>> On 02/14/2013 02:38 AM, Seth Jennings wrote:
>> <snip>
>>>> + * The statistics below are not protected from concurrent access for
>>>> + * performance reasons so they may not be a 100% accurate.  However,
>>>> + * the do provide useful information on roughly how many times a
>>>
>>> s/the/they
>>
>> Ah yes, thanks :)
>>
>>>
>>>> + * certain event is occurring.
>>>> +*/
>>>> +static u64 zswap_pool_limit_hit;
>>>> +static u64 zswap_reject_compress_poor;
>>>> +static u64 zswap_reject_zsmalloc_fail;
>>>> +static u64 zswap_reject_kmemcache_fail;
>>>> +static u64 zswap_duplicate_entry;
>>>> +
>>>> +/*********************************
>>>> +* tunables
>>>> +**********************************/
>>>> +/* Enable/disable zswap (disabled by default, fixed at boot for
>>>> now) */
>>>> +static bool zswap_enabled;
>>>> +module_param_named(enabled, zswap_enabled, bool, 0);
>>>
>>> please document in Documentation/kernel-parameters.txt.
>>
>> Will do.
> 
> Is that a good idea?  Konrad's frontswap/cleancache patches
> to fix frontswap/cleancache initialization so that backends
> can be built/loaded as modules may be merged for 3.9.
> AFAIK, module parameters are not included in kernel-parameters.txt.

This is true.  However, the frontswap/cleancache init stuff isn't the
only reason zswap is built-in only.  The writeback code depends on
non-exported kernel symbols:

swapcache_free
__swap_writepage
__add_to_swap_cache
swapcache_prepare
swapper_space
end_swap_bio_write

I know a fix is as trivial as exporting them, but I didn't want to
take on that debate right now.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
