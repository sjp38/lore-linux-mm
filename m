Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id B26296B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:10:18 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id m1so488412ves.13
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:10:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130822004250.GB4665@bbox>
References: <1377065791-2959-1-git-send-email-minchan@kernel.org>
	<52148730.4000709@oracle.com>
	<20130822004250.GB4665@bbox>
Date: Fri, 23 Aug 2013 22:10:17 +0800
Message-ID: <CAA_GA1fZc89BRxKyS8zs-i0-+YJ9TsVXFFZcmza2Dzo4O4kiaA@mail.gmail.com>
Subject: Re: [PATCH v7 0/5] zram/zsmalloc promotion
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Bob Liu <bob.liu@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mgorman@suse.de>

Hi Minchan,

On Thu, Aug 22, 2013 at 8:42 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Bob,
>
> On Wed, Aug 21, 2013 at 05:24:00PM +0800, Bob Liu wrote:
>> Hi Minchan,
>>
>> On 08/21/2013 02:16 PM, Minchan Kim wrote:
>> > It's 7th trial of zram/zsmalloc promotion.
>> > I rewrote cover-letter totally based on previous discussion.
>> >
>> > The main reason to prevent zram promotion was no review of
>> > zsmalloc part while Jens, block maintainer, already acked
>> > zram part.
>> >
>> > At that time, zsmalloc was used for zram, zcache and zswap so
>> > everybody wanted to make it general and at last, Mel reviewed it
>> > when zswap was submitted to merge mainline a few month ago.
>> > Most of review was related to zswap writeback mechanism which
>> > can pageout compressed page in memory into real swap storage
>> > in runtime and the conclusion was that zsmalloc isn't good for
>> > zswap writeback so zswap borrowed zbud allocator from zcache to
>> > replace zsmalloc. The zbud is bad for memory compression ratio(2)
>> > but it's very predictable behavior because we can expect a zpage
>> > includes just two pages as maximum. Other reviews were not major.
>> > http://lkml.indiana.edu/hypermail/linux/kernel/1304.1/04334.html
>> >
>> > Zcache doesn't use zsmalloc either so zsmalloc's user is only
>> > zram now so this patchset moves it into zsmalloc directory.
>> > Recently, Bob tried to move zsmalloc under mm directory to unify
>> > zram and zswap with adding pseudo block device in zswap(It's
>> > very weired to me) but he was simple ignoring zram's block device
>> > (a.k.a zram-blk) feature and considered only swap usecase of zram,
>> > in turn, it lose zram's good concept.
>> >
>>
>> Yes, I didn't notice the feature that zram can be used as a normal block
>> device.
>>
>>
>> > Mel raised an another issue in v6, "maintainance headache".
>> > He claimed zswap and zram has a similar goal that is to compresss
>> > swap pages so if we promote zram, maintainance headache happens
>> > sometime by diverging implementaion between zswap and zram
>> > so that he want to unify zram and zswap. For it, he want zswap
>> > to implement pseudo block device like Bob did to emulate zram so
>> > zswap can have an advantage of writeback as well as zram's benefit.
>>
>> If consider zram as a swap device only, I still think it's better to add
>> a pseudo block device to zswap and just disable the writeback of zswap.
>
> Why do you think zswap is better?
>

In my opinion:
1. It's easy for zswap to do the same thing by adding a few small changes.
2. zswap won't get to the block layer which can reduce a lot of overheads.
3. zswap is transparent to current users who are using normal block
device as the swap device.

> I don't know but when I read http://lwn.net/Articles/334649/, it aimed
> for compressing page caches as well as swap pages but it made widespread
> hooks in core (I guess that's why zcache had a birth later by Nitin and Dan)
> so reviewers guided him to support anon pages only to merge it.
> And at that time, it was a specific virtual block device for only supporting
> swap. AFAIRC, akpm suggested to make it general block device so other party
> can have a benefit.
>
> You can type "zram tmp" in google and will find many article related
> to use zram as tmp and I have been received some questions/reports

I see.
But i think if using shmem as tmp, the pages can be reclaimed during
memory pressure,
get to zswap and compressed as well.

Mel also pointed a situation using zram as tmpfs may make things worse.

> from anonymous guys by private mail. And Jorome, Redhat guy, has
> contributed that part like partial I/O.
>

I am not going to block zram being promoted, just some different voice.

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
