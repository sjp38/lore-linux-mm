Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 681C16B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 17:10:20 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w187so156427447pgb.10
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:10:20 -0700 (PDT)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id e12si4524290pgn.770.2017.08.14.14.10.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 14:10:19 -0700 (PDT)
Received: by mail-pg0-x229.google.com with SMTP id i12so3743782pgr.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:10:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <b2fbc169-f02e-92a7-d341-5d40868fe4bd@molgen.mpg.de>
References: <0ef258fb-57ad-277c-fa34-31f1c41f80e0@molgen.mpg.de>
 <CAM_iQpVA1gSaLZct_wAwZLxUbQoH2Nby5NRSc=PDi2LPQFtxUA@mail.gmail.com> <b2fbc169-f02e-92a7-d341-5d40868fe4bd@molgen.mpg.de>
From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 14 Aug 2017 14:09:58 -0700
Message-ID: <CAM_iQpUJBdjYWLgzgtsTdx5afXL3OEhBbGCo0iNWWq4LWMKPWA@mail.gmail.com>
Subject: Re: `page allocation failure: order:0` with ixgbe under high load
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menzel <pmenzel@molgen.mpg.de>
Cc: linux-mm <linux-mm@kvack.org>, it+linux-mm@molgen.mpg.de

On Mon, Aug 14, 2017 at 7:18 AM, Paul Menzel <pmenzel@molgen.mpg.de> wrote:
> Dear Cong,
>
>
> Thank you for the response.
>
>
> On 08/11/17 19:51, Cong Wang wrote:
>
>> On Fri, Aug 11, 2017 at 8:36 AM, Paul Menzel <pmenzel@molgen.mpg.de>
>> wrote:
>>> Or should some parameters be tuned?
>>>
>>> ```
>>> $ more /proc/sys/vm/min*
>>> ::::::::::::::
>>> /proc/sys/vm/min_free_kbytes
>>> ::::::::::::::
>>> 39726
>>
>>
>>
>> Can you try to increase this? Although it depends on your workload,
>> 38M seems too small for a host with 96+G memory.
>
>
> Increasing the value to 128 MB did not get rid of the warning. With 256 M=
B
> we were unable to reproduce the warning.


Interesting. I wonder if we should just increase the hard-coded cap
(64M) for the default min_free_kbytes, or make it configurable at
compile-time.


>
>>> ::::::::::::::
>>> /proc/sys/vm/min_slab_ratio
>>> ::::::::::::::
>>> 5
>>> ::::::::::::::
>>> /proc/sys/vm/min_unmapped_ratio
>>> ::::::::::::::
>>> 1
>>> ```
>>>
>>> There is quite some information about this on the WWW [1], but some
>>> suggest
>>> that with recent Linux kernels, this shouldn=E2=80=99t happen, as memor=
y get
>>> defragmented.
>>
>>
>>
>> On the other hand, the allocation order is 0 anyway. ;)
>
>
> Right. Coherent(?) memory is not needed for an order of 0.
>
> In our case the memory is mainly occupied by the disk(?) buffer/cache, an=
d
> not the real program. So there is plenty available. Shouldn=E2=80=99t the=
 Linux
> kernel be able to deal with such situations, or is this exactly the use
> case, which the parameter `min_free_kbytes` is for?

Well, for atomic memory allocations, we can't wait for these memory
to drain or reclaim, I think this is why min_free_kbytes exits.

Atomic allocations are heavily used by networking, so the 64M cap
is really not enough for a heavily loaded network server with a
fast NIC.

But I am not at all a MM expert. ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
