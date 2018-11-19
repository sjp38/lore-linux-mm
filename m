Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21C556B1BFB
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 13:57:54 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id x82so5452121ita.9
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 10:57:54 -0800 (PST)
Received: from p3plsmtpa11-05.prod.phx3.secureserver.net (p3plsmtpa11-05.prod.phx3.secureserver.net. [68.178.252.106])
        by mx.google.com with ESMTPS id n6si2777697ioc.84.2018.11.19.10.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 10:57:52 -0800 (PST)
Subject: Re: [PATCH v2 0/6] RFC: gup+dma: tracking dma-pinned pages
References: <20181110085041.10071-1-jhubbard@nvidia.com>
From: Tom Talpey <tom@talpey.com>
Message-ID: <942cb823-9b18-69e7-84aa-557a68f9d7e9@talpey.com>
Date: Mon, 19 Nov 2018 13:57:51 -0500
MIME-Version: 1.0
In-Reply-To: <20181110085041.10071-1-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: john.hubbard@gmail.com, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>

John, thanks for the discussion at LPC. One of the concerns we
raised however was the performance test. The numbers below are
rather obviously tainted. I think we need to get a better baseline
before concluding anything...

Here's my main concern:

On 11/10/2018 3:50 AM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
>...
> ------------------------------------------------------
> WITHOUT the patch:
> ------------------------------------------------------
> reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
> fio-3.3
> Starting 1 process
> Jobs: 1 (f=1): [R(1)][100.0%][r=55.5MiB/s,w=0KiB/s][r=14.2k,w=0 IOPS][eta 00m:00s]
> reader: (groupid=0, jobs=1): err= 0: pid=1750: Tue Nov  6 20:18:06 2018
>     read: IOPS=13.9k, BW=54.4MiB/s (57.0MB/s)(1024MiB/18826msec)

~14000 4KB read IOPS is really, really low for an NVMe disk.

>    cpu          : usr=2.39%, sys=95.30%, ctx=669, majf=0, minf=72

CPU is obviously the limiting factor. At these IOPS, it should be far
less.
> ------------------------------------------------------
> OR, here's a better run WITH the patch applied, and you can see that this is nearly as good
> as the "without" case:
> ------------------------------------------------------
> 
> reader: (g=0): rw=read, bs=(R) 4096B-4096B, (W) 4096B-4096B, (T) 4096B-4096B, ioengine=libaio, iodepth=64
> fio-3.3
> Starting 1 process
> Jobs: 1 (f=1): [R(1)][100.0%][r=53.2MiB/s,w=0KiB/s][r=13.6k,w=0 IOPS][eta 00m:00s]
> reader: (groupid=0, jobs=1): err= 0: pid=2521: Tue Nov  6 20:01:33 2018
>     read: IOPS=13.4k, BW=52.5MiB/s (55.1MB/s)(1024MiB/19499msec)

Similar low IOPS.

>    cpu          : usr=3.47%, sys=94.61%, ctx=370, majf=0, minf=73

Similar CPU saturation.

>

I get nearly 400,000 4KB IOPS on my tiny desktop, which has a 25W
i7-7500 and a Samsung PM961 128GB NVMe (stock Bionic 4.15 kernel
and fio version 3.1). Even then, the CPU saturates, so it's not
necessarily a perfect test. I'd like to see your runs both get to
"max" IOPS, i.e. CPU < 100%, and compare the CPU numbers. This would
give the best comparison for making a decision.

Can you confirm what type of hardware you're running this test on?
CPU, memory speed and capacity, and NVMe device especially?

Tom.
