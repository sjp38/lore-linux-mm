Subject: Re: Performance of Readv and the Cost of Revesemaps Under Heavy DB
  Workloads
Message-ID: <OF0C04A218.48BF8D2A-ON85256C2F.007168ED@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Tue, 10 Sep 2002 13:25:09 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: linux-mm@kvack.org, riel@nl.linux.org, akpm@zip.com.au, mjbligh@us.ibm.com, wli@holomorphy.com, dmccr@us.ibm.comgh@us.ibm.com, Bill Hartner <bhartner@us.ibm.com>, Troy C Wilson <wilsont@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>Peter Wong wrote:
>>
>> All,
>>
>>      I have measured a decision support workload using 2.4.17-based
>> kernel, 2.5.31-based kernel, and 2.5.32-based kernel, all of which
>> use the readv patch made available by Janet Morgan. Janet's patch is
>> also included in Andrew Morton's mm patch, which can be found at
>> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.32/2.5.32-mm2/.
>> I got the following results.
>>
>> ---------------------------------------------------------------
>> Database Size: 100 GB
>>
>> 2417RV:    2.4.17 (kernel.org)
>>            + lse04-rc1.diffs
>>              - bounce patch by Jens Axboe
>>              - io_reqeust_lock patch by Jonathan Lahr
>>              - rawvary patch by Badari Pulavarty
>>              - readv patches by Janet Morgan
>>            + TASK_UNMAPPED_BASE = 0x10000000
>>            + PAGE_OFFSET        = 0xD0000000
>>
>> 2531RV:    2.5.31 (kernel.org)
>>            + readv patch from Janet Morgan
>>            + TASK_UNMAPPED_BASE = 0x10000000
>>            + PAGE_OFFSET        = 0xC0000000
>>
>> 2532RV:    2.5.32 (kernel.org)
>>            + mm-2 patch from Andrew Morton which
>>              includes Janet's readv patch
>>            + TASK_UNMAPPED_BASE = 0x10000000
>>            + PAGE_OFFSET        = 0xC0000000
>>
>>      Based upon the throughput rate,
>>           2531RV is 99.8% of 2417RV;
>>           2532RV is  100% of 2417RV.
>
>Well that's a bit sad.  I assume the test was IO-bound?  Did
>you measure the CPU utilisation for the run as well?
>

The CPU utilization among these 3 kernels is similar:

                        User(%)     System(%)   Idle (%)

              2417RV         66             9         25
              2531RV         67             9         24
              2632RV         67             7         26

>What is your overall take on the performance of 2.5 with respect
>to 2.4 and, indeed, other operating systems?

Based upon the measurements of readv on this decision support
workload that I got so far, the 2.5 performance is about the
same as the 2.4 performance. I reported earlier that 2.5
performs better than 2.4 by 8% while using "read" for this
workload.

>
>>       There are 110 prefetchers for the runs, and ~2 GB of shared
>> memory space used by the database, i.e., ~500,000 pages. With Andrew's
>> mm patch, the maximum number of reversemaps reaches 43.7 millions. That
>> is, each page is used by ~87 processes. With 8 bytes per reversemap,
>> it costs ~350MB of the kernel memory, which is quite significant. Note
>> that the database system used forks processes and does not use
>> pthreads.
>
>Look in /proc/slabinfo to know the exact amount of memory which the
>reversemaps are using.
>

The maximum number of slabs used for pte_chains as observed in
/proc/slabinfo is as follows:

pte_chain         1633008 6464730     32 45175 57210    1 :  252  126
                                               ^^^^^    ^

     Memory consumed = 57210 * 4 KB = ~223 MB

David McCracken pointed out that you have done some optimization on
the pte_chain structure. It is no longer the case that every
reversemap costs 8 bytes. You allocate 32 bytes for each pte_chain,
4 bytes for the next pointer, and 28 bytes for 7 PTE pointers with
4 bytes each. Thus, if the pte_chain is fully occupied, each
reversemap costs ~4.7 bytes.

>You don't mention whether you're using CONFIG_HIGHPTE.  Probably
>not; I think it was broken in that kernel.
>
>- CONFIG_HIGHPTE will reduce ZONE_NORMAL pressure by moving pagetables
>  into highmem.
>
>- CONFIG_HIGHPTE+CONFIG_HIGHMEM64G will not be as favourable, because
>  struct page gains 4 bytes and the reverse mapping objects double
>  in size.
>
>If your machine has more than 4G (does it?) then you'll need
>CONFIG_HIGHMEM64G=y and CONFIG_HIGHPTE=y.
>
>Please, God: don't make us put pte_chains in highmem as well :(
>

My machine has 4GB RAM and I did not use CONFIG_HIGHPTE.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
