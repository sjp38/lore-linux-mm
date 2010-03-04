Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C2CA6B0047
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 07:58:09 -0500 (EST)
Received: by vws5 with SMTP id 5so745747vws.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 04:58:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
Date: Thu, 4 Mar 2010 07:58:07 -0500
Message-ID: <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: foo saa <foosaa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, Jens Axboe <jens.axboe@oracle.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Thanks for adding the mailing lists.

I have tried fsync(), fdatasync() after the write calls, but still the
write() passes without propagating any error. dmesg still shows
multiples of thousands of bad i/o errors for logical sectors.

Also, one noted behavior is that if I use fsync / fdatasync, the write
process becomes extremely slow when it encounters the bad sectors and
grinds the hdd for longer durations.

Is there any user specified timeout that can set on it too?

You are right about the error propagation failure. The errors are
caught the driver level (atleast at the lidata driver) as it logs the
messages from drivers/ata/libata-eh.c / libata-scsi.c to the syslog.

I have spend much time in analysing the kernel source code because I
have been trying multiple combinations for my program to work and each
testing consumes about 3-4 hours. (Testing atleast one sample from a
good and bad drives).

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
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
