Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94BDB6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 08:04:35 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r133so5928798pgr.6
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 05:04:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g14si2180207pfd.491.2017.08.29.05.04.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 05:04:34 -0700 (PDT)
Date: Tue, 29 Aug 2017 14:04:26 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 14/20] mm: Provide speculative fault infrastructure
Message-ID: <20170829120426.4ar56rbmiupbqmio@hirez.programming.kicks-ass.net>
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1503007519-26777-15-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170827001823.n5wgkfq36z6snvf2@node.shutemov.name>
 <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <507e79d5-59df-c5b5-106d-970c9353d9bc@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Tue, Aug 29, 2017 at 09:59:30AM +0200, Laurent Dufour wrote:
> On 27/08/2017 02:18, Kirill A. Shutemov wrote:
> >> +
> >> +	if (unlikely(!vma->anon_vma))
> >> +		goto unlock;
> > 
> > It deserves a comment.
> 
> You're right I'll add it in the next version.
> For the record, the root cause is that __anon_vma_prepare() requires the
> mmap_sem to be held because vm_next and vm_prev must be safe.

But should that test not be:

	if (unlikely(vma_is_anonymous(vma) && !vma->anon_vma))
		goto unlock;

Because !anon vmas will never have ->anon_vma set and you don't want to
exclude those.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
