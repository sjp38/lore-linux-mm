Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 8F8AF6B005D
	for <linux-mm@kvack.org>; Sun,  1 Jul 2012 22:04:15 -0400 (EDT)
Message-ID: <4FF100F0.9050501@huawei.com>
Date: Mon, 2 Jul 2012 10:01:20 +0800
From: Jiang Liu <jiang.liu@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: setup pageblock_order before it's used by sparse
References: <1341047274-5616-1-git-send-email-jiang.liu@huawei.com> <CAE9FiQWzfLkeQs8O22MUEmuGUx=jPi5s=wZt2fcpFMcwrzt3uA@mail.gmail.com>
In-Reply-To: <CAE9FiQWzfLkeQs8O22MUEmuGUx=jPi5s=wZt2fcpFMcwrzt3uA@mail.gmail.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tony Luck <tony.luck@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

Hi Yinghai,
	The patch fails compilation as below:
mm/page_alloc.c:151: error: initializer element is not constant
mm/page_alloc.c:151: error: expected ?,? or ?;? before ?__attribute__?

On IA64, HUGETLB_PAGE_ORDER has dependency on variable hpage_shift.
# define HUGETLB_PAGE_ORDER        (HPAGE_SHIFT - PAGE_SHIFT)
# define HPAGE_SHIFT               hpage_shift

And hpage_shift could be changed by early parameter "hugepagesz".
So seems will still need to keep function set_pageblock_order().

Thanks!
Gerry

On 2012-7-1 4:15, Yinghai Lu wrote:
> On Sat, Jun 30, 2012 at 2:07 AM, Jiang Liu <jiang.liu@huawei.com> wrote:
>> From: Xishi Qiu <qiuxishi@huawei.com>
>>
>> On architectures with CONFIG_HUGETLB_PAGE_SIZE_VARIABLE set, such as Itanium,
>> pageblock_order is a variable with default value of 0. It's set to the right
>> value by set_pageblock_order() in function free_area_init_core().
>>
>> But pageblock_order may be used by sparse_init() before free_area_init_core()
>> is called along path:
>> sparse_init()
>>    ->sparse_early_usemaps_alloc_node()
>>        ->usemap_size()
>>            ->SECTION_BLOCKFLAGS_BITS
>>                ->((1UL << (PFN_SECTION_SHIFT - pageblock_order)) *
>> NR_PAGEBLOCK_BITS)
>>
>> The uninitialized pageblock_size will cause memory wasting because usemap_size()
>> returns a much bigger value then it's really needed.
>>
>> For example, on an Itanium platform,
>> sparse_init() pageblock_order=0 usemap_size=24576
>> free_area_init_core() before pageblock_order=0, usemap_size=24576
>> free_area_init_core() after pageblock_order=12, usemap_size=8
>>
>> That means 24K memory has been wasted for each section, so fix it by calling
>> set_pageblock_order() from sparse_init().
>>
> 
> can you check attached patch?
> 
> That will kill more lines code instead.
> 
> Thanks
> 
> Yinghai


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
