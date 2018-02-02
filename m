Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C86FD6B0008
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 12:00:49 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id a15so5011833qka.18
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 09:00:49 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g24si2507334qte.120.2018.02.02.09.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 09:00:48 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w12H0Y6k036046
	for <linux-mm@kvack.org>; Fri, 2 Feb 2018 12:00:47 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fvqty45n6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Feb 2018 12:00:46 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 2 Feb 2018 17:00:43 -0000
Subject: Re: [RFC PATCH v1 12/13] mm: split up release_pages into non-sentinel
 and sentinel passes
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
 <20180131230413.27653-13-daniel.m.jordan@oracle.com>
 <3287f5ca-ab17-6437-c0fd-b867d90f8c1f@linux.vnet.ibm.com>
Date: Fri, 2 Feb 2018 18:00:38 +0100
MIME-Version: 1.0
In-Reply-To: <3287f5ca-ab17-6437-c0fd-b867d90f8c1f@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <8a56da6b-8a47-3dc9-9b01-eb92be9fd828@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: daniel.m.jordan@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

On 02/02/2018 15:40, Laurent Dufour wrote:
> 
> 
> On 01/02/2018 00:04, daniel.m.jordan@oracle.com wrote:
>> A common case in release_pages is for the 'pages' list to be in roughly
>> the same order as they are in their LRU.  With LRU batch locking, when a
>> sentinel page is removed, an adjacent non-sentinel page must be promoted
>> to a sentinel page to follow the locking scheme.  So we can get behavior
>> where nearly every page in the 'pages' array is treated as a sentinel
>> page, hurting the scalability of this approach.
>>
>> To address this, split up release_pages into non-sentinel and sentinel
>> passes so that the non-sentinel pages can be locked with an LRU batch
>> lock before the sentinel pages are removed.
>>
>> For the prototype, just use a bitmap and a temporary outer loop to
>> implement this.
>>
>> Performance numbers from a single microbenchmark at this point in the
>> series are included in the next patch.
>>
>> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
>> ---
>>  mm/swap.c | 20 +++++++++++++++++++-
>>  1 file changed, 19 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/swap.c b/mm/swap.c
>> index fae766e035a4..a302224293ad 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -731,6 +731,7 @@ void lru_add_drain_all(void)
>>  	put_online_cpus();
>>  }
>>
>> +#define LRU_BITMAP_SIZE	512
>>  /**
>>   * release_pages - batched put_page()
>>   * @pages: array of pages to release
>> @@ -742,16 +743,32 @@ void lru_add_drain_all(void)
>>   */
>>  void release_pages(struct page **pages, int nr)
>>  {
>> -	int i;
>> +	int h, i;
>>  	LIST_HEAD(pages_to_free);
>>  	struct pglist_data *locked_pgdat = NULL;
>>  	spinlock_t *locked_lru_batch = NULL;
>>  	struct lruvec *lruvec;
>>  	unsigned long uninitialized_var(flags);
>> +	DECLARE_BITMAP(lru_bitmap, LRU_BITMAP_SIZE);
>> +
>> +	VM_BUG_ON(nr > LRU_BITMAP_SIZE);
> 
> While running your series rebased on v4.15-mmotm-2018-01-31-16-51, I'm
> hitting this VM_BUG sometimes on a ppc64 system where page size is set to 64K.

I can't see any link between nr and LRU_BITMAP_SIZE, caller may pass a
larger list of pages which is not relative to the LRU list.

To move forward seeing the benefit of this series with the SPF one, I
declared the bit map based on nr. This is still not a valid option but this
at least allows to process all the passed pages.

> In my case, nr=537 while LRU_BITMAP_SIZE is 512. Here is the stack trace
> displayed :
> 
> kernel BUG at /local/laurent/work/glinux/mm/swap.c:728!
> Oops: Exception in kernel mode, sig: 5 [#1]
> LE SMP NR_CPUS=2048 NUMA pSeries
> Modules linked in: pseries_rng rng_core vmx_crypto virtio_balloon ip_tables
> x_tables autofs4 virtio_net virtio_blk virtio_pci virtio_ring virtio
> CPU: 41 PID: 3485 Comm: cc1 Not tainted 4.15.0-mm1-lru+ #2
> NIP:  c0000000002b0784 LR: c0000000002b0780 CTR: c0000000007bab20
> REGS: c0000005e126b740 TRAP: 0700   Not tainted  (4.15.0-mm1-lru+)
> MSR:  8000000000029033 <SF,EE,ME,IR,DR,RI,LE>  CR: 28002422  XER: 20000000
> CFAR: c000000000192ae4 SOFTE: 0
> GPR00: c0000000002b0780 c0000005e126b9c0 c00000000103c100 000000000000001c
> GPR04: c0000005ffc4ce38 c0000005ffc63d00 0000000000000000 0000000000000001
> GPR08: 0000000000000007 c000000000ec3a4c 00000005fed90000 0000000000000000
> GPR12: 0000000000002200 c00000000fd8cd00 0000000000000000 0000000000000000
> GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> GPR20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> GPR24: c0000005e11ab980 0000000000000000 0000000000000000 c0000005e126ba60
> GPR28: 0000000000000219 c0000005e126bc40 0000000000000000 c0000005ec5f0000
> NIP [c0000000002b0784] release_pages+0x864/0x880
> LR [c0000000002b0780] release_pages+0x860/0x880
> Call Trace:
> [c0000005e126b9c0] [c0000000002b0780] release_pages+0x860/0x880 (unreliable)
> [c0000005e126bb30] [c00000000031da3c] free_pages_and_swap_cache+0x11c/0x150
> [c0000005e126bb80] [c0000000002ef5f8] tlb_flush_mmu_free+0x68/0xa0
> [c0000005e126bbc0] [c0000000002f1568] arch_tlb_finish_mmu+0x58/0xf0
> [c0000005e126bbf0] [c0000000002f19d4] tlb_finish_mmu+0x34/0x60
> [c0000005e126bc20] [c0000000003031e8] exit_mmap+0xd8/0x1d0
> [c0000005e126bce0] [c0000000000f3188] mmput+0x78/0x160
> [c0000005e126bd10] [c0000000000ff568] do_exit+0x348/0xd00
> [c0000005e126bdd0] [c0000000000fffd8] do_group_exit+0x58/0xd0
> [c0000005e126be10] [c00000000010006c] SyS_exit_group+0x1c/0x20
> [c0000005e126be30] [c00000000000ba60] system_call+0x58/0x6c
> Instruction dump:
> 3949ffff 4bfffdc8 3c62ffce 38a00200 f9c100e0 f9e100e8 386345e8 fa0100f0
> fa2100f8 fa410100 4bee2329 60000000 <0fe00000> 3b400001 4bfff868 7d5d5378
> ---[ end trace 55b1651f9d92f14f ]---
> 
>>
>> +	bitmap_zero(lru_bitmap, nr);
>> +
>> +	for (h = 0; h < 2; h++) {
>>  	for (i = 0; i < nr; i++) {
>>  		struct page *page = pages[i];
>>
>> +		if (h == 0) {
>> +			if (PageLRU(page) && page->lru_sentinel) {
>> +				bitmap_set(lru_bitmap, i, 1);
>> +				continue;
>> +			}
>> +		} else {
>> +			if (!test_bit(i, lru_bitmap))
>> +				continue;
>> +		}
>> +
>>  		if (is_huge_zero_page(page))
>>  			continue;
>>
>> @@ -798,6 +815,7 @@ void release_pages(struct page **pages, int nr)
>>
>>  		list_add(&page->lru, &pages_to_free);
>>  	}
>> +	}
>>  	if (locked_lru_batch) {
>>  		lru_batch_unlock(NULL, &locked_lru_batch, &locked_pgdat,
>>  				 &flags);
>>
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
