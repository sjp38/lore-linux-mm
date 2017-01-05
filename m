Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA9F6B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:14:06 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id n68so490472107itn.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:14:06 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l77si10447661ioe.11.2017.01.05.07.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 07:14:05 -0800 (PST)
Subject: Re: [RFC PATCH v3] sparc64: Add support for Application Data
 Integrity (ADI)
References: <1483569999-13543-1-git-send-email-khalid.aziz@oracle.com>
 <fc6696de-34d7-e4ce-2b39-f788ba22843e@redhat.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <e808bcce-3357-9df9-2032-442d6b59798a@oracle.com>
Date: Thu, 5 Jan 2017 08:13:31 -0700
MIME-Version: 1.0
In-Reply-To: <fc6696de-34d7-e4ce-2b39-f788ba22843e@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, dave.hansen@linux.intel.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Khalid Aziz <khalid@gonehiking.org>

On 01/05/2017 02:37 AM, Jerome Marchand wrote:
> On 01/04/2017 11:46 PM, Khalid Aziz wrote:
>> ADI is a new feature supported on sparc M7 and newer processors to allow
>> hardware to catch rogue accesses to memory. ADI is supported for data
>> fetches only and not instruction fetches. An app can enable ADI on its
>> data pages, set version tags on them and use versioned addresses to
>> access the data pages. Upper bits of the address contain the version
>> tag. On M7 processors, upper four bits (bits 63-60) contain the version
>> tag. If a rogue app attempts to access ADI enabled data pages, its
>> access is blocked and processor generates an exception.
>>
>> This patch extends mprotect to enable ADI (TSTATE.mcde), enable/disable
>> MCD (Memory Corruption Detection) on selected memory ranges, enable
>> TTE.mcd in PTEs, return ADI parameters to userspace and save/restore ADI
>> version tags on page swap out/in.  It also adds handlers for all traps
>> related to MCD. ADI is not enabled by default for any task. A task must
>> explicitly enable ADI on a memory range and set version tag for ADI to
>> be effective for the task.
>>
>> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
>> Cc: Khalid Aziz <khalid@gonehiking.org>
>> ---
>> v2:
>> 	- Fixed a build error
>>
>> v3:
>> 	- Removed CONFIG_SPARC_ADI
>> 	- Replaced prctl commands with mprotect
>> 	- Added auxiliary vectors for ADI parameters
>> 	- Enabled ADI for swappable pages
>>
>>  Documentation/sparc/adi.txt             | 239 ++++++++++++++++++++++++++++++++
>>  arch/sparc/include/asm/adi.h            |   6 +
>>  arch/sparc/include/asm/adi_64.h         |  46 ++++++
>>  arch/sparc/include/asm/elf_64.h         |   8 ++
>>  arch/sparc/include/asm/hugetlb.h        |  13 ++
>>  arch/sparc/include/asm/hypervisor.h     |   2 +
>>  arch/sparc/include/asm/mman.h           |  40 +++++-
>>  arch/sparc/include/asm/mmu_64.h         |   2 +
>>  arch/sparc/include/asm/mmu_context_64.h |  32 +++++
>>  arch/sparc/include/asm/pgtable_64.h     |  97 ++++++++++++-
>>  arch/sparc/include/asm/ttable.h         |  10 ++
>>  arch/sparc/include/asm/uaccess_64.h     | 120 +++++++++++++++-
>>  arch/sparc/include/uapi/asm/asi.h       |   5 +
>>  arch/sparc/include/uapi/asm/auxvec.h    |   8 ++
>>  arch/sparc/include/uapi/asm/mman.h      |   2 +
>>  arch/sparc/include/uapi/asm/pstate.h    |  10 ++
>>  arch/sparc/kernel/Makefile              |   1 +
>>  arch/sparc/kernel/adi_64.c              |  93 +++++++++++++
>>  arch/sparc/kernel/entry.h               |   3 +
>>  arch/sparc/kernel/head_64.S             |   1 +
>>  arch/sparc/kernel/mdesc.c               |   4 +
>>  arch/sparc/kernel/process_64.c          |  21 +++
>>  arch/sparc/kernel/sun4v_mcd.S           |  16 +++
>>  arch/sparc/kernel/traps_64.c            | 142 ++++++++++++++++++-
>>  arch/sparc/kernel/ttable_64.S           |   6 +-
>>  arch/sparc/mm/gup.c                     |  37 +++++
>>  arch/sparc/mm/tlb.c                     |  28 ++++
>>  arch/x86/kernel/signal_compat.c         |   2 +-
>>  include/asm-generic/pgtable.h           |   5 +
>>  include/linux/mm.h                      |   2 +
>>  include/uapi/asm-generic/siginfo.h      |   5 +-
>>  mm/memory.c                             |   2 +-
>>  mm/rmap.c                               |   4 +-
>
> I haven't actually reviewed the code and looked at why you need
> set_swp_pte_at() function, but the code that add the generic version of
> this function need to be separated from the rest of the patch. Also,
> given the size of this patch, I suspect the rest also need to be broken
> into more patches.
>
> Jerome
>

Sure, I can do that. Code to add new signal codes can be one patch, 
generic changes to swap infrastructure can be another and I can look for 
logical breaks for the rest of the sparc specific code.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
