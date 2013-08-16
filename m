Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id F2D036B0032
	for <linux-mm@kvack.org>; Fri, 16 Aug 2013 00:55:57 -0400 (EDT)
Received: by mail-vc0-f173.google.com with SMTP id id13so1128379vcb.18
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 21:55:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130816042641.GA2893@gmail.com>
References: <1376459736-7384-1-git-send-email-minchan@kernel.org>
	<20130814174050.GN2296@suse.de>
	<20130814185820.GA2753@gmail.com>
	<20130815171250.GA2296@suse.de>
	<20130816042641.GA2893@gmail.com>
Date: Fri, 16 Aug 2013 12:55:56 +0800
Message-ID: <CAA_GA1cLXaW9RH5Wfe4atJ6nWwP9HbrqNfFFYTPL4Uy5BonTug@mail.gmail.com>
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Luigi Semenzato <semenzato@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>

Hi Minchan,

On Fri, Aug 16, 2013 at 12:26 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hi Mel,
>
> On Thu, Aug 15, 2013 at 06:12:50PM +0100, Mel Gorman wrote:
>> On Thu, Aug 15, 2013 at 03:58:20AM +0900, Minchan Kim wrote:
>> > > <SNIP>
>> > >
>> > > I do not believe this is a problem for zram as such because I do not
>> > > think it ever writes back to disk and is immune from the unpredictable
>> > > performance characteristics problem. The problem for zram using zsmalloc
>> > > is OOM killing. If it's used for swap then there is no guarantee that
>> > > killing processes frees memory and that could result in an OOM storm.
>> > > Of course there is no guarantee that memory is freed with zbud either but
>> > > you are guaranteed that freeing 50%+1 of the compressed pages will free a
>> > > single physical page. The characteristics for zsmalloc are much more severe.
>> > > This might be managable in an applicance with very careful control of the
>> > > applications that are running but not for general servers or desktops.
>> >
>> > Fair enough but let's think of current usecase for zram.
>> > As I said in description, most of user for zram are embedded products.
>> > So, most of them has no swap storage and hate OOM kill because OOM is
>> > already very very slow path so system slow response is really thing
>> > we want to avoid. We prefer early process kill to slow response.
>> > That's why custom low memory killer/notifier is popular in embedded side.
>> > so actually, OOM storm problem shouldn't be a big problem under
>> > well-control limited system.
>> >
>>
>> Which zswap could also do if
>>
>> a) it had a pseudo block device that failed all writes
>> b) zsmalloc was pluggable
>>
>> I recognise this sucks because zram is already in the field but if zram
>> is promoted then zram and zswap will continue to diverge further with no
>> reconcilation in sight.
>>
>> Part of the point of using zswap was that potentially zcache could be
>> implemented on top of it and so all file cache could be stored compressed
>> in memory. AFAIK, it's not possible to do the same thing for zram because
>> of the lack of writeback capabilities. Maybe it could be done if zram
>> could be configured to write to an underlying storage device but it may
>> be very clumsy to configure. I don't know as I never investigated it and
>> to be honest, I'm struggling to remember how I got involved anywhere near
>> zswap/zcache/zram/zwtf in the first place.
>>
>> > > If it's used for something like tmpfs then it becomes much worse. Normal
>> > > tmpfs without swap can lockup if tmpfs is allowed to fill memory. In a
>> > > sane configuration, lockups will be avoided and deleting a tmpfs file is
>> > > guaranteed to free memory. When zram is used to back tmpfs, there is no
>> > > guarantee that any memory is freed due to fragmentation of the compressed
>> > > pages. The only way to recover the memory may be to kill applications
>> > > holding tmpfs files open and then delete them which is fairly drastic
>> > > action in a normal server environment.
>> >
>> > Indeed.
>> > Actually, I had a plan to support zsmalloc compaction. The zsmalloc exposes
>> > handle instead of pure pointer so it could migrate some zpages to somewhere
>> > to pack in. Then, it could help above problem and OOM storm problem.
>> > Anyway, it's a totally new feature and requires many changes and experiement.
>> > Although we don't have such feature, zram is still good for many people.
>> >
>>
>> And is zsmalloc was pluggable for zswap then it would also benefit.
>
> But zswap isn't pseudo block device so it couldn't be used for block device.
> Let say one usecase for using zram-blk.
>

But maybe we can make zswap creating some pseudo block devices.
All data will be stored in zswap memory pool instead of real device.

If zswap pool gets full, refuse to accept any new pages(no wirte back
will happen).
That's all the same as zram.
In this case, zswap can be used to replace zram!

