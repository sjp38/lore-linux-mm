Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5A96B0007
	for <linux-mm@kvack.org>; Mon, 14 May 2018 15:15:58 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s17-v6so6638357pgq.23
        for <linux-mm@kvack.org>; Mon, 14 May 2018 12:15:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u36-v6si8443859pgn.213.2018.05.14.12.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 14 May 2018 12:15:56 -0700 (PDT)
Date: Mon, 14 May 2018 12:15:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
Message-ID: <20180514191551.GA27939@bombadil.infradead.org>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Mon, May 14, 2018 at 08:28:01PM +0300, Boaz Harrosh wrote:
> On a call to mmap an mmap provider (like an FS) can put
> this flag on vma->vm_flags.
> 
> The VM_LOCAL_CPU flag tells the Kernel that the vma will be used
> from a single-core only, and therefore invalidation (flush_tlb) of
> PTE(s) need not be a wide CPU scheduling.

I still don't get this.  You're opening the kernel up to being exploited
by any application which can persuade it to set this flag on a VMA.

> NOTE: This vma (VM_LOCAL_CPU) is never used during a page_fault. It is
> always used in a synchronous way from a thread pinned to a single core.

It's not a question of how your app is going to use this flag.  It's a
question about how another app can abuse this flag (or how your app is
going to be exploited to abuse this flag) to break into the kernel.
