Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CA06C6B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 09:17:23 -0500 (EST)
Received: by vws5 with SMTP id 5so826349vws.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 06:17:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
Date: Thu, 4 Mar 2010 09:17:19 -0500
Message-ID: <87f94c371003040617t4a4fcd0dt1c9fc0f50e6002c4@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: Greg Freemyer <greg.freemyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: foo saa <foosaa@gmail.com>, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 1:42 AM, Andrew Morton <akpm@linux-foundation.org> w=
rote:
> (lots of cc's added)
>
> On Wed, 3 Mar 2010 23:52:20 -0500 foo saa <foosaa@gmail.com> wrote:
>
>> hi everyone,
>>
>> I am in the process of writing a disk erasure application in C. The
>> program does zerofill the drive (Good or Bad) before someone destroys
>> it. During the erasure process, I need to record the number of bad
>> sectors during the zerofill operation.
>>
>> The method used to write to the hdd involves opening the appropriate
>> /dev block device using open() call with O_WRONLY flag, start issuing
>> write() calls to fill the sectors. A 512 byte buffer filled with
>> zero's is used. All calls are of 64bit enabled. (I am using
>> _LARGEFILE64_SOURCE define).
>>
>> The problem is (mostly with the bad hdd's), when the write call
>> encounters a bad sector, it takes a bit longer than usual and writes
>> the sector without any errors. (dmesg shows a lot of error messages
>> embedded in the LIBATA error handling code!). The call never fails for
>> any reason.
>>
>> I am using 2.6.27-7-generic =A0and gcc version 4.3.2 =A0on ubuntu 8.10. =
I
>> have tried upto 2.6.30.10 and multiple distros with similar behavior.
>>
>> Here is a summary of things I have attempted.
>>
>> I know about the bad sector and it's location on the hdd, since it has
>> been verified by using Windows based hex editor utilities, DOS based
>> erasure applications, MHDD and many other HDD utilities.
>>
>> I have tried using O_DIRECT with aligned buffers, but still could not
>> identify the bad sectors during the writing process.
>>
>> I have tried using fadvise, posix_fadvise functions to get of the
>> caching, but still failed.
>>
>> I have tried using SG_IO and SAT translation (direct ATA commands with
>> device addressing) and it fails too. Raw devices is out of question
>> now.
>>
>> The libata is not letting / informing the user mode program (executing
>> under root) about the media / write errors / bad blocks and failures,
>> though it notifies the kernel and logs to syslog. It also tries to
>> reallocate, softreset, hardreset the block device which is evident
>> from the dmesg logs.
>>
>> What has to be done for my program to identify / receive the bad block
>> / sector information during the read / write process?
>>
>> How can I receive the bad sector / physical and media write errors in
>> my program? This is my only requirement and question.
>>
>> I am currently out of options unless anyone from here can show some
>> new direction!
>>
>> My only option is to recompile the kernel with libata customization
>> and changes according to my requirement. (Can I instruct to libata to
>> skip the error handling process and pass certain errors to my
>> program?).
>>
>> Is this a good approach and recommended one? If not what should be
>> done to achieve it? If yes, can somebody throw some light on it?
>>
>> Please let me know if you have any queries in my above explanation.
>>
>
> OK, this is bad.
>
> Did you try running fsync() after a write(), check the return value?
>
> I doubt if this is a VFS bug. =A0As O_DIRECT writes are also failing to
> report errors, I'd suspect that the driver or block layers really are
> failing to propagate the error back.
>
> Do the ata guys know of a way of deliberately injecting errors to test
> these codepaths? =A0If we don't have that, something using the
> fault-injection code would be nice. =A0As low-level as possible,
> preferably at interrupt time.

I think / suspect your major problem is you say above that you use a
512-byte buffer to wipe with.  The kernel is using 4K pages.  So when
you write to a 4K section of the drive for the first time, the kernel
implements read-modify-write logic.

Your i/o failures are almost certainly on the read cycle of the above,
not the write cycle.  You need to move to 4K buffers and you need to
ensure your 4K writes are aligned with how the kernel is working with
the disk.  ie. You need your 4K buffer to perfectly align with the
kernels 4K block handling so you never have a read-modify-write cycle.

Effectively you need your code to do something very similar to:

dd if=3D/dev/zero of=3D/dev/sda bs=3D4K conv=3Dsync,noerror

=3D=3D more background

1) In general disks do not have media errors on write.  They perform a
blind write that is assumed to work.  Errors do occur on read.  When
that happens the sector is tagged for relocation and on the next write
to that sector an alternate sector from the spares area is used.

If a drive has run out of spare sectors and a write is performed to a
sector tagged for relocation you will get a write error.  But it
should be a fast failure, there is nothing to retry.

2) For testing read i/o error logic, hdparm has the --make-bad-sector
command that will set the above mentioned flag.  It does it by forcing
the crc on the media to be bad.  All reads will therefore fail.

There is a corresponding clear bad sector that restores things to normal.

3) Modern drives to have a way to adjust the read timeout time.  I
don't recall the specifics right now, but since you should only be
writing, it wont help you anyway.

Good Luck
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
