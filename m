Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 63EAC6B009B
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 13:13:03 -0500 (EST)
Received: by vws6 with SMTP id 6so29011vws.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 10:13:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201003041631.o24GVl51005720@alien.loup.net>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
	 <201003041631.o24GVl51005720@alien.loup.net>
Date: Thu, 4 Mar 2010 13:12:59 -0500
Message-ID: <f875e2fe1003041012m680ffc87i50099ed011526440@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: s ponnusa <foosaa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mike Hayward <hayward@loup.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The write cache is turned off at the hdd level. I am using O_DIRECT
mode with aligned buffers of the 4k page size. I have turned off the
page cache and read ahead during read as well using the fadvise
function.

As you have mentioned, the program grinds the hdd when it hits the bad
sector patch. It retries to remap / write again until it (hdd) fails.
It then finds the hdd does not respond and finally resets the device.
(This goes on and the program eventually moves on the next sector
because write call returned success. No errno value was set. Is this
how a write will function in linux? It does not propagate the error to
the user mode program for any reasons related to the disk failures
during a write process even with the O_DIRECT flag.

Is there any specific location, that can be used to turn off the
sector remapping, retrying option at the libata level (I don't want to
change it at the public repository, rather I would like to change in
my kernel for testing / debugging purposes) and propagating the error
to the usermode programs? The messages in syslog are due to the printk
calls at the libata-eh.c file in the drivers/ata section of the kernel
code. But I have not spend much analysing it though.

Thanks.

On Thu, Mar 4, 2010 at 11:31 AM, Mike Hayward <hayward@loup.net> wrote:
> I have seen a couple of your posts on this and thought I'd chime in
> since I know a bit about storage.
>
> I frequently see io errors come through to user space (both read and
> write requests) from usb flash drives, so there is a functioning error
> path there to some degree. =A0When I see the errors, the kernel is also
> logging the sector and eventually resetting the device.
>
> There is no doubt a disk drive will slow down when it hits a bad spot
> since it will retry numerous times, most likely trying to remap bad
> blocks. =A0Of course your write succeeded because you probably have the
> drive cache enabled. =A0Flush or a full cache hangs while the drive
> retries all of the sectors that are bad, remapping them until finally
> it can remap no more. =A0At some point it probably returns an error if
> flush is timing out or it can't remap any more sectors, but it won't
> include the bad sector.
>
> I would suggest turning the drive cache off. =A0Then the drive won't lie
> to you about completing writes and you'll at least know which sectors
> are bad. =A0Just a thought :-)
>
> - Mike
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
