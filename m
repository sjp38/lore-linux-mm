Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id B04D26B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 10:01:00 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 16so11565664oin.13
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 07:01:00 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v14si1921888iog.97.2018.02.02.07.00.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 07:00:59 -0800 (PST)
Subject: Re: [PATCH v11 00/10] Application Data Integrity feature introduced
 by SPARC M7
References: <cover.1517497017.git.khalid.aziz@oracle.com>
 <87wozwi0p1.fsf@xmission.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <0f1bdb63-60d5-467c-a6a4-c06ba62b1f6e@oracle.com>
Date: Fri, 2 Feb 2018 07:59:25 -0700
MIME-Version: 1.0
In-Reply-To: <87wozwi0p1.fsf@xmission.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: davem@davemloft.net, dave.hansen@linux.intel.com, aarcange@redhat.com, akpm@linux-foundation.org, allen.pais@oracle.com, anthony.yznaga@oracle.com, arnd@arndb.de, babu.moger@oracle.com, benh@kernel.crashing.org, bob.picco@oracle.com, bsingharora@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, dave.jiang@intel.com, david.j.aldridge@oracle.com, elena.reshetova@intel.com, glx@linutronix.de, gregkh@linuxfoundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, hpa@zytor.com, hughd@google.com, imbrenda@linux.vnet.ibm.com, jack@suse.cz, jag.raman@oracle.com, jane.chu@oracle.com, jglisse@redhat.com, jroedel@suse.de, khalid@gonehiking.org, khandual@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, kstewart@linuxfoundation.org, ktkhai@virtuozzo.com, liam.merwick@oracle.com, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net, me@tobin.cc, mgorman@suse.de, mgorman@techsingularity.net, mhocko@suse.com, mike.kravetz@oracle.com, minchan@kernel.org, mingo@kernel.org, mingo@redhat.com, mpe@ellerman.id.au, nadav.amit@gmail.com, nagarathnam.muthusamy@oracle.com, nborisov@suse.com, n-horiguchi@ah.jp.nec.com, nick.alcock@oracle.com, nitin.m.gupta@oracle.com, ombredanne@nexb.com, pasha.tatashin@oracle.com, paulus@samba.org, pombredanne@nexb.com, punit.agrawal@arm.com, rob.gardner@oracle.com, ross.zwisler@linux.intel.com, shannon.nelson@oracle.com, shli@fb.com, sparclinux@vger.kernel.org, steven.sistare@oracle.com, tglx@linutronix.de, thomas.tai@oracle.com, tklauser@distanz.ch, tom.hromatka@oracle.com, vegard.nossum@oracle.com, vijay.ac.kumar@oracle.com, willy@infradead.org, x86@kernel.org, zi.yan@cs.rutgers.edu

On 02/01/2018 07:29 PM, ebiederm@xmission.com wrote:
> Khalid Aziz <khalid.aziz@oracle.com> writes:
> 
>> V11 changes:
>> This series is same as v10 and was simply rebased on 4.15 kernel. Can
>> mm maintainers please review patches 2, 7, 8 and 9 which are arch
>> independent, and include/linux/mm.h and mm/ksm.c changes in patch 10
>> and ack these if everything looks good?
> 
> I am a bit puzzled how this differs from the pkey's that other
> architectures are implementing to achieve a similar result.
> 
> I am a bit mystified why you don't store the tag in a vma
> instead of inventing a new way to store data on page out.

Hello Eric,

As Steven pointed out, sparc sets tags per cacheline unlike pkey. This 
results in much finer granularity for tags that pkey and hence requires 
larger tag storage than what we can do in a vma.

> 
> Can you please use force_sig_fault to send these signals instead
> of force_sig_info.  Emperically I have found that it is very
> error prone to generate siginfo's by hand, especially on code
> paths where several different si_codes may apply.  So it helps
> to go through a helper function to ensure the fiddly bits are
> all correct.  AKA the unused bits all need to be set to zero before
> struct siginfo is copied to userspace.
> 

What you say makes sense. I followed the same code as other fault 
handlers for sparc. I could change just the fault handlers for ADI 
related faults. Would it make more sense to change all the fault 
handlers in a separate patch and keep the code in 
arch/sparc/kernel/traps_64.c consistent? Dave M, do you have a preference?

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
