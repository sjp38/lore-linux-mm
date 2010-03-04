Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 126976B0085
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 10:33:55 -0500 (EST)
Received: by vws5 with SMTP id 5so876104vws.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 07:33:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B8FC6AC.4060801@teksavvy.com>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
Date: Thu, 4 Mar 2010 10:33:52 -0500
Message-ID: <f875e2fe1003040733h20d5523ex5d18b84f47fee8c7@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: foo saa <foosaa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mark Lord <kernel@teksavvy.com>
Cc: Greg Freemyer <greg.freemyer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am using 4k aligned buffers for writing and reading.

Kernel / driver catches the error during the write cycle and I can get
the error messages about the media being bad or sector i/o errors. But
it is not propagated to the program and write always passes (even in
the case of the device being out of control. (i.e., the device fails
to respond to any further open / read / write queries and inaccessible
from the core). Isn't the error has to be notified to the program that
makes the call?

Reading is a completely different scenario and I am disabling the
read-ahead cache completely with fadvise call.

hdparm is good, but I don't want to use the internal ATA SECURE ERASE
because I can never get the amount of bad sectors the drive had.

On Thu, Mar 4, 2010 at 9:41 AM, Mark Lord <kernel@teksavvy.com> wrote:
> On 03/04/10 09:17, Greg Freemyer wrote:
> ..
>>
>> I think / suspect your major problem is you say above that you use a
>> 512-byte buffer to wipe with. =A0The kernel is using 4K pages. =A0So whe=
n
>> you write to a 4K section of the drive for the first time, the kernel
>> implements read-modify-write logic.
>>
>> Your i/o failures are almost certainly on the read cycle of the above,
>> not the write cycle. =A0You need to move to 4K buffers and you need to
>> ensure your 4K writes are aligned with how the kernel is working with
>> the disk. =A0ie. You need your 4K buffer to perfectly align with the
>> kernels 4K block handling so you never have a read-modify-write cycle.
>
> ..
>
> You'll also need to disable Linux read-ahead for the drive,
> or it may try reading beyond even the 4KB block.
>
> But really.. isn't "hdparm --security-erase NULL /dev/sdX" good enough ??=
?
>
> Cheers
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
