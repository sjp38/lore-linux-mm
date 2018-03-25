Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C88A6B005A
	for <linux-mm@kvack.org>; Sun, 25 Mar 2018 18:10:32 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so11656795plf.1
        for <linux-mm@kvack.org>; Sun, 25 Mar 2018 15:10:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f35-v6sor6097370plh.75.2018.03.25.15.10.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Mar 2018 15:10:31 -0700 (PDT)
Date: Sun, 25 Mar 2018 15:10:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mm] b1f0502d04: INFO:trying_to_register_non-static_key
In-Reply-To: <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1803251510040.80485@chino.kir.corp.google.com>
References: <20180317075119.u6yuem2bhxvggbz3@inn> <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: kernel test robot <fengguang.wu@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org

On Wed, 21 Mar 2018, Laurent Dufour wrote:

> I found the root cause of this lockdep warning.
> 
> In mmap_region(), unmap_region() may be called while vma_link() has not been
> called. This happens during the error path if call_mmap() failed.
> 
> The only to fix that particular case is to call
> seqcount_init(&vma->vm_sequence) when initializing the vma in mmap_region().
> 

Ack, although that would require a fixup to dup_mmap() as well.
