Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A2E86B0011
	for <linux-mm@kvack.org>; Tue,  3 May 2011 14:54:46 -0400 (EDT)
Received: by iyh42 with SMTP id 42so484369iyh.14
        for <linux-mm@kvack.org>; Tue, 03 May 2011 11:54:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201105031516.28907.arnd@arndb.de>
References: <BANLkTinhK_K1oSJDEoqD6EQK8Qy5Wy3v+g@mail.gmail.com>
	<201105031516.28907.arnd@arndb.de>
Date: Tue, 3 May 2011 20:54:43 +0200
Message-ID: <BANLkTi=74Mp1vWBt2F-sqqqkeNfP69+9vg@mail.gmail.com>
Subject: Re: mmc blkqueue is empty even if there are pending reads in do_generic_file_read()
From: Per Forlin <per.forlin@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linux-mm@kvack.org, linux-mmc@vger.kernel.org, linaro-kernel@lists.linaro.org

On 3 May 2011 15:16, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thursday 28 April 2011, Per Forlin wrote:
>
>> For reads on the other hand it look like this
>> root@(none):/ dd if=3D/dev/mmcblk0 of=3D/dev/null bs=3D4k count=3D256
>> 256+0 records in
>> 256+0 records out
>> root@(none):/ dmesg
>> [mmc_queue_thread] req d954cec0 blocks 32
>> [mmc_queue_thread] req =A0 (null) blocks 0
>> [mmc_queue_thread] req =A0 (null) blocks 0
>> [mmc_queue_thread] req d954cec0 blocks 64
>> [mmc_queue_thread] req =A0 (null) blocks 0
>> [mmc_queue_thread] req d954cde8 blocks 128
>> [mmc_queue_thread] req =A0 (null) blocks 0
>> [mmc_queue_thread] req d954cec0 blocks 256
>> [mmc_queue_thread] req =A0 (null) blocks 0
>
>> There are never more than one read request in the mmc block queue. All
>> the mmc request preparations will be serialized and the cost for this
>> is roughly 10% lower bandwidth (verified on ARM platforms ux500 and
>> Pandaboard).
>
> After some offline discussions, I went back to look at your mail, and I t=
hink
> the explanation is much simpler than you expected:
>
> You have only a single process reading blocks synchronously, so the round
> trip goes all the way to user space. The block layer does some readahead,
> so it will start reading 32 blocks instead of just 8 (4KB) for the first
> read, but then the user process just sits waiting for data. After the
> mmc driver has finished reading the entire 32 blocks, the user needs a
> little time to read them from the page cache in 4 KB chunks (8 syscalls),
> during which the block layer has no clue about what the user wants to do
> next.
>
> The readahead scales up to 256 blocks, but there is still only one reader=
,
> so you never have additional requests in the queue.
>
> Try running multiple readers in parallel, e.g.
>
> for i in 1 2 3 4 5 ; do
> =A0 =A0 =A0 =A0dd if=3D/dev/mmcblk0 bs=3D16k count=3D256 iflag=3Ddirect s=
kip=3D$[$i * 1024] &
> done
Yes you are right about this. If I run with multiple read threads
there are multiple request waiting in the mmc block queue.

>> page_not_up_to_date:
>> /* Get exclusive access to the page ... */
>> error =3D lock_page_killable(page);
> I looked at the code in do_generic_file_read(). lock_page_killable
> waits until the current read ahead is completed.
> Is it possible to configure the read ahead to push multiple read
> request to the block device queue?add
When I first looked at this I used dd if=3D/dev/mmcblk0 of=3D/dev/null bs=
=3D1M count=3D4
If bs is larger than read ahead, this will make the execution loop in
do_generic_file_read() reading 512 until 1M is read. The second time
in this loop it will wait on lock_page_killable.

If bs=3D16k the execution wont stuck at lock_page_killable.


>
>
> =A0 =A0 =A0 =A0Arnd
>
Thanks,
Per

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