> 1) Many embedded system don't have swap so although tmpfs can support swapout
> it's pointless still so such systems should have sane configuration to limit
> memory space so it's not only zram problem.
>
> 2) Many embedded system don't have enough memory. Let's assume short-lived
> file growing up until half of system memory once in a while. We don't want
> to write it on flash by wear-leveing issue and very slowness so we want to use
> in-memory but if we uses tmpfs, it should evict half of working set to cover
> them when the size reach peak. zram would be better choice.
>
>>
>> > > These are the sort of reason why I feel that zram has limited cases where
>> > > it is safe to use and zswap has a wider range of applications. At least
>> > > I would be very unhappy to try supporting zram in the field for normal
>> > > servers. zswap should be able to replace the functionality of zram+swap
>> > > by backing zswap with a pseudo block device that rejects all writes. I
>> >
>> > One of difference between zswap and zram is asynchronous I/O support.
>>
>> As zram is not writing to disk, how compelling is asynchronous IO? If
>> zswap was backed by the pseudo device is there a measurable bottleneck?
>
> Compression. It was really bottlneck point. I had an internal patch which
> can make zram use various compressor, not only LZO.
> The better good compressor was, the more bottlenck compressor was.
>
>>
>> > I guess frontswap is synchronous by semantic while zram could support
>> > asynchronous I/O.
>> >
>> > > do not know why this never happened but guess the zswap people never were
>> > > interested and the zram people never tried. Why was the pseudo device
>> > > to avoid writebacks never implemented? Why was the underlying allocator
>> > > not made pluggable to optionally use zsmalloc when the user did not care
>> > > that it had terrible writeback characteristics?
>> >
>> > I remember you suggested to make zsmalloc with pluggable for zswap.
>> > But I don't know why zswap people didn't implement it.
>> >
>> > >
>> > > zswap cannot replicate zram+tmpfs but I also think that such a configuration
>> > > is a bad idea anyway. As zram is already being deployed then it might get
>> >
>> > It seems your big concern of zsmalloc is fragmentaion so if zsmalloc can
>> > support compaction, it would mitigate the concern.
>> >
>>
>> Even if it supported zsmalloc I would still wonder why zswap is not using
>> it as a pluggable option :(
>>
>> > > promoted anyway but personally I think compressed memory continues to be
>> >
>> > I admit zram might have limitations but it has helped lots of people.
>> > It's not an imaginary scenario.
>> >
>>
>> I know.
>>
>> > Please, let's not do get out of zram from kernel tree and stall it on staging
>> > forever with preventing new features.
>> > Please, let's promote, expose it to more potential users, receive more
>> > complains from them, recruit more contributors and let's enhance.
>> >
>>
>> As this is already used heavily in the field and I am not responsible
>> for maintaining it I am not going to object to it being promoted. I can
>> always push that it be disabled in distribution configs as it is not
>> suitable for general workloads for reason already discussed.
>>
>> However, I believe that the promotion will lead to zram and zswap diverging
>> further from each other, both implementing similar functionality and
>> ultimately cause greater maintenance headaches. There is a path that makes
>> zswap a functional replacement for zram and I've seen no good reason why
>> that path was not taken. Zram cannot be a functional replacment for zswap
>> as there is no obvious sane way writeback could be implemented. Continuing
>
> Then, do you think current zswap's writeback is sane way?
> I didn't raise an issue because I didn't want to be a blocker when zswap was
> promoted. Actually, I didn't like that way because I thought swap-writeback
> feature should be implemented by VM itself rather than some hooked driver
> internal logic. VM alreay has a lot information so it would handle multipe
> heterogenous swap more efficenlty like cache hierachy without LRU inversing.
> It could solve current zswap LRU inversing problem generally and help others
> who want to configure multiple swap system as well as zram.
>
>> to diverge will ultimately bite someone in the ass.
>
> Mel, current zram situation is following as.
>
> 1) There are a lot users in the world.
> 2) So, many valuable contributions have been in there.
> 2) The new feature development of zram had stalled because Greg asserted
>    he doesn't accept new feature until promote will be done and recently,
>    he said he will remove zram in staging if anybody doesn't try to promote
> 3) You are saying zram shouldn't be promote. IOW, zram should go away.
>
> Right? Then, What should we zram developers do?

In my opinion we can do:
1) promote zsmalloc to mm/
2) making zswap can support zsmalloc
3) making zswap can create some fake block device and emulate the same
action of zram
like don't write back.

> What's next step for zram which is really perfect for embedded system?
> We should really lose a chance to enhance zram although fresh zswap
> couldn't replace old zram?
>
> Mel, please consider embedded world although they are very little voice
> in this core subsystem.
>

-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
