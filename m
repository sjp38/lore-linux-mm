Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4FCD6B0003
	for <linux-mm@kvack.org>; Mon, 14 May 2018 17:49:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r63-v6so11360420pfl.12
        for <linux-mm@kvack.org>; Mon, 14 May 2018 14:49:05 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j6-v6si8160557pgp.534.2018.05.14.14.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 May 2018 14:49:03 -0700 (PDT)
Date: Mon, 14 May 2018 14:49:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-Id: <20180514144901.0fe99d240ff8a53047dd512e@linux-foundation.org>
In-Reply-To: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Mon, 14 May 2018 20:28:01 +0300 Boaz Harrosh <boazh@netapp.com> wrote:

> On a call to mmap an mmap provider (like an FS) can put
> this flag on vma->vm_flags.
> 
> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
> from a single-core only, and therefore invalidation (flush_tlb) of
> PTE(s) need not be a wide CPU scheduling.
> 
> The motivation of this flag is the ZUFS project where we want
> to optimally map user-application buffers into a user-mode-server
> execute the operation and efficiently unmap.
> 
> In this project we utilize a per-core server thread so everything
> is kept local. If we use the regular zap_ptes() API All CPU's
> are scheduled for the unmap, though in our case we know that we
> have only used a single core. The regular zap_ptes adds a very big
> latency on every operation and mostly kills the concurrency of the
> over all system. Because it imposes a serialization between all cores

I'd have thought that in this situation, only the local CPU's bit is
set in the vma's mm_cpumask() and the remote invalidations are not
performed.  Is that a misunderstanding, or is all that stuff not working
correctly?
