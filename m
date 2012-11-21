Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 97E2B6B00B4
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 09:52:59 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1122433pad.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 06:52:58 -0800 (PST)
Message-ID: <50ACEAAD.60306@gmail.com>
Date: Wed, 21 Nov 2012 22:52:29 +0800
From: Jiang Liu <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFT PATCH v1 4/5] mm: provide more accurate estimation of pages
 occupied by memmap
References: <20121115112454.e582a033.akpm@linux-foundation.org> <1353254850-27336-1-git-send-email-jiang.liu@huawei.com> <1353254850-27336-5-git-send-email-jiang.liu@huawei.com> <20121119154240.91efcc53.akpm@linux-foundation.org> <50AB9F4A.5050500@gmail.com> <20121120111942.c9596d3f.akpm@linux-foundation.org>
In-Reply-To: <20121120111942.c9596d3f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wen Congyang <wency@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Jiang Liu <jiang.liu@huawei.com>, Maciej Rutecki <maciej.rutecki@gmail.com>, Chris Clayton <chris2553@googlemail.com>, "Rafael J . Wysocki" <rjw@sisk.pl>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Jianguo Wu <wujianguo@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/21/2012 03:19 AM, Andrew Morton wrote:
> On Tue, 20 Nov 2012 23:18:34 +0800
> Jiang Liu <liuj97@gmail.com> wrote:
> 
>>>> +static unsigned long calc_memmap_size(unsigned long spanned_pages,
>>>> +				      unsigned long present_pages)
>>>> +{
>>>> +	unsigned long pages = spanned_pages;
>>>> +
>>>> +	/*
>>>> +	 * Provide a more accurate estimation if there are big holes within
>>>> +	 * the zone and SPARSEMEM is in use.
>>>> +	 */
>>>> +	if (spanned_pages > present_pages + (present_pages >> 4) &&
>>>> +	    IS_ENABLED(CONFIG_SPARSEMEM))
>>>> +		pages = present_pages;
>>>> +
>>>> +	return PAGE_ALIGN(pages * sizeof(struct page)) >> PAGE_SHIFT;
>>>> +}
>>>
>>> Please explain the ">> 4" heuristc more completely - preferably in both
>>> the changelog and code comments.  Why can't we calculate this
>>> requirement exactly?  That might require a second pass, but that's OK for
>>> code like this?
>> Hi Andrew,
>> 	A normal x86 platform always have some holes within the DMA ZONE,
>> so the ">> 4" heuristic is to avoid applying this adjustment to the DMA
>> ZONE on x86 platforms. 
>> 	Because the memmap_size is just an estimation, I feel it's OK to
>> remove the ">> 4" heuristic, that shouldn't affect much.
> 
> Again: why can't we calculate this requirement exactly?  That might
> require a second pass, but that's OK for code like this?

Hi Andrew,
	If there are holes within a zone, it may cost us one or two extra pages
for each populated region within the zone due to alignment because memmap for 
each populated regions may not naturally aligned on page boundary.
	Originally the ">> 4" heuristic is to trade off these extra memmap pages,
especially for small zones linke DMA zone.
	Thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
