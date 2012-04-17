Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 27FCB6B004D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 22:18:55 -0400 (EDT)
Message-ID: <4F8CD310.4010609@kernel.org>
Date: Tue, 17 Apr 2012 11:18:56 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: swap on eMMC and other flash
References: <201203301744.16762.arnd@arndb.de> <201204111557.14153.arnd@arndb.de> <CAKL-ytsXbe4=u94PjqvhZo=ZLiChQ0FmZC84GNrFHa0N1mDjFw@mail.gmail.com> <201204161859.32436.arnd@arndb.de> <CAKL-ytvC3dw6p=R1G3GOCst_6B=uOqRK2kWOH9jso_=bgtNOXA@mail.gmail.com>
In-Reply-To: <CAKL-ytvC3dw6p=R1G3GOCst_6B=uOqRK2kWOH9jso_=bgtNOXA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephan Uphoff <ups@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linaro-kernel@lists.linaro.org, android-kernel@googlegroups.com, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>

On 04/17/2012 06:12 AM, Stephan Uphoff wrote:
> Hi Arnd,
>
> On Mon, Apr 16, 2012 at 12:59 PM, Arnd Bergmann<arnd@arndb.de>  wrote:
>> On Monday 16 April 2012, Stephan Uphoff wrote:
>>> opportunity to plant a few ideas.
>>>
>>> In contrast to rotational disks read/write operation overhead and
>>> costs are not symmetric.
>>> While random reads are much faster on flash - the number of write
>>> operations is limited by wearout and garbage collection overhead.
>>> To further improve swapping on eMMC or similar flash media I believe
>>> that the following issues need to be addressed:
>>>
>>> 1) Limit average write bandwidth to eMMC to a configurable level to
>>> guarantee a minimum device lifetime
>>> 2) Aim for a low write amplification factor to maximize useable write bandwidth
>>> 3) Strongly favor read over write operations
>>>
>>> Lowering write amplification (2) has been discussed in this email
>>> thread - and the only observation I would like to add is that
>>> over-provisioning the internal swap space compared to the exported
>>> swap space significantly can guarantee a lower write amplification
>>> factor with the indirection and GC techniques discussed.
>>
>> Yes, good point.
>>
>>> I believe the swap functionality is currently optimized for storage
>>> media where read and write costs are nearly identical.
>>> As this is not the case on flash I propose splitting the anonymous
>>> inactive queue (at least conceptually) - keeping clean anonymous pages
>>> with swap slots on a separate queue as the cost of swapping them
>>> out/in is only an inexpensive read operation. A variable similar to
>>> swapiness (or a more dynamic algorithmn) could determine the
>>> preference for swapping out clean pages or dirty pages. ( A similar
>>> argument could be made for splitting up the file inactive queue )
>>
>> I'm not sure I understand yet how this would be different from swappiness.
>
> As I see it swappiness determines the ratio for paging out file backed
> as compared to anonymous, swap backed pages.
> I would like to further be able to set the ratio for throwing away
> clean anonymous pages with swap slots ( that are easy to read back in)
> as compared to writing out dirty anonymous pages to swap.

We can apply the rule in file-lru list too and we already have 
ISOLATE_CLEAN mode to select victim pages in LRU list so it should work.

For selecting clean anon pages with swap slot, we need more looking.
Recent, Dan had a question about it and Hugh answered it.
Look at the http://marc.info/?l=linux-mm&m=133462346928786&w=2

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
