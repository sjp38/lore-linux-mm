Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id A334C6B006E
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 10:02:19 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 14 Jan 2013 10:02:14 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 5A41B38C801C
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 10:02:13 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0EF2Adi216772
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 10:02:11 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0EF0wxN011205
	for <linux-mm@kvack.org>; Mon, 14 Jan 2013 08:00:59 -0700
Message-ID: <50F41D9D.1000403@linux.vnet.ibm.com>
Date: Mon, 14 Jan 2013 07:00:45 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
References: <201301120331.r0C3VxXc016220@como.maths.usyd.edu.au>
In-Reply-To: <201301120331.r0C3VxXc016220@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: linux-mm@kvack.org, 695182@bugs.debian.org, linux-kernel@vger.kernel.org

On 01/11/2013 07:31 PM, paul.szabo@sydney.edu.au wrote:
> Seems that any i386 PAE machine will go OOM just by running a few
> processes. To reproduce:
>   sh -c 'n=0; while [ $n -lt 19999 ]; do sleep 600 & ((n=n+1)); done'
> My machine has 64GB RAM. With previous OOM episodes, it seemed that
> running (booting) it with mem=32G might avoid OOM; but an OOM was
> obtained just the same, and also with lower memory:
>   Memory    sleeps to OOM       free shows total
>   (mem=64G)  5300               64447796
>   mem=32G   10200               31155512
>   mem=16G   13400               14509364
>   mem=8G    14200               6186296
>   mem=6G    15200               4105532
>   mem=4G    16400               2041364
> The machine does not run out of highmem, nor does it use any swap.

I think what you're seeing here is that, as the amount of total memory
increases, the amount of lowmem available _decreases_ due to inflation
of mem_map[] (and a few other more minor things).  The number of sleeps
you can do is bound by the number of processes, as you noticed from
ulimit.  Creating processes that don't use much memory eats a relatively
large amount of low memory.

This is a sad (and counterintuitive) fact: more RAM actually *CREATES*
RAM bottlenecks on 32-bit systems.

> On my large machine, 'free' fails to show about 2GB memory, e.g. with
> mem=16G it shows:
> 
> root@zeno:~# free -l
>              total       used       free     shared    buffers     cached
> Mem:      14509364     435440   14073924          0       4068     111328
> Low:        769044     120232     648812
> High:     13740320     315208   13425112
> -/+ buffers/cache:     320044   14189320
> Swap:    134217724          0  134217724

You probably have a memory hole.  mem=16G means "give me all the memory
below the physical address at 16GB".  It does *NOT* mean, "give me
enough memory such that 'free' will show ~16G available."  If you have a
1.5GB hole below 16GB, and you do mem=16G, you'll end up with ~14.5GB
available.

The e820 map (during early boot in dmesg) or /proc/iomem will let you
locate your memory holes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
