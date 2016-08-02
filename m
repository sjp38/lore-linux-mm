Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 345956B025E
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 13:20:19 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id i184so292294941ywb.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:20:19 -0700 (PDT)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id k94si1025413uak.15.2016.08.02.10.20.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 10:20:18 -0700 (PDT)
Received: by mail-ua0-x229.google.com with SMTP id j59so134022646uaj.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 10:20:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160731062248.lqdakdzdyl7qya73@mguzik>
References: <CA+GA0_uRjKznAB+d-3bDqdNRDYBA+YQbYSUcB9=rDTLk1NJEmg@mail.gmail.com>
 <20160731062248.lqdakdzdyl7qya73@mguzik>
From: =?UTF-8?Q?Marcin_=C5=9Alusarz?= <marcin.slusarz@gmail.com>
Date: Tue, 2 Aug 2016 19:20:17 +0200
Message-ID: <CA+GA0_vGaHfpjYLq-NO4MMzRbgv0_YFnniaYXYQTvSNUUkSxKg@mail.gmail.com>
Subject: Re: Is reading from /proc/self/smaps thread-safe?
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mateusz Guzik <mguzik@redhat.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

2016-07-31 8:22 GMT+02:00 Mateusz Guzik <mguzik@redhat.com>:
> On Tue, Jul 26, 2016 at 02:44:48PM +0200, Marcin =C5=9Alusarz wrote:
>> Hey
>>
>> I have a simple program that mmaps 8MB of anonymous memory, spawns 16
>> threads, reads /proc/self/smaps in each thread and looks up whether
>> mapped address can be found in smaps. From time to time it's not there.
>>
>> Is this supposed to work reliably?
>>
>> My guess is that libc functions allocate memory internally using mmap
>> and modify process' address space while other thread is iterating over
>> vmas.
>>
>> I see that reading from smaps takes mmap_sem in read mode. I'm guessing
>> vm modifications are done under mmap_sem in write mode.
>>
>> Documentation/filesystem/proc.txt says reading from smaps is "slow but
>> very precise" (although in context of RSS).
>>
>
> Address space modification definitely happens as threads get their
> stacks mmaped and unmapped.
>
> If you run your program under strace you will see all threads perform
> multiple read()s to get the content as the kernel keeps return short
> reads (below 1 page size). In particular, seq_read imposes the limit
> artificially.
>
> Since there are multiple trips to the kernel, locks are dropped and
> special measures are needed to maintain consistency of the result.
>
> In m_start you can see there is a best-effort attempt: it is remembered
> what vma was accessed by the previous run. But the vma can be unmapped
> before we get here next time.

I added printks to m_start and I see that when last_addr is non-zero, find_=
vma
succeeds, even in cases when my test can't find its mapping.
So it seems the problem is not that simple.

Just for testing I commented out m_next_vma call from m_start and now my
test always succeeds (of course at the expense of duplicated entries).
Maybe it's just because of changed timing or maybe the problem is deeper...

>
> So no, reading the file when the content is bigger than 4k is not
> guaranteed to give consistent results across reads.
>
> I don't have a good idea how to fix it, and it is likely not worth
> working on. This is not the only place which is unable to return
> reliable information for sufficiently large dataset.
>
> The obvious thing to try out is just storing all the necessary
> information and generating the text form on read. Unfortunately even
> that data is quite big -- over 100 bytes per vma. This can be shrinked
> down significantly with encoding what information is present as opposed
> to keeping all records). But with thousands of entries per application
> this translates into kilobytes of memory which would have to allocated
> just to hold it, sounds like a non-starter to me.

Another idea is to change seq_read to flush data to user buffer every
time it's full, without "stopping/starting" the seq_file. The logic of seq_=
read
is quite hairy, so I didn't try this. And I'm not sure if page fault in
copy_to_user could retake mmap_sem in write mode.

Another (crazy) idea is to implement write operation for smaps where
buffer contents would pick the right VMA for the next read.
Too crazy? :)

Marcin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
