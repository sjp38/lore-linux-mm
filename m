Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9712F6B0039
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 16:07:40 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so2146829pdj.14
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:07:40 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id kb10si5226844pbc.5.2014.08.14.13.07.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 13:07:39 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id eu11so2233844pac.31
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 13:07:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALZtONCSUZiNdZ12XJcSZPPOemGXyc27Fy=BKT6ZAFWwBFgu6w@mail.gmail.com>
References: <1407978746-20587-1-git-send-email-minchan@kernel.org>
	<1407978746-20587-3-git-send-email-minchan@kernel.org>
	<CALZtONDB5q56f1TUHgqbiJ4ZaP6Yk=GcNQw9DhvLhNyExdfQ4w@mail.gmail.com>
	<CAFdhcLQ11MnF7Py+X1wrJMiu0L15-JrV883oYGopdz1oag0njQ@mail.gmail.com>
	<CAFdhcLQ2cU8APUP=qVQqQmWT8jouFvdSHPVsQ8RCXceaVWa4dQ@mail.gmail.com>
	<CALZtONCSUZiNdZ12XJcSZPPOemGXyc27Fy=BKT6ZAFWwBFgu6w@mail.gmail.com>
Date: Thu, 14 Aug 2014 16:07:39 -0400
Message-ID: <CAFdhcLQ+LrVyqeBeXf++sV2RddBn2Rn6w7ZRX1szU+XW8+SPXA@mail.gmail.com>
Subject: Re: [PATCH 3/3] zram: add mem_used_max via sysfs
From: David Horner <ds2horner@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>

On Thu, Aug 14, 2014 at 3:11 PM, Dan Streetman <ddstreet@ieee.org> wrote:
> On Thu, Aug 14, 2014 at 12:23 PM, David Horner <ds2horner@gmail.com> wrote:
>> On Thu, Aug 14, 2014 at 11:32 AM, David Horner <ds2horner@gmail.com> wrote:
>>> On Thu, Aug 14, 2014 at 11:09 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>>>> On Wed, Aug 13, 2014 at 9:12 PM, Minchan Kim <minchan@kernel.org> wrote:
>>>>> -       if (zram->limit_bytes &&
>>>>> -               zs_get_total_size_bytes(meta->mem_pool) > zram->limit_bytes) {
>>>>> +       total_bytes = zs_get_total_size_bytes(meta->mem_pool);
>>>>> +       if (zram->limit_bytes && total_bytes > zram->limit_bytes) {
>>>>
>>>> do you need to take the init_lock to read limit_bytes here?  It could
>>>> be getting changed between these checks...
>>>
>>> There is no real danger in freeing with an error.
>>> It is more timing than a race.
>> I probably should explain my reasoning.
>>
>> any changes between getting the total value and the limit test are not
>> problematic (From race perspective).
>>
>> 1) If the actual total increases and the value returned under rates it, then
>> a) if this.total exceeds the limit - no problem it is rolled back as
>> it would if the actual total were used.
>> b) if this.total <= limit OK - as other process will be dinged (it
>> will see its own allocation)
>>
>> 2)  If the actual total decreases and the value returned overrates
>> rates it, then
>> a) if this.value <= limit then allocation great (actual has even more room)
>> b) if this.value > max it will be rolled back (as the other might be
>> as well) and process can compete again.
>

for completeness I should have mentioned the normal decrease case of
deallocation
and not roll back.
(and of course it is also not a problem and does not race).

Are these typical situations in documentation folder
(I know the related memory barriers is)
It would be so much better to say scenario 23 is a potential problem
rather than rewriting the essays.


> actually I wasn't thinking of total_bytes changing, i think it's ok to
> check the total at that specific point in time, for the reasons you
> point out above.
>
> I was thinking about zram->limit_bytes changing, especially if it's
> possible to disable the limit (i.e. set it to 0), e.g.:
>
> assume currently total_bytes == 1G and limit_bytes == 2G, so there is
> not currently any danger of going over the limit.  Then:
>
>
> thread 1 : if (zram->limit_bytes  ...this is true
>
> thread 2 : zram->limit_bytes = limit;    ...where limit == 0
>
> thread 1 : && total_bytes > zram->limit_bytes) {   ...this is now also true
>
> thread 1 : incorrectly return -ENOMEM failure
>
> It's very unlikely, and a single failure isn't a big deal here since
> the caller must be prepared to handle a failure.  And of course the
> compiler might reorder those checks.  And if it's not possible to
> disable the limit by setting it to 0 (besides a complete reset of the
> zram device, which wouldn't happen while this function is running),
> then there's not an issue here (although, I think being able to
> disable the limit without having to reset the zram device is useful).

agreed on 7 of 8 assertions
 (not yet sure about reset not happening while function running).

That issue then arises in [PATCH 2/2] zram: limit memory size for zram
and as you mention reordering the zero check after the limit comparison
in the if statement could be reordered by the compiler

As I see it this is also a timing issue - as you explained, and not a race.

Perhaps we name it scenario 24?

And especially I agree with allowing zero limit reset without device reset.
The equivalent is currently possible (for all practical purposes)
anyway by setting
the limit to max_u64.
So allowing zero is cleaner.


>
>
> Also for setting the max_used_bytes, isn't non-atomically setting a
> u64 value dangerous (on <64 bit systems) when it's not synchronized
> between threads?

perhaps it needs an atomic function - I will think some more on it.

>
> That is, unless the entire zram_bvec_write() function or this section
> is already thread-safe, and i missed it (which i may have :-)

nor have I.checked.(on the to do).

>
>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
