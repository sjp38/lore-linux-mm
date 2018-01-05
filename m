Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD7328025D
	for <linux-mm@kvack.org>; Fri,  5 Jan 2018 00:18:04 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id g33so2491840plb.13
        for <linux-mm@kvack.org>; Thu, 04 Jan 2018 21:18:04 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m17si3058682pge.720.2018.01.04.21.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jan 2018 21:18:03 -0800 (PST)
Subject: Re: [PATCH 05/23] x86, kaiser: unmap kernel from userspace page
 tables (core patch)
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003447.1DB395E3@viggo.jf.intel.com>
 <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <93776eb2-b6d4-679a-280c-8ba558a69c34@linux.intel.com>
Date: Thu, 4 Jan 2018 21:18:02 -0800
MIME-Version: 1.0
In-Reply-To: <e80ac5b1-c562-fc60-ee84-30a3a40bde60@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, richard.fellner@student.tugraz.at, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org

On 01/04/2018 08:16 PM, Yisheng Xie wrote:
>> === Page Table Poisoning ===
>>
>> KAISER has two copies of the page tables: one for the kernel and
>> one for when running in userspace.  
> 
> So, we have 2 page table, thinking about this case:
> If _ONE_ process includes _TWO_ threads, one run in user space, the other
> run in kernel, they can run in one core with Hyper-Threading, right?

Yes.

> So both userspace and kernel space is valid, right? And for one core
> with Hyper-Threading, they may share TLB, so the timing problem
> described in the paper may still exist?

No.  The TLB is managed per logical CPU (hyperthread), as is the CR3
register that points to the page tables.  Two threads running the same
process might use the same CR3 _value_, but that does not mean they
share TLB entries.

One thread *can* be in the kernel with the kernel page tables while the
other is in userspace with the user page tables active.  They will even
use a different PCID/ASID for the same page tables normally.

> Can this case still be protected by KAISER?

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
