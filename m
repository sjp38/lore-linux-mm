Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 340B86B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 03:56:20 -0400 (EDT)
Message-ID: <4BCD5E47.4020507@gmx.at>
Date: Tue, 20 Apr 2010 09:56:55 +0200
From: Walter Haidinger <walter.haidinger@gmx.at>
MIME-Version: 1.0
Subject: Re: [Bugme-new] [Bug 15783] New: slow dd and multiple "page allocation
 failure" messages
References: <bug-15783-10286@https.bugzilla.kernel.org/> <20100419140948.0b748c69.akpm@linux-foundation.org>
In-Reply-To: <20100419140948.0b748c69.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>

Am 19.04.2010 23:09, schrieb Andrew Morton:
> 
> (switched to email.  Please respond via emailed reply-to-all, not
> via the bugzilla web interface).

ok.

> Sigh.  This shouldn't happen.
> 
> I'm going to go ahead and assume that some earlier kernels didn't
> do this :(

No, I don't _think_ so. Problem is, I only noticed this when zeroing out
the device. Haven't done this recently with earlier kernels. Besides,
as reported, not all write operations are slow.

> Is the writeout to /dev/sde1 slow right from the start, or does it 
> start out fast and later slow down?

It seems to me that write speed does not change very much, but the
actual speed varies. One time it's just 10 MiB/s, another time about 30.
But for a couple of tests writes, speed is pretty stable.

Also, only writing directly to the device seems to be slow.
Perhaps that's why is hard to notice.

e.g.: when /dev/sde1 is mounted as ext3 fs:
Copying a 5 GiB file takes about 50s,
mbuffer </dev/zero >/mnt1/foo1 writes with >100 MiB/s,
dd if=/dev/zero of=/mnt1/foo2 manages >75 MiB/s.

After unmounting and writing directly from /dev/zero to /dev/sde1:
mbuffer writes about 40 MiB/s and dd less than 30.

But then badblocks -svw -t 0x00 /dev/sde1 writes about 120 MiB/s.
Btw, dd if=/dev/zero of=/dev/null runs with >500 MiB/s.

Needless to say, I'm confused by the numbers...

> `dd' isn't very efficient without the `bs' option - it reads and
> writes in 512-byte chunks.   But that shouldn't be causing these
> problems.

Tried mbuffer instead. Shows similar results, only a bit faster.
Still, even if dd is inefficient, it is way slower than expected.

If you want me to test anything, please let me know.

Walter

PS: The short tests above triggered no "page allocation failures"
    (vm.vfs_cache_pressure = 1000).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
