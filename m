Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 762016B0006
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 11:45:25 -0500 (EST)
Message-ID: <5127A0A3.6040904@ubuntu.com>
Date: Fri, 22 Feb 2013 11:45:23 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
References: <20121215005448.GA7698@dcvr.yhbt.net> <20121216024520.GH9806@dastard>
In-Reply-To: <20121216024520.GH9806@dastard>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Eric Wong <normalperson@yhbt.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/15/2012 9:45 PM, Dave Chinner wrote:
> On Sat, Dec 15, 2012 at 12:54:48AM +0000, Eric Wong wrote:
>> Applications streaming large files may want to reduce disk
>> spinups and I/O latency by performing large amounts of readahead
>> up front. Applications also tend to read files soon after opening
>> them, so waiting on a slow fadvise may cause unpleasant latency
>> when the application starts reading the file.
>> 
>> As a userspace hacker, I'm sometimes tempted to create a
>> background thread in my app to run readahead().  However, I
>> believe doing this in the kernel will make life easier for other
>> userspace hackers.
>> 
>> Since fadvise makes no guarantees about when (or even if)
>> readahead is performed, this change should not hurt existing
>> applications.
>> 
>> "strace -T" timing on an uncached, one gigabyte file:
>> 
>> Before: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <2.484832> 
>> After: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <0.000061>
> 
> You've basically asked fadvise() to readahead the entire file if
> it can. That means it is likely to issue enough readahead to fill
> the IO queue, and that's where all the latency is coming from. If
> all you are trying to do is reduce the latency of the first read,
> then only readahead the initial range that you are going to need to
> read...

It shouldn't take 2 seconds to queue up some async reads.  Are you
using ext3?  The blocks have to be mapped in order to queue the reads,
and without ext4 extents, this means the indirect blocks have to be
read and can cause fadvise to block.


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJRJ6CjAAoJEJrBOlT6nu759s8IAKmIyZYDk1JSRP6oJaGaGZ/r
aZCBH52wTPH8DaqFGe+62L8lyIQ5hD15Y+zTuaWh+fJ7C1k/lU8F/QbKCG2D+xCB
vfLF0WRx63fWLLg8xZTRU1x8X6sG+Byp+UYWNspTDrL15ChlaqqGGmwLNo4JxLa8
+AGQVt1WMU3TitD9CUMUfYFWGUQsMR0gWeJkJnjHiEZ7VoGzft2PTlnvElzIk76u
3cmwfoKHrnXzi50rPtP2gonRjMwd8VY859qOk0zlHoMDMcXklAWeIN9PEUIMx+VP
fMnBm6u48cKXPYGvQrGMOdjxlt7k4LhGDZxIlvmwNHWUSaifmkJ8oBMvfbAYtUA=
=G5rE
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
