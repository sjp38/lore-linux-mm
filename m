Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E84E6B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:28:22 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id at7so1316137obd.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:28:22 -0700 (PDT)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id u74si5132898itc.107.2016.06.17.05.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 05:28:19 -0700 (PDT)
Received: by mail-it0-x242.google.com with SMTP id f6so1834748ith.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:28:19 -0700 (PDT)
Subject: Re: [PATCH] zram: update zram to use zpool
References: <cover.1466000844.git.geliangtang@gmail.com>
 <efcf047e747d9d1e80af16ebfc51ea1964a7a621.1466000844.git.geliangtang@gmail.com>
 <20160615231732.GJ17127@bbox>
 <CAMJBoFPcaAbsQ=PA2WPsmuyd1a-SyJgE5k4Rn2CUf6rS0-ykKw@mail.gmail.com>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <8ffd0aab-1adb-17a9-3055-ad60c31f8eb6@gmail.com>
Date: Fri, 17 Jun 2016 08:28:14 -0400
MIME-Version: 1.0
In-Reply-To: <CAMJBoFPcaAbsQ=PA2WPsmuyd1a-SyJgE5k4Rn2CUf6rS0-ykKw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Geliang Tang <geliangtang@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 2016-06-17 04:30, Vitaly Wool wrote:
> Hi Minchan,
>
> On Thu, Jun 16, 2016 at 1:17 AM, Minchan Kim <minchan@kernel.org> wrote:
>> On Wed, Jun 15, 2016 at 10:42:07PM +0800, Geliang Tang wrote:
>>> Change zram to use the zpool api instead of directly using zsmalloc.
>>> The zpool api doesn't have zs_compact() and zs_pool_stats() functions.
>>> I did the following two things to fix it.
>>> 1) I replace zs_compact() with zpool_shrink(), use zpool_shrink() to
>>>    call zs_compact() in zsmalloc.
>>> 2) The 'pages_compacted' attribute is showed in zram by calling
>>>    zs_pool_stats(). So in order not to call zs_pool_state() I move the
>>>    attribute to zsmalloc.
>>>
>>> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
>>
>> NACK.
>>
>> I already explained why.
>> http://lkml.kernel.org/r/20160609013411.GA29779@bbox
>
> This is a fair statement, to a certain extent. I'll let Geliang speak
> for himself but I am personally interested in this zram extension
> because I want it to work on MMU-less systems. zsmalloc can not handle
> that, so I want to be able to use zram over z3fold.
I concur with this.

It's also worth pointing out that people can and do use zram for things 
other than swap, so the assumption that zswap is a viable alternative is 
not universally correct.  In my case for example, I use it on a VM host 
for temporary storage for transient SSI VM's.  Making it more 
deterministic would be seriously helpful in this case, as it would mean 
I can more precisely provision resources on this particular system, and 
could better account for latencies in the testing these transient VM's 
are used for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
