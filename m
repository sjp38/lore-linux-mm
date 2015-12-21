Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f44.google.com (mail-lf0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 10A1D6B0007
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:33:28 -0500 (EST)
Received: by mail-lf0-f44.google.com with SMTP id l133so114891756lfd.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 09:33:28 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id vq10si18887934lbb.180.2015.12.21.09.33.26
        for <linux-mm@kvack.org>;
        Mon, 21 Dec 2015 09:33:26 -0800 (PST)
Date: Mon, 21 Dec 2015 18:33:10 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Message-ID: <20151221173310.GD21582@pd.tnic>
References: <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <20151215131135.GE25973@pd.tnic>
 <CAPcyv4gMr6LcZqjxt6fAoEiaa0AzcgMxnp2+V=TWJ1eHb6nC3A@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F8566E@ORSMSX114.amr.corp.intel.com>
 <CAPcyv4icSmdnvQhsdzfP3uZYXJ2vsjrZxMQjSghNOt19u++o7g@mail.gmail.com>
 <CAPcyv4gMku=rAczAz2b4PaW6qwm9LAVU8BG3hcT_A4QMAkZfbA@mail.gmail.com>
 <20151215183924.GJ25973@pd.tnic>
 <94D0CD8314A33A4D9D801C0FE68B40295BE9F290@G4W3202.americas.hpqcorp.net>
 <20151215192837.GL25973@pd.tnic>
 <94D0CD8314A33A4D9D801C0FE68B40295BE9F3D5@G4W3202.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <94D0CD8314A33A4D9D801C0FE68B40295BE9F3D5@G4W3202.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>, "Luck, Tony" <tony.luck@intel.com>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>

On Tue, Dec 15, 2015 at 08:25:37PM +0000, Elliott, Robert (Persistent Memory) wrote:
> This isn't exactly what you're looking for, but here is 
> an example of fio doing reads from pmem devices (reading
> from NVDIMMs, writing to DIMMs) with various transfer
> sizes.

... and "fio" is?

> At 256 KiB, all the main memory buffers fit in the CPU
> caches, so no write traffic appears on DDR (just the reads
> from the NVDIMMs).  At 1 MiB, the data spills out of the
> caches, and writes to the DIMMs end up on DDR.
> 
> Although DDR is busier, fio gets a lot less work done:
> * 256 KiB: 90 GiB/s by fio
> *   1 MiB: 49 GiB/s by fio

Yeah, I don't think that answers the question I had: whether REP; MOVSB
is faster/better than using non-temporal stores. But you say that
already above.

Also, if you do non-temporal stores then you're expected to have *more*
memory controller and DIMM traffic as you're pushing everything out
through the WCC.

What would need to be measured instead is, IMO, two things:

* compare NTI vs REP; MOVSB data movement to see the differences in
performance aspects

* run a benchmark (no idea which one) which would measure the positive
impact of the NTI versions which do not pollute the cache and thus do
not hurt other workloads' working set being pushed out of the cache.

Also, we don't really know (at least I don't) what REP; MOVSB
improvements hide behind those enhanced fast string optimizations.
It could be that microcode is doing some aggregation into cachelines
and doing much bigger writes which could compensate for the cache
pollution.

Questions over questions...

