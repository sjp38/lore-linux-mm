Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0169A6B0003
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:55:04 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r2-v6so11323194wro.21
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 07:55:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id u9-v6si515612wrr.132.2018.06.26.07.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 07:55:02 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w5QEs7Ft144943
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:55:00 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2jupnju34m-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 10:55:00 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Tue, 26 Jun 2018 08:54:59 -0600
Subject: Re: [powerpc/powervm]kernel BUG at mm/memory_hotplug.c:1864!
References: <6826dab0e4382380db8d11b047272bda@linux.vnet.ibm.com>
 <20180608112823.GA20395@techadventures.net>
 <3d1e7740df56ed35c8b56941acdb7079@linux.vnet.ibm.com>
 <20180608121553.GA20774@techadventures.net>
 <0aac625ee724d877b87c69bba5ac9a0e@linux.vnet.ibm.com>
 <605b4df2-4cf1-2dda-3661-68b78845f8ec@gmail.com>
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 26 Jun 2018 09:54:53 -0500
MIME-Version: 1.0
In-Reply-To: <605b4df2-4cf1-2dda-3661-68b78845f8ec@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <345785ef-5da2-b2e8-78b8-2391b54c6141@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, vrbagal1 <vrbagal1@linux.vnet.ibm.com>, Oscar Salvador <osalvador@techadventures.net>
Cc: sachinp <sachinp@linux.vnet.ibm.com>, Linuxppc-dev <linuxppc-dev-bounces+vrbagal1=linux.vnet.ibm.com@lists.ozlabs.org>, linux-mm@kvack.org, linux-next <linux-next@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On 06/12/2018 05:28 AM, Balbir Singh wrote:
> 
> 
> On 11/06/18 17:41, vrbagal1 wrote:
>> On 2018-06-08 17:45, Oscar Salvador wrote:
>>> On Fri, Jun 08, 2018 at 05:11:24PM +0530, vrbagal1 wrote:
>>>> On 2018-06-08 16:58, Oscar Salvador wrote:
>>>>> On Fri, Jun 08, 2018 at 04:44:24PM +0530, vrbagal1 wrote:
>>>>>> Greetings!!!
>>>>>>
>>>>>> I am seeing kernel bug followed by oops message and system reboots,
>>>>>> while
>>>>>> running dlpar memory hotplug test.
>>>>>>
>>>>>> Machine Details: Power6 PowerVM Platform
>>>>>> GCC version: (gcc version 4.8.3 20140911 (Red Hat 4.8.3-7) (GCC))
>>>>>> Test case: dlpar memory hotplug test (https://github.com/avocado-framework-tests/avocado-misc-tests/blob/master/memory/memhotplug.py)
>>>>>> Kernel Version: Linux version 4.17.0-autotest
>>>>>>
>>>>>> I am seeing this bug on rc7 as well.
>>
>> Observing similar traces on linux next kernel: 4.17.0-next-20180608-autotest
>>
>> A Block size [0x4000000] unaligned hotplug range: start 0x220000000, size 0x1000000
> 
> size < block_size in this case, why? how? Could you confirm that the block size is 64MB and your trying to remove 16MB
> 

I was not able to re-create this failure exactly ( I don't have a Power6 system)
but was able to get a similar re-create on a Power 9 with a few modifications.

I think the issue you're seeing is due to a change in the validation of memory
done in remove_memory to ensure the amount of memory being removed spans
entire memory block. The pseries memory remove code, see pseries_remove_memblock,
tries to remove each section of a memory block instead of the entire memory block.

Could you try the patch below that updates the pseries code to remove the entire
memory block instead of doing it one section at a time.

-Nathan
---

 arch/powerpc/platforms/pseries/hotplug-memory.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
index c1578f54c626..6072efc793e1 100644
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -316,11 +316,11 @@ static int dlpar_offline_lmb(struct drmem_lmb *lmb)
 	return dlpar_change_lmb_state(lmb, false);
 }
 
-static int pseries_remove_memblock(unsigned long base, unsigned int memblock_size)
+static int pseries_remove_memblock(unsigned long base,
+				   unsigned int memblock_sz)
 {
-	unsigned long block_sz, start_pfn;
-	int sections_per_block;
-	int i, nid;
+	unsigned long start_pfn;
+	int nid;
 
 	start_pfn = base >> PAGE_SHIFT;
 
@@ -329,18 +329,12 @@ static int pseries_remove_memblock(unsigned long base, unsigned int memblock_siz
 	if (!pfn_valid(start_pfn))
 		goto out;
 
-	block_sz = pseries_memory_block_size();
-	sections_per_block = block_sz / MIN_MEMORY_BLOCK_SIZE;
 	nid = memory_add_physaddr_to_nid(base);
-
-	for (i = 0; i < sections_per_block; i++) {
-		remove_memory(nid, base, MIN_MEMORY_BLOCK_SIZE);
-		base += MIN_MEMORY_BLOCK_SIZE;
-	}
+	remove_memory(nid, base, memblock_sz);
 
 out:
 	/* Update memory regions for memory remove */
-	memblock_remove(base, memblock_size);
+	memblock_remove(base, memblock_sz);
 	unlock_device_hotplug();
 	return 0;
 }
