Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01E4B6B033B
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 08:20:06 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id i14so2998517qke.6
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 05:20:05 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id e6si1846816qkb.89.2017.09.08.05.20.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 05:20:04 -0700 (PDT)
Subject: Re: [PATCH v7 9/9] sparc64: Add support for ADI (Application Data
 Integrity)
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <3a687666c2e7972fb6d2379848f31006ac1dd59a.1502219353.git.khalid.aziz@oracle.com>
 <20170904162530.GA21781@amd>
 <20170905.144456.431070706382873486.davem@davemloft.net>
 <20170906223206.GA11481@amd>
From: Steven Sistare <steven.sistare@oracle.com>
Message-ID: <8e191b8e-2e72-5ef8-ba0e-abf1cbc2fad0@oracle.com>
Date: Fri, 8 Sep 2017 08:18:48 -0400
MIME-Version: 1.0
In-Reply-To: <20170906223206.GA11481@amd>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>, David Miller <davem@davemloft.net>
Cc: khalid.aziz@oracle.com, dave.hansen@linux.intel.com, corbet@lwn.net, bob.picco@oracle.com, pasha.tatashin@oracle.com, mike.kravetz@oracle.com, mingo@kernel.org, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, tom.hromatka@oracle.com, eric.saint.etienne@oracle.com, allen.pais@oracle.com, cmetcalf@mellanox.com, akpm@linux-foundation.org, geert@linux-m68k.org, tklauser@distanz.ch, atish.patra@oracle.com, vijay.ac.kumar@oracle.com, peterz@infradead.org, mhocko@suse.com, jack@suse.cz, lstoakes@gmail.com, hughd@google.com, thomas.tai@oracle.com, paul.gortmaker@windriver.com, ross.zwisler@linux.intel.com, dave.jiang@intel.com, willy@infradead.org, ying.huang@intel.com, zhongjiang@huawei.com, minchan@kernel.org, vegard.nossum@oracle.com, imbrenda@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, khalid@gonehiking.org

On 9/6/2017 6:32 PM, Pavel Machek wrote:
> On Tue 2017-09-05 14:44:56, David Miller wrote:
>> From: Pavel Machek <pavel@ucw.cz>
>> Date: Mon, 4 Sep 2017 18:25:30 +0200
>>
>>> Will gcc be able to compile code that uses these automatically? That
>>> does not sound easy to me. Can libc automatically use this in malloc()
>>> to prevent accessing freed data when buffers are overrun?
>>>
>>> Is this for benefit of JITs?
>>
>> Anything that can control mappings and the virtual address used to
>> access memory can use ADI.
>>
>> malloc() is of course one such case.  It can map memory with ADI
>> enabled, and return buffer addresses to malloc() callers with the
>> proper virtual address bits set to satisfy the ADI key checks.
>>
>> And by induction anything using malloc() for it's memory allocation
>> gets ADI protection as well.
> 
> I see; that's actually quite a nice trick.
> 
> I guess it does not protect against stack-based overflows, but should
> help against heap-based overflows, so it improves security a bit, too.
> 
> Nice, thanks for explanation.

ADI can also be used to protect the stack.  Modify ADI versions for
a 64B aligned portion of the register save area in the kernel spill
and fill handlers,  and accidental or malicious access to the area 
from userland will trap.  Other data on the stack can be corrupted, 
but one cannot linearly overflow into the next stack frame without 
tripping over the ADI canary.  There are a few other details to handle,
such as setjmp/longjmp and JITs that modify the stack, but that is the gist.  
This is not part of the current patch, but has been implemented on
Solaris.

ADI could protect other data on the stack, but that requires 
compiler code generation changes.

- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
