Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0322D6B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 17:27:55 -0500 (EST)
Received: by vws6 with SMTP id 6so561929vws.14
        for <linux-mm@kvack.org>; Fri, 05 Mar 2010 14:27:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100305120355.6b161572@lxorguk.ukuu.org.uk>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
	 <4B8FC6AC.4060801@teksavvy.com>
	 <f875e2fe1003040733h20d5523ex5d18b84f47fee8c7@mail.gmail.com>
	 <4B8FF2C3.1060808@teksavvy.com>
	 <f875e2fe1003041020t7cbab2c2x585df9b2dfc10dd2@mail.gmail.com>
	 <4B90655B.4000005@gmail.com>
	 <f875e2fe1003041811p5aa934ecob90836a8d0a6b605@mail.gmail.com>
	 <20100305120355.6b161572@lxorguk.ukuu.org.uk>
Date: Fri, 5 Mar 2010 17:27:50 -0500
Message-ID: <f875e2fe1003051427u70aa1a4cl56c51c73cab4f1b0@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: s ponnusa <foosaa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Robert Hancock <hancockrwd@gmail.com>, Mark Lord <kernel@teksavvy.com>, Greg Freemyer <greg.freemyer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Having fsync / fdatasync results in the below mentioned behavior.

> - sectors being corrupted/dying that were not written by near to it
> - writes that the drive thinks were successful and reports that way but
> =A0turn out not to be readable

Always the write passes after much delay, but it turns out that the
sector is not readable.
But for my scenario, I need to know when a sector timeouts / errors
during the write process and move on to the next sector. Apparently I
have changed my program to do the following steps:

Open the drive in O_RDWR mode.
write a sector.
reposition the file pointer.
read the sector.
verify the read buffer contents with write buffer contents.

This scenario always passes and does not identify the bad sectors if
the program does it sequentially (even on a hdd with bad sectors).

But if I write using an independent program (prg A) and verify using
another independent program (prg B), all the writes done using prg A
passes (expected behavior) and the read operations from prg B fails on
bad sectors (again expected behavior) and I am able to detect the bad
sectors.

Is there any issue, if I perform both the operations simultaneously?
(Initially I tried using the O_DIRECT mode and as it was extremely
slow reverted to opening the device in O_RDWR mode and used fadvise
with don'tneed flag).

Thanks.

On Fri, Mar 5, 2010 at 7:03 AM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> cannot be read back by any other means. And the program which wrote
>> the data is unaware of the error that has happened at the lower level.
>> But the error log clearly has the issue caught but is trying to handle
>> differently.
>
> This is standard behaviour on pretty much every OS. If each write was
> back verified by the OS you wouldn't get any work done due fact it took
> so long to do any I/O and all I/O was synchronoous.
>
> Where it matters you can mount some file systems synchronous, you can do
> synchronous I/O (O_SYNC) or you can use and check fsync/fdatasync results
> which should give you pretty good coverage providing barriers are enabled=
.
>
> It still won't catch a lot of cases because you sometimes see
>
> - sectors being corrupted/dying that were not written by near to it
> - writes that the drive thinks were successful and reports that way but
> =A0turn out not to be readable
>
> Alan
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
