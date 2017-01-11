Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75A176B025E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 13:51:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c73so65933197pfb.7
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 10:51:16 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 13si3696173pfl.237.2017.01.11.10.51.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jan 2017 10:51:15 -0800 (PST)
Subject: Re: [PATCH v4 0/4] Application Data Integrity feature introduced by
 SPARC M7
References: <cover.1483999591.git.khalid.aziz@oracle.com>
 <621cfed0-3e56-13e6-689a-0637bce164fe@linux.intel.com>
 <f70cd704-f486-ed5c-7961-b71278fc8f9a@oracle.com>
 <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <4978715f-e5e8-824e-3804-597eaa0beb95@oracle.com>
Date: Wed, 11 Jan 2017 11:50:52 -0700
MIME-Version: 1.0
In-Reply-To: <11d20dac-2c0f-6e9a-7f98-3839c749adb6@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, davem@davemloft.net, corbet@lwn.net, arnd@arndb.de, akpm@linux-foundation.org
Cc: hpa@zytor.com, viro@zeniv.linux.org.uk, nitin.m.gupta@oracle.com, chris.hyser@oracle.com, tushar.n.dave@oracle.com, sowmini.varadhan@oracle.com, mike.kravetz@oracle.com, adam.buchbinder@gmail.com, minchan@kernel.org, hughd@google.com, kirill.shutemov@linux.intel.com, keescook@chromium.org, allen.pais@oracle.com, aryabinin@virtuozzo.com, atish.patra@oracle.com, joe@perches.com, pmladek@suse.com, jslaby@suse.cz, cmetcalf@mellanox.com, paul.gortmaker@windriver.com, mhocko@suse.com, jmarchan@redhat.com, lstoakes@gmail.com, 0x7f454c46@gmail.com, vbabka@suse.cz, tglx@linutronix.de, mingo@redhat.com, dan.j.williams@intel.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, namit@vmware.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

On 01/11/2017 11:13 AM, Dave Hansen wrote:
> On 01/11/2017 08:56 AM, Khalid Aziz wrote:
>> On 01/11/2017 09:33 AM, Dave Hansen wrote:
>>> On 01/11/2017 08:12 AM, Khalid Aziz wrote:
>>>> A userspace task enables ADI through mprotect(). This patch series adds
>>>> a page protection bit PROT_ADI and a corresponding VMA flag
>>>> VM_SPARC_ADI. VM_SPARC_ADI is used to trigger setting TTE.mcd bit in the
>>>> sparc pte that enables ADI checking on the corresponding page.
>>>
>>> Is there a cost in the hardware associated with doing this "ADI
>>> checking"?  For instance, instead of having this new mprotect()
>>> interface, why not just always set TTE.mcd on all PTEs?
>>
>> There is no performance penalty in the MMU to check tags, but if
>> PSTATE.mcd bit is set and TTE.mcde is set, the tag in VA must match what
>> was set on the physical page for all memory accesses.
>
> OK, then I'm misunderstanding the architecture again.
>
> For memory shared by two different processes, do they have to agree on
> what the tags are, or can they differ?

The two processes have to agree on the tag. This is part of the security 
design to prevent other processes from accessing pages belonging to 
another process unless they know the tag set on those pages.

>
>> Potential for side
>> effects is too high in such case and would require kernel to either
>> track tags for every page as they are re-allocated or migrated, or scrub
>> pages constantly to ensure we do not get spurious tag mismatches. Unless
>> there is a very strong reason to blindly set TTE.mcd on every PTE, I
>> think the risk of instability is too high without lot of extra code.
>
> Ahh, ok.  That makes sense.  Clearing the tags is expensive.  We must
> either clear tags or know the previous tags of the memory before we
> access it.
>
> Are any of the tags special?  Do any of them mean "don't do any
> checking", or similar?
>

Tag values of 0 and 15 can be considered special. Setting tag to 15 on 
memory range is disallowed. Accessing a memory location whose tag is 
cleared (means set to 0) with any tag value in the VA is allowed. Once a 
tag is set on a memory, and PSTATE.mcde and TTE.mcd are set, there isn't 
a tag that can be used to bypass version check by MMU.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
