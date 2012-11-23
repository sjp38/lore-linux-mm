Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 567B46B005D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 21:10:33 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id r4so7623774iaj.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 18:10:32 -0800 (PST)
Message-ID: <50AEDB12.6090300@gmail.com>
Date: Fri, 23 Nov 2012 10:10:26 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: Problem in Page Cache Replacement
References: <20121120182500.GH1408@quack.suse.cz> <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com> <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com> <50AC9220.70202@gmail.com> <20121121090204.GA9064@localhost> <50ACA209.9000101@gmail.com> <1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com> <50ACA634.5000007@gmail.com> <CAJOrxZBpefqtkXr+XTxEZ6qy-6SCwQJ11makD=Lg_M4itY5Ang@mail.gmail.com> <20121122154107.GB11736@localhost> <20121122155318.GA12636@localhost>
In-Reply-To: <20121122155318.GA12636@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: =?UTF-8?B?TWV0aW4gRMO2xZ9sw7w=?= <metindoslu@gmail.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 11/22/2012 11:53 PM, Fengguang Wu wrote:
> On Thu, Nov 22, 2012 at 11:41:07PM +0800, Fengguang Wu wrote:
>> On Wed, Nov 21, 2012 at 12:07:22PM +0200, Metin DA?A?lA 1/4  wrote:
>>> On Wed, Nov 21, 2012 at 12:00 PM, Jaegeuk Hanse <jaegeuk.hanse@gmail.com> wrote:
>>>> On 11/21/2012 05:58 PM, metin d wrote:
>>>>
>>>> Hi Fengguang,
>>>>
>>>> I run tests and attached the results. The line below I guess shows the data-1 page caches.
>>>>
>>>> 0x000000080000006c       6584051    25718  __RU_lA___________________P________    referenced,uptodate,lru,active,private
>>>>
>>>>
>>>> I thinks this is just one state of page cache pages.
>>> But why these page caches are in this state as opposed to other page
>>> caches. From the results I conclude that:
>>>
>>> data-1 pages are in state : referenced,uptodate,lru,active,private
>> I wonder if it's this code that stops data-1 pages from being
>> reclaimed:
>>
>> shrink_page_list():
>>
>>                  if (page_has_private(page)) {
>>                          if (!try_to_release_page(page, sc->gfp_mask))
>>                                  goto activate_locked;
>>
>> What's the filesystem used?
> Ah it's more likely caused by this logic:
>
>          if (is_active_lru(lru)) {
>                  if (inactive_list_is_low(mz, file))
>                          shrink_active_list(nr_to_scan, mz, sc, priority, file);
>
> The active file list won't be scanned at all if it's smaller than the
> active list. In this case, it's inactive=33586MB > active=25719MB. So
> the data-1 pages in the active list will never be scanned and reclaimed.

Hi Fengguang,

It seems that most of data-1 file pages are in active lru cache and most 
of data-2 file pages are in inactive lru cache. As Johannes mentioned, 
if inter-reference distance is bigger than half of memory, the pages 
will not be actived. How you intend to resolve this issue? Is Johannes's 
inactive list threshing idea  available?

Regards,
Jaegeuk

>
>>> data-2 pages are in state : referenced,uptodate,lru,mappedtodisk
>> Thanks,
>> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
