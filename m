Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id NAA11590
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 13:30:51 -0700 (PDT)
Message-ID: <3D7D04EA.8BC7AF31@digeo.com>
Date: Mon, 09 Sep 2002 13:30:34 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Performance of Readv and the Cost of Revesemaps Under Heavy DB
 Workloads
References: <OFB460955F.DB2A4AF7-ON85256C2F.006CDBB2@pok.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Wong <wpeter@us.ibm.com>
Cc: linux-mm@kvack.org, riel@nl.linux.org, akpm@zip.com.au, mjbligh@us.ibm.com, wli@holomorphy.com, dmccr@us.ibm.comgh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Peter Wong wrote:
> 
> All,
> 
>      I have measured a decision support workload using 2.4.17-based
> kernel, 2.5.31-based kernel, and 2.5.32-based kernel, all of which
> use the readv patch made available by Janet Morgan. Janet's patch is
> also included in Andrew Morton's mm patch, which can be found at
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.32/2.5.32-mm2/.
> I got the following results.
> 
> ---------------------------------------------------------------
> Database Size: 100 GB
> 
> 2417RV:    2.4.17 (kernel.org)
>            + lse04-rc1.diffs
>              - bounce patch by Jens Axboe
>              - io_reqeust_lock patch by Jonathan Lahr
>              - rawvary patch by Badari Pulavarty
>              - readv patches by Janet Morgan
>            + TASK_UNMAPPED_BASE = 0x10000000
>            + PAGE_OFFSET        = 0xD0000000
> 
> 2531RV:    2.5.31 (kernel.org)
>            + readv patch from Janet Morgan
>            + TASK_UNMAPPED_BASE = 0x10000000
>            + PAGE_OFFSET        = 0xC0000000
> 
> 2532RV:    2.5.32 (kernel.org)
>            + mm-2 patch from Andrew Morton which
>              includes Janet's readv patch
>            + TASK_UNMAPPED_BASE = 0x10000000
>            + PAGE_OFFSET        = 0xC0000000
> 
>      Based upon the throughput rate,
>           2531RV is 99.8% of 2417RV;
>           2532RV is  100% of 2417RV.

Well that's a bit sad.  I assume the test was IO-bound?  Did
you measure the CPU utilisation for the run as well?

What is your overall take on the performance of 2.5 with respect
to 2.4 and, indeed, other operating systems?

>       There are 110 prefetchers for the runs, and ~2 GB of shared
> memory space used by the database, i.e., ~500,000 pages. With Andrew's
> mm patch, the maximum number of reversemaps reaches 43.7 millions. That
> is, each page is used by ~87 processes. With 8 bytes per reversemap,
> it costs ~350MB of the kernel memory, which is quite significant. Note
> that the database system used forks processes and does not use
> pthreads.

Look in /proc/slabinfo to know the exact amount of memory which the
reversemaps are using.

You don't mention whether you're using CONFIG_HIGHPTE.  Probably
not; I think it was broken in that kernel.

- CONFIG_HIGHPTE will reduce ZONE_NORMAL pressure by moving pagetables
  into highmem.

- CONFIG_HIGHPTE+CONFIG_HIGHMEM64G will not be as favourable, because
  struct page gains 4 bytes and the reverse mapping objects double
  in size.

If your machine has more than 4G (does it?) then you'll need
CONFIG_HIGHMEM64G=y and CONFIG_HIGHPTE=y.

Please, God: don't make us put pte_chains in highmem as well :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
