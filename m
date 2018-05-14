Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D52C6B0006
	for <linux-mm@kvack.org>; Mon, 14 May 2018 15:38:14 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id x21-v6so11176268pfn.23
        for <linux-mm@kvack.org>; Mon, 14 May 2018 12:38:14 -0700 (PDT)
Received: from mx142.netapp.com (mx142.netapp.com. [2620:10a:4005:8000:2306::b])
        by mx.google.com with ESMTPS id t19-v6si9313987plo.287.2018.05.14.12.38.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 12:38:13 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
Date: Mon, 14 May 2018 22:37:38 +0300
MIME-Version: 1.0
In-Reply-To: <20180514191551.GA27939@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 14/05/18 22:15, Matthew Wilcox wrote:
> On Mon, May 14, 2018 at 08:28:01PM +0300, Boaz Harrosh wrote:
>> On a call to mmap an mmap provider (like an FS) can put
>> this flag on vma->vm_flags.
>>
>> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
>> from a single-core only, and therefore invalidation (flush_tlb) of
>> PTE(s) need not be a wide CPU scheduling.
> 
> I still don't get this.  You're opening the kernel up to being exploited
> by any application which can persuade it to set this flag on a VMA.
> 

No No this is not an application accessible flag this can only be set
by the mmap implementor at ->mmap() time (Say same as VM_VM_MIXEDMAP).

Please see the zuf patches for usage (Again apologise for pushing before
a user)

The mmap provider has all the facilities to know that this can not be
abused, not even by a trusted Server.

>> NOTE: This vma (VM_LOCAL_CPU) is never used during a page_fault. It is
>> always used in a synchronous way from a thread pinned to a single core.
> 
> It's not a question of how your app is going to use this flag.  It's a
> question about how another app can abuse this flag (or how your app is
> going to be exploited to abuse this flag) to break into the kernel.
> 

If you look at the zuf user you will see that the faults all return
SIG_BUS. These can never fault. The server has access to this mapping
from a single thread pinned to a core.

Again it is not an app visible flag in anyway

Thanks for looking
Boaz
