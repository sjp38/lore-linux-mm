Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 234C26B0269
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:29:19 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id c7-v6so10881224iod.1
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:29:19 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 12-v6sor10767954itm.13.2018.11.05.08.29.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 08:29:17 -0800 (PST)
Subject: Re: Creating compressed backing_store as swapfile
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
 <20181105155815.i654i5ctmfpqhggj@angband.pl>
 <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
 <42594.1541434463@turing-police.cc.vt.edu>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <6a1f57b6-503c-48a2-689b-3c321cd6d29f@gmail.com>
Date: Mon, 5 Nov 2018 11:28:49 -0500
MIME-Version: 1.0
In-Reply-To: <42594.1541434463@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: valdis.kletnieks@vt.edu
Cc: Adam Borowski <kilobyte@angband.pl>, Pintu Agarwal <pintu.ping@gmail.com>, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

On 11/5/2018 11:14 AM, valdis.kletnieks@vt.edu wrote:
> On Mon, 05 Nov 2018 11:07:12 -0500, "Austin S. Hemmelgarn" said:
> 
>> Performance isn't _too_ bad for the BTRFS case though (I've actually
>> tested this before), just make sure you disable direct I/O mode on the
>> loop device, otherwise you run the risk of data corruption.
> 
> Did you test that for random-access. or just sequential read/write?
> (Also, see the note in my other mail regarding doing a random-access
> write to the middle of the file...)
> 
Actual swap usage.  About 16 months ago, I had been running a couple of 
Intel NUC5PPYH boxes (Pentium N3700 CPU's, 4GB of DDR3-1333 RAM) for 
some network prototyping.  On both, I had swap set up to use a file on 
BTRFS via a loop device, and I made a point to test both with LZ4 inline 
compression and without any compression, and saw negligible performance 
differences (less than 1% in most cases).  It was, of course, 
significantly worse than running on ext4, but on a system that's so 
resource constrained that both storage and memory are at a premium to 
this degree, the performance hit is probably going to be worth it.

Also, it's probably worth noting that BTRFS doesn't need to decompress 
the entire file to read or write blocks in the middle, it splits the 
file into 128k blocks and compresses each of those independent of the 
others, so it can just decompress the 128k block that holds the actual 
block that's needed.
