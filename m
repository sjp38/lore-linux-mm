Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA23423
	for <linux-mm@kvack.org>; Mon, 7 Oct 2002 23:46:00 -0700 (PDT)
Message-ID: <3DA27F28.C60D201D@digeo.com>
Date: Mon, 07 Oct 2002 23:46:00 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.40-mm1
References: <3D996BA3.24E8B007@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mala Anand <manand@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ...
> - Included a patch from Mala Anand which _should_ speed up kernel<->userspace
>   memory copies for Intel ia32 hardware.  But I can't measure any difference
>   with poorly-aligned pagecache copies.
> 

Well Mala, I have to take that back.  I must have forgotten to
turn on my computer or brain or something.   Your patch kicks
butt.

In this test I timed how long it took to read a fully-cached
1 gigabyte file into an 8192-byte userspace buffer.  The alignment
of the user buffer was incremented by one byte between runs.

for i in $(seq 0 32)
do
	time time-read -a $i -b 8192 -h 8192 foo 
done

time-read.c is in http://www.zip.com.au/~akpm/linux/patches/2.5/ext3-tools.tar.gz

The CPU is "Pentium III (Katmai)"

All times are in seconds:


User buffer	2.5.41		2.5.41+		2.5.41+
				patch		patch++

0x804c000	4.373		4.387		6.063
0x804c001	10.024		6.410
0x804c002	10.002		6.411
0x804c003	10.013		6.408
0x804c004	10.105		6.343
0x804c005	10.184		6.394
0x804c006	10.179		6.398
0x804c007	10.185		6.408
0x804c008	9.725		9.724		6.347
0x804c009	9.780		6.436
0x804c00a	9.779		6.421
0x804c00b	9.778		6.433
0x804c00c	9.723		6.402
0x804c00d	9.790		6.382
0x804c00e	9.790		6.381
0x804c00f	9.785		6.380
0x804c010	9.727		9.723		6.277
0x804c011	9.779		6.360
0x804c012	9.783		6.345
0x804c013	9.786		6.341
0x804c014	9.772		6.133
0x804c015	9.919		6.327
0x804c016	9.920		6.319
0x804c017	9.918		6.319
0x804c018	9.846		9.857		6.372
0x804c019	10.060		6.443
0x804c01a	10.049		6.436
0x804c01b	10.041		6.432
0x804c01c	9.931		6.356
0x804c01d	10.013		6.432
0x804c01e	10.020		6.425
0x804c01f	10.016		6.444
0x804c020	4.442		4.423		6.380

So the patch is a 30% win at all alignments except for 32-byte-aligned
destination addresses.

Now, in the patch++ I modified things so we use the copy_user_int()
function for _all_ alignments.  Look at the 0x804c008 alignment.
We sped up the copies by 30% by using copy_user_int() instead of
rep;movsl.

This is important, because glibc malloc() returns addresses which
are N+8 aligned.  I would expect that this alignment is common.

So.  Patch is a huge win as-is.  For the PIII it looks like we need
to enable it at all alignments except mod32.  And we need to test
with aligned dest, unaligned source.

Can you please do some P4 testing?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
