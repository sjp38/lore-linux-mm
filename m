Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 743556B0006
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 02:02:34 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id 78so10934401pfw.2
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 23:02:34 -0800 (PST)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id 75si5749602pfq.220.2015.12.20.23.02.32
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 23:02:33 -0800 (PST)
Message-ID: <5677A378.6010703@cn.fujitsu.com>
Date: Mon, 21 Dec 2015 15:00:08 +0800
From: Zhu Guihua <zhugh.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] theoretical race between memory hotplug and pfn iterator
References: <20151221031501.GA32524@js1304-P5Q-DELUXE>
In-Reply-To: <20151221031501.GA32524@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Toshi Kani <toshi.kani@hpe.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org


On 12/21/2015 11:15 AM, Joonsoo Kim wrote:
> Hello, memory-hotplug folks.
>
> I found theoretical problems between memory hotplug and pfn iterator.
> For example, pfn iterator works something like below.
>
> for (pfn = zone_start_pfn; pfn < zone_end_pfn; pfn++) {
>          if (!pfn_valid(pfn))
>                  continue;
>
>          page = pfn_to_page(pfn);
>          /* Do whatever we want */
> }
>
> Sequence of hotplug is something like below.
>
> 1) add memmap (after then, pfn_valid will return valid)
> 2) memmap_init_zone()
>
> So, if pfn iterator runs between 1) and 2), it could access
> uninitialized page information.
>
> This problem could be solved by re-ordering initialization steps.
>
> Hot-remove also has a problem. If memory is hot-removed after
> pfn_valid() succeed in pfn iterator, access to page would cause NULL
> deference because hot-remove frees corresponding memmap. There is no
> guard against free in any pfn iterators.
>
> This problem can be solved by inserting get_online_mems() in all pfn
> iterators but this looks error-prone for future usage. Another idea is
> that delaying free corresponding memmap until synchronization point such
> as system suspend. It will guarantee that there is no running pfn
> iterator. Do any have a better idea?
>
> Btw, I tried to memory-hotremove with QEMU 2.5.5 but it didn't work. I
> followed sequences in doc/memory-hotplug. Do you have any comment on this?

I tried memory hot remove with qemu 2.5.5 and RHEL 7, it works well.
Maybe you can provide more details, such as guest version, err log.

Thanks,
Zhu

>
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
> .
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
