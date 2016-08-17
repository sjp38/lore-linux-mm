Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id C11256B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 08:38:34 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id j124so333119419ith.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:38:34 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id m143si27302900ita.23.2016.08.17.05.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Aug 2016 05:38:34 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id f6so8921085ith.2
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:38:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1585895702.34969.1471428208265.JavaMail.weblogic@epwas3e2>
References: <CGME20160817100328epcms5p2521a3ce1725a2cc4f2da82e2e1b79f33@epcms5p2>
 <1585895702.34969.1471428208265.JavaMail.weblogic@epwas3e2>
From: Pekka Enberg <penberg@kernel.org>
Date: Wed, 17 Aug 2016 15:38:33 +0300
Message-ID: <CAOJsxLErrX4MLZ5h5WcWi_021mA95FxF_Xq-PUWnMap3R+7Paw@mail.gmail.com>
Subject: Re: [PATCH 0/4] zswap: Optimize compressed pool memory utilization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: srividya.dr@samsung.com
Cc: sjenning@redhat.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dinakar Reddy Pathireddy <dinakar.p@samsung.com>, SUNEEL KUMAR SURIMANI <suneel@samsung.com>, =?UTF-8?B?6rmA7KO87ZuI?= <juhunkim@samsung.com>

On Wed, Aug 17, 2016 at 1:03 PM, Srividya Desireddy
<srividya.dr@samsung.com> wrote:
> This series of patches optimize the memory utilized by zswap for storing
> the swapped out pages.
>
> Zswap is a cache which compresses the pages that are being swapped out
> and stores them into a dynamically allocated RAM-based memory pool.
> Experiments have shown that around 10-15% of pages stored in zswap are
> duplicates which results in 10-12% more RAM required to store these
> duplicate compressed pages. Around 10-20% of pages stored in zswap
> are zero-filled pages, but these pages are handled as normal pages by
> compressing and allocating memory in the pool.
>
> The following patch-set optimizes memory utilized by zswap by avoiding the
> storage of duplicate pages and zero-filled pages in zswap compressed memory
> pool.
>
> Patch 1/4: zswap: Share zpool memory of duplicate pages
> This patch shares compressed pool memory of the duplicate pages. When a new
> page is requested for swap-out to zswap; search for an identical page in
> the pages already stored in zswap. If an identical page is found then share
> the compressed page data of the identical page with the new page. This
> avoids allocation of memory in the compressed pool for a duplicate page.
> This feature is tested on devices with 1GB, 2GB and 3GB RAM by executing
> performance test at low memory conditions. Around 15-20% of the pages
> swapped are duplicate of the pages existing in zswap, resulting in 15%
> saving of zswap memory pool when compared to the baseline version.
>
> Test Parameters         Baseline    With patch  Improvement
> Total RAM                   955MB       955MB
> Available RAM             254MB       269MB       15MB
> Avg. App entry time     2.469sec    2.207sec    7%
> Avg. App close time     1.151sec    1.085sec    6%
> Apps launched in 1sec   5             12             7
>
> There is little overhead in zswap store function due to the search
> operation for finding duplicate pages. However, if duplicate page is
> found it saves the compression and allocation time of the page. The average
> overhead per zswap_frontswap_store() function call in the experimental
> device is 9us. There is no overhead in case of zswap_frontswap_load()
> operation.
>
> Patch 2/4: zswap: Enable/disable sharing of duplicate pages at runtime
> This patch adds a module parameter to enable or disable the sharing of
> duplicate zswap pages at runtime.
>
> Patch 3/4: zswap: Zero-filled pages handling
> This patch checks if a page to be stored in zswap is a zero-filled page
> (i.e. contents of the page are all zeros). If such page is found,
> compression and allocation of memory for the compressed page is avoided
> and instead the page is just marked as zero-filled page.
> Although, compressed size of a zero-filled page using LZO compressor is
> very less (52 bytes including zswap_header), this patch saves compression
> and allocation time during store operation and decompression time during
> zswap load operation for zero-filled pages. Experiments have shown that
> around 10-20% of pages stored in zswap are zero-filled.

Aren't zero-filled pages already handled by patch 1/4 as their
contents match? So the overall memory saving is 52 bytes?

- Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
