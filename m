Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 56BD36B0003
	for <linux-mm@kvack.org>; Sun, 20 Dec 2015 22:13:05 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id n128so63804698pfn.0
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 19:13:05 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id hr4si410736pad.183.2015.12.20.19.13.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 20 Dec 2015 19:13:04 -0800 (PST)
Date: Mon, 21 Dec 2015 12:15:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC] theoretical race between memory hotplug and pfn iterator
Message-ID: <20151221031501.GA32524@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Toshi Kani <toshi.kani@hpe.com>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org

Hello, memory-hotplug folks.

I found theoretical problems between memory hotplug and pfn iterator.
For example, pfn iterator works something like below.

for (pfn = zone_start_pfn; pfn < zone_end_pfn; pfn++) {
        if (!pfn_valid(pfn))
                continue;

        page = pfn_to_page(pfn);
        /* Do whatever we want */
}

Sequence of hotplug is something like below.

1) add memmap (after then, pfn_valid will return valid)
2) memmap_init_zone()

So, if pfn iterator runs between 1) and 2), it could access
uninitialized page information.

This problem could be solved by re-ordering initialization steps.

Hot-remove also has a problem. If memory is hot-removed after
pfn_valid() succeed in pfn iterator, access to page would cause NULL
deference because hot-remove frees corresponding memmap. There is no
guard against free in any pfn iterators.

This problem can be solved by inserting get_online_mems() in all pfn
iterators but this looks error-prone for future usage. Another idea is
that delaying free corresponding memmap until synchronization point such
as system suspend. It will guarantee that there is no running pfn
iterator. Do any have a better idea?

Btw, I tried to memory-hotremove with QEMU 2.5.5 but it didn't work. I
followed sequences in doc/memory-hotplug. Do you have any comment on this?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
