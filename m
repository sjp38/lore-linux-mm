Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D19AB6B00AE
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 21:23:10 -0500 (EST)
Received: by vws6 with SMTP id 6so202433vws.14
        for <linux-mm@kvack.org>; Thu, 04 Mar 2010 18:23:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201003050042.o250gsUC007947@alien.loup.net>
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
	 <201003041631.o24GVl51005720@alien.loup.net>
	 <f875e2fe1003041012m680ffc87i50099ed011526440@mail.gmail.com>
	 <201003050042.o250gsUC007947@alien.loup.net>
Date: Thu, 4 Mar 2010 21:23:09 -0500
Message-ID: <f875e2fe1003041823o507ecb36qfd7af7d27de7683d@mail.gmail.com>
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
From: s ponnusa <foosaa@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mike Hayward <hayward@loup.net>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 4, 2010 at 7:42 PM, Mike Hayward <hayward@loup.net> wrote:
> =A0> The write cache is turned off at the hdd level. I am using O_DIRECT
> =A0> mode with aligned buffers of the 4k page size. I have turned off the
> =A0> page cache and read ahead during read as well using the fadvise
> =A0> function.
> If O_DIRECT and no write cache, either the sector finally was
> remapped, or the successful return is very disturbing. =A0Doesn't matter
> what operating system, it should not silently corrupt with write cache
> off. =A0Test by writing nonzero random data on one of these 'retry'
> sectors. =A0Reread to see if data returned after successful write. =A0If
> so, you'll know it's just slow to remap.
>
> Because timeouts can take awhile, if you have many bad blocks I
> imagine this could be a very painful process :-) It's one thing to
> wipe a functioning drive, another to wipe a failed one. =A0If drive
> doesn't have a low level function to do it more quickly (cut out the
> long retries), after a couple of hours I'd give up on that, literally
> disassemble and destroy the platters. =A0It is probably faster and
> cheaper than spending a week trying to chew through the bad section.
> Keep in mind, zeroing the drive is not going to erase the data all
> that well anyway. =A0Might as well skip regions when finding a bad
> sequence and scrub as much of the rest as you can without getting hung
> up on 5% of the data, then mash it to bits or take a nasty magnet or
> some equally destructive thing to it!
>
> If it definitely isn't storing the data you write after it returns
> success (reread it to check), I'd definitely call that a write-read
> corruption, either in the kernel or in the drive. =A0If in kernel it
> should be fixed as that is seriously broken to silently ignore data
> corruption and I think we'd all like to trust the kernel if not the
> drive :-)
>
> Please let me know if you can prove data corruption. =A0I'm writing a
> sophisticated storage app and would like to know if kernel has such a
> defect. =A0My bet is it's just a drive that is slowly remapping.
>
> - Mike
>
Mike,

The data written through linux cannot be read back by any other means.
Does that prove any data corruption? I wrote a signature on to a bad
drive. (With all the before mentioned permutation and combinations).
The program returned 0 (zero) errors and said the data was
successfully written to all the sectors of the drive and it had taken
5 hrs (The sample size of the drive is 20 GB). And I tried to verify
it using another program on linux. It produced read errors across a
couple of million sectors after almost 13 hours of grinding the hdd.

I can understand the slow remapping process during the write
operations. But what if the drive has used up all the available
sectors for mapping and is slowly dying. The SMART data displays
thousands of seek, read, crc errors and still linux does not notify
the program which has asked it to write some data. ????

I don't know how one can handle the data integrity / protection with
it. The data might be just be surviving because of the personnel
vigilance (constant look out on SMART data / HDD health) and probably
due to existing redundancy options! :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
