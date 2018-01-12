Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 752B16B0260
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 13:19:08 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m7so5171555pgv.17
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:19:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u66si15735557pfa.237.2018.01.12.10.19.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 12 Jan 2018 10:19:07 -0800 (PST)
Date: Fri, 12 Jan 2018 10:18:40 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v6 18/24] mm: Try spin lock in speculative path
Message-ID: <20180112181840.GA7590@bombadil.infradead.org>
References: <1515777968-867-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1515777968-867-19-git-send-email-ldufour@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515777968-867-19-git-send-email-ldufour@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Fri, Jan 12, 2018 at 06:26:02PM +0100, Laurent Dufour wrote:
> There is a deadlock when a CPU is doing a speculative page fault and
> another one is calling do_unmap().
> 
> The deadlock occurred because the speculative path try to spinlock the
> pte while the interrupt are disabled. When the other CPU in the
> unmap's path has locked the pte then is waiting for all the CPU to
> invalidate the TLB. As the CPU doing the speculative fault have the
> interrupt disable it can't invalidate the TLB, and can't get the lock.
> 
> Since we are in a speculative path, we can race with other mm action.
> So let assume that the lock may not get acquired and fail the
> speculative page fault.

It seems like you introduced this bug in the previous patch, and now
you're fixing it in this patch?  Why not merge the two?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
