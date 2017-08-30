Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BC436B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 18:38:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id q68so14503379pgq.11
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 15:38:34 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [184.105.139.130])
        by mx.google.com with ESMTPS id d23si5329589pgn.676.2017.08.30.15.38.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 15:38:33 -0700 (PDT)
Date: Wed, 30 Aug 2017 15:38:30 -0700 (PDT)
Message-Id: <20170830.153830.2267882580011615008.davem@davemloft.net>
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
From: David Miller <davem@davemloft.net>
In-Reply-To: <7b8216b8-e732-0b31-a374-1a817d4fbc80@oracle.com>
References: <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
	<F65BCC2D-8FA4-453F-8378-3369C44B0319@oracle.com>
	<7b8216b8-e732-0b31-a374-1a817d4fbc80@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: khalid.aziz@oracle.com
Cc: anthony.yznaga@oracle.com, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, steven.sistare@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

From: Khalid Aziz <khalid.aziz@oracle.com>
Date: Wed, 30 Aug 2017 16:27:54 -0600

>>> +#define arch_calc_vm_prot_bits(prot, pkey)
>>> sparc_calc_vm_prot_bits(prot)
>>> +static inline unsigned long sparc_calc_vm_prot_bits(unsigned long
>>> prot)
>>> +{
>>> +	if (prot & PROT_ADI) {
>>> +		struct pt_regs *regs;
>>> +
>>> +		if (!current->mm->context.adi) {
>>> +			regs = task_pt_regs(current);
>>> +			regs->tstate |= TSTATE_MCDE;
>>> +			current->mm->context.adi = true;
>> If a process is multi-threaded when it enables ADI on some memory for
>> the first time, TSTATE_MCDE will only be set for the calling thread
>> and it will not be possible to enable it for the other threads.
>> One possible way to handle this is to enable TSTATE_MCDE for all user
>> threads when they are initialized if adi_capable() returns true.
>> 
> 
> Or set TSTATE_MCDE unconditionally here by removing "if
> (!current->mm->context.adi)"?

I think you have to make "ADI enabled" a property of the mm_struct.

Then you can broadcast to mm->cpu_vm_mask a per-cpu interrupt that
updates regs->tstate of a thread using 'mm' is currently executing.

And in the context switch code you set TSTATE_MCDE if it's not set
already.

That should cover all threaded case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
