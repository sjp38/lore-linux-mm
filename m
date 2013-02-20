Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id DFFF36B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 21:04:04 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id xb4so2576378pbc.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2013 18:04:04 -0800 (PST)
Message-ID: <51242F0D.4040201@gmail.com>
Date: Wed, 20 Feb 2013 10:03:57 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: Questin about swap_slot free and invalidate page
References: <20130131051140.GB23548@blaptop> <alpine.LNX.2.00.1302031732520.4050@eggly.anvils> <20130204024950.GD2688@blaptop> <d6fc41b7-8448-40be-84c3-c24d0833bd85@default> <51236C11.1010208@gmail.com> <1f089254-3abe-4c63-a72a-c9e564ae7d0d@default>
In-Reply-To: <1f089254-3abe-4c63-a72a-c9e564ae7d0d@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 02/19/2013 11:27 PM, Dan Magenheimer wrote:
>> From: Ric Mason [mailto:ric.masonn@gmail.com]
>> Sent: Tuesday, February 19, 2013 5:12 AM
>> To: Dan Magenheimer
>> Cc: Minchan Kim; Hugh Dickins; Nitin Gupta; Seth Jennings; Konrad Rzeszutek Wilk; linux-mm@kvack.org;
>> linux-kernel@vger.kernel.org; Andrew Morton
>> Subject: Re: Questin about swap_slot free and invalidate page
>>
>> On 02/05/2013 05:28 AM, Dan Magenheimer wrote:
>>>> From: Minchan Kim [mailto:minchan@kernel.org]
>>>> Sent: Sunday, February 03, 2013 7:50 PM
>>>> To: Hugh Dickins
>>>> Cc: Nitin Gupta; Dan Magenheimer; Seth Jennings; Konrad Rzeszutek Wilk; linux-mm@kvack.org; linux-
>>>> kernel@vger.kernel.org; Andrew Morton
>>>> Subject: Re: Questin about swap_slot free and invalidate page
>>>>
>>>> Hi Hugh,
>>>>
>>>> On Sun, Feb 03, 2013 at 05:51:14PM -0800, Hugh Dickins wrote:
>>>>> On Thu, 31 Jan 2013, Minchan Kim wrote:
>>>>>
>>>>>> When I reviewed zswap, I was curious about frontswap_store.
>>>>>> It said following as.
>>>>>>
>>>>>>    * If frontswap already contains a page with matching swaptype and
>>>>>>    * offset, the frontswap implementation may either overwrite the data and
>>>>>>    * return success or invalidate the page from frontswap and return failure.
>>>>>>
>>>>>> It didn't say why it happens. we already have __frontswap_invalidate_page
>>>>>> and call it whenever swap_slot frees. If we don't free swap slot,
>>>>>> scan_swap_map can't find the slot for swap out so I thought overwriting of
>>>>>> data shouldn't happen in frontswap.
>>>>>>
>>>> I am waiting Dan's reply(He will come in this week) and then, judge what's
>>>> the best.
>>> Hugh is right that handling the possibility of duplicates is
>>> part of the tmem ABI.  If there is any possibility of duplicates,
>>> the ABI defines how a backend must handle them to avoid data
>>> coherency issues.
>>>
>>> The kernel implements an in-kernel API which implements the tmem
>>> ABI.  If the frontend and backend can always agree that duplicate
>> Which ABI in zcache implement that?
> https://oss.oracle.com/projects/tmem/dist/documentation/api/tmemspec-v001.pdf
>
> The in-kernel APIs are frontswap and cleancache.  For more information about
> tmem, see http://lwn.net/Articles/454795/

But you mentioned that you have in-kernel API which can handle 
duplicate.  Do you mean zcache_cleancache/frontswap_put_page? I think 
they just overwrite instead of optional flush the page on the 
second(duplicate) put as mentioned in your tmemspec.

>   
>>> are never possible, I agree that the backend could avoid that
>>> special case.  However, duplicates occur rarely enough and the
>>> consequences (data loss) are bad enough that I think the case
>>> should still be checked, at least with a BUG_ON.  I also wonder
>>> if it is worth it to make changes to the core swap subsystem
>>> to avoid code to implement a zswap corner case.
>>>
>>> Remember that zswap is an oversimplified special case of tmem
>>> that handles only one frontend (Linux frontswap) and one backend
>>> (zswap).  Tmem goes well beyond that and already supports other
>>> more general backends including Xen and ramster, and could also
>>> support other frontends such as a BSD or Solaris equivalent
>>> of frontswap, for example with a Linux ramster/zcache backend.
>>> I'm not sure how wise it is to tear out generic code and replace
>>> it with simplistic code unless there is absolutely no chance that
>>> the generic code will be necessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