> We could try modifying pmem to use its own non-temporal
> memcpy functions (I've posted experimental patches
> before that did this) to see if that transition point
> shifts.  We can also watch the CPU cache statistics
> while running.
> 
> Here are statistics from Intel's pcm-memory.x 
> (pardon the wide formatting):
> 
> 256 KiB
> =======
> pmem0: (groupid=0, jobs=40): err= 0: pid=20867: Tue Nov 24 18:20:08 2015
>   read : io=5219.1GB, bw=89079MB/s, iops=356314, runt= 60006msec
>   cpu          : usr=1.74%, sys=96.16%, ctx=49576, majf=0, minf=21997
> 
> Run status group 0 (all jobs):
>    READ: io=5219.1GB, aggrb=89079MB/s, minb=89079MB/s, maxb=89079MB/s, mint=60006msec, maxt=60006msec
> 
> |---------------------------------------||---------------------------------------|
> |--             Socket  0             --||--             Socket  1             --|
> |---------------------------------------||---------------------------------------|
> |--     Memory Channel Monitoring     --||--     Memory Channel Monitoring     --|
> |---------------------------------------||---------------------------------------|
> |-- Mem Ch  0: Reads (MB/s): 11778.11 --||-- Mem Ch  0: Reads (MB/s): 11743.99 --|
> |--            Writes(MB/s):    51.83 --||--            Writes(MB/s):    43.25 --|
> |-- Mem Ch  1: Reads (MB/s): 11779.90 --||-- Mem Ch  1: Reads (MB/s): 11736.06 --|
> |--            Writes(MB/s):    48.73 --||--            Writes(MB/s):    37.86 --|
> |-- Mem Ch  4: Reads (MB/s): 11784.79 --||-- Mem Ch  4: Reads (MB/s): 11746.94 --|
> |--            Writes(MB/s):    52.90 --||--            Writes(MB/s):    43.73 --|
> |-- Mem Ch  5: Reads (MB/s): 11778.48 --||-- Mem Ch  5: Reads (MB/s): 11741.55 --|
> |--            Writes(MB/s):    47.62 --||--            Writes(MB/s):    37.80 --|
> |-- NODE 0 Mem Read (MB/s) : 47121.27 --||-- NODE 1 Mem Read (MB/s) : 46968.53 --|
> |-- NODE 0 Mem Write(MB/s) :   201.08 --||-- NODE 1 Mem Write(MB/s) :   162.65 --|
> |-- NODE 0 P. Write (T/s):     190927 --||-- NODE 1 P. Write (T/s):     182961 --|

What does T/s mean?

> |-- NODE 0 Memory (MB/s):    47322.36 --||-- NODE 1 Memory (MB/s):    47131.17 --|
> |---------------------------------------||---------------------------------------|
> |---------------------------------------||---------------------------------------|
> |--                   System Read Throughput(MB/s):  94089.80                  --|
> |--                  System Write Throughput(MB/s):    363.73                  --|
> |--                 System Memory Throughput(MB/s):  94453.52                  --|
> |---------------------------------------||---------------------------------------|
> 
> 1 MiB
> =====
> |---------------------------------------||---------------------------------------|
> |--             Socket  0             --||--             Socket  1             --|
> |---------------------------------------||---------------------------------------|
> |--     Memory Channel Monitoring     --||--     Memory Channel Monitoring     --|
> |---------------------------------------||---------------------------------------|
> |-- Mem Ch  0: Reads (MB/s):  7227.83 --||-- Mem Ch  0: Reads (MB/s):  7047.45 --|
> |--            Writes(MB/s):  5894.47 --||--            Writes(MB/s):  6010.66 --|
> |-- Mem Ch  1: Reads (MB/s):  7229.32 --||-- Mem Ch  1: Reads (MB/s):  7041.79 --|
> |--            Writes(MB/s):  5891.38 --||--            Writes(MB/s):  6003.19 --|
> |-- Mem Ch  4: Reads (MB/s):  7230.70 --||-- Mem Ch  4: Reads (MB/s):  7052.44 --|
> |--            Writes(MB/s):  5888.63 --||--            Writes(MB/s):  6012.49 --|
> |-- Mem Ch  5: Reads (MB/s):  7229.16 --||-- Mem Ch  5: Reads (MB/s):  7047.19 --|
> |--            Writes(MB/s):  5882.45 --||--            Writes(MB/s):  6008.11 --|
> |-- NODE 0 Mem Read (MB/s) : 28917.01 --||-- NODE 1 Mem Read (MB/s) : 28188.87 --|
> |-- NODE 0 Mem Write(MB/s) : 23556.93 --||-- NODE 1 Mem Write(MB/s) : 24034.46 --|
> |-- NODE 0 P. Write (T/s):     238713 --||-- NODE 1 P. Write (T/s):     228040 --|
> |-- NODE 0 Memory (MB/s):    52473.94 --||-- NODE 1 Memory (MB/s):    52223.33 --|
> |---------------------------------------||---------------------------------------|
> |---------------------------------------||---------------------------------------|
> |--                   System Read Throughput(MB/s):  57105.87                  --|
> |--                  System Write Throughput(MB/s):  47591.39                  --|
> |--                 System Memory Throughput(MB/s): 104697.27                  --|
> |---------------------------------------||---------------------------------------|

Looks to me like, because writes have increased, the read bandwidth has
dropped too, which makes sense.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
