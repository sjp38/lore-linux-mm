Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id F12B66B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 19:35:24 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id uz6so603159obc.34
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:35:24 -0800 (PST)
Message-ID: <512FF7C6.4090109@gmail.com>
Date: Fri, 01 Mar 2013 08:35:18 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie
 to a config option
References: <1360175261-13287-1-git-send-email-dan.magenheimer@oracle.com> <5126F06A.8010106@gmail.com> <f6930e42-24d8-447c-9443-b4d3f5aa1418@default>
In-Reply-To: <f6930e42-24d8-447c-9443-b4d3f5aa1418@default>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, gregkh@linuxfoundation.org, linux-mm@kvack.org, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, sjenning@linux.vnet.ibm.com, minchan@kernel.org

On 03/01/2013 06:29 AM, Dan Magenheimer wrote:
>> From: Ric Mason [mailto:ric.masonn@gmail.com]
>> Subject: Re: [PATCH] staging/zcache: Fix/improve zcache writeback code, tie to a config option
>>
>> On 02/07/2013 02:27 AM, Dan Magenheimer wrote:
>>> It was observed by Andrea Arcangeli in 2011 that zcache can get "full"
>>> and there must be some way for compressed swap pages to be (uncompressed
>>> and then) sent through to the backing swap disk.  A prototype of this
>>> functionality, called "unuse", was added in 2012 as part of a major update
>>> to zcache (aka "zcache2"), but was left unfinished due to the unfortunate
>>> temporary fork of zcache.
>>>
>>> This earlier version of the code had an unresolved memory leak
>>> and was anyway dependent on not-yet-upstream frontswap and mm changes.
>>> The code was meanwhile adapted by Seth Jennings for similar
>>> functionality in zswap (which he calls "flush").  Seth also made some
>>> clever simplifications which are herein ported back to zcache.  As a
>>> result of those simplifications, the frontswap changes are no longer
>>> necessary, but a slightly different (and simpler) set of mm changes are
>>> still required [1].  The memory leak is also fixed.
>>>
>>> Due to feedback from akpm in a zswap thread, this functionality in zcache
>>> has now been renamed from "unuse" to "writeback".
>>>
>>> Although this zcache writeback code now works, there are open questions
>>> as how best to handle the policy that drives it.  As a result, this
>>> patch also ties writeback to a new config option.  And, since the
>>> code still depends on not-yet-upstreamed mm patches, to avoid build
>>> problems, the config option added by this patch temporarily depends
>>> on "BROKEN"; this config dependency can be removed in trees that
>>> contain the necessary mm patches.
>>>
>>> [1] https://lkml.org/lkml/2013/1/29/540/ https://lkml.org/lkml/2013/1/29/539/
>> shrink_zcache_memory:
>>
>> while(nr_evict-- > 0) {
>>       page = zcache_evict_eph_pageframe();
>>       if (page == NULL)
>>           break;
>>       zcache_free_page(page);
>> }
>>
>> zcache_evict_eph_pageframe
>> ->zbud_evict_pageframe_lru
>>       ->zbud_evict_tmem
>>           ->tmem_flush_page
>>               ->zcache_pampd_free
>>                   ->zcache_free_page  <- zbudpage has already been free here
>>
>> If the zcache_free_page called in shrink_zcache_memory can be treated as
>> a double free?
> Thanks for the code review and sorry for the delay...
>
> zcache_pampd_free() only calls zcache_free_page() if page is non-NULL,
> but in this code path I think when zcache_pampd_free() calls
> zbud_free_and_delist(), that function determines that the zbudpage
> is dying and returns NULL.
>
> So unless I am misunderstanding (or misreading the code), there
> is no double free.

Oh, I see. Thanks for your response. :)

>
> Thanks,
> Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
