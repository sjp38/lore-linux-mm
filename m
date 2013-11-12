Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6886D6B00EC
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 09:25:20 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so729129pbb.0
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 06:25:20 -0800 (PST)
Received: from psmtp.com ([74.125.245.153])
        by mx.google.com with SMTP id ws5si20063358pab.238.2013.11.12.06.25.18
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 06:25:19 -0800 (PST)
Received: by mail-we0-f180.google.com with SMTP id q59so6123972wes.11
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 06:25:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5281F0B4.8060902@oracle.com>
References: <CALZtONAxsYxLizARV3Aam_n7534g5gh_FFkTz6jb-0Q9gThuBQ@mail.gmail.com>
 <5281F0B4.8060902@oracle.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 12 Nov 2013 09:24:55 -0500
Message-ID: <CALZtONDAitXFfQWPfWG2Qy03NY7Q-2Asch0xQn0FEa-A6oNZTg@mail.gmail.com>
Subject: Re: mm/zswap: change to writethrough
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: sjennings@variantweb.net, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, minchan@kernel.org, weijie.yang@samsung.com, k.kozlowski@samsung.com, konrad.wilk@oracle.com

On Tue, Nov 12, 2013 at 4:11 AM, Bob Liu <bob.liu@oracle.com> wrote:
>
> On 11/12/2013 03:12 AM, Dan Streetman wrote:
>> Seth, have you (or anyone else) considered making zswap a writethrough
>> cache instead of writeback?  I think that it would significantly help
>> the case where zswap fills up and starts writing back its oldest pages
>> to disc - all the decompression work would be avoided since zswap
>> could just evict old pages and forget about them, and it seems likely
>> that when zswap is full that's probably the worst time to add extra
>> work/delay, while adding extra disc IO (presumably using dma) before
>> zswap is full doesn't seem to me like it would have much impact,
>> except in the case where zswap isn't full but there is so little free
>> memory that new allocs are waiting on swap-out.
>>
>> Besides the additional disc IO that obviously comes with making zswap
>> writethrough (additional only before zswap fills up), are there any
>> other disadvantages?  Is it a common situation for there to be no
>> memory left and get_free_page actively waiting on swap-out, but before
>> zswap fills up?
>>
>> Making it writethrough also could open up other possible improvements,
>> like making the compression and storage of new swap-out pages async,
>> so the compression doesn't delay the write out to disc.
>>
>
> I like this idea and those benefits, the only question I'm not sure is
> would it be too complicate to implement this feature? It sounds like we
> need to reimplement something like swapcache to handle zswap write through.

Simply converting to writethrough should be as easy as returning
non-zero from zswap_frontswap_store(), although
zswap_writeback_entry() also needs simplification to skip the
writeback.  I think it shouldn't be difficult; I'll start working on a
first pass of a patch.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
