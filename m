Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6D76B0491
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 01:17:02 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id s9so1781945oie.2
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 22:17:02 -0800 (PST)
Received: from huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id a63si1331849oic.109.2018.01.04.22.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 22:17:01 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
 <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <bda85c5e-d2be-f4ac-e2b4-4ef01d5a01a5@huawei.com>
Date: Fri, 5 Jan 2018 14:16:38 +0800
MIME-Version: 1.0
In-Reply-To: <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

Hi Dave,

On 2018/1/5 13:18, Dave Hansen wrote:
> On 01/04/2018 08:16 PM, Yisheng Xie wrote:
>>> === Page Table Poisoning ===
>>>
>>> KAISER has two copies of the page tables: one for the kernel and
>>> one for when running in userspace.  
>>
>> So, we have 2 page table, thinking about this case:
>> If _ONE_ process includes _TWO_ threads, one run in user space, the other
>> run in kernel, they can run in one core with Hyper-Threading, right?
> 
> Yes.
> 
>> So both userspace and kernel space is valid, right? And for one core
>> with Hyper-Threading, they may share TLB, so the timing problem
>> described in the paper may still exist?
> 
> No.  The TLB is managed per logical CPU (hyperthread), as is the CR3
> register that points to the page tables.  Two threads running the same
> process might use the same CR3 _value_, but that does not mean they
> share TLB entries.

Get it, and thanks for your explain.

BTW, we have just reported a bug caused by kaiser[1], which looks like
caused by SMEP. Could you please help to have a look?

[1] https://lkml.org/lkml/2018/1/5/3

Thanks
Yisheng

> 
> One thread *can* be in the kernel with the kernel page tables while the
> other is in userspace with the user page tables active.  They will even
> use a different PCID/ASID for the same page tables normally.
> 
>> Can this case still be protected by KAISER?
> 
> Yes.
> 
> .
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
