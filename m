Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 50C3D6B0082
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:22:33 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id z10so1107211pdj.15
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 07:22:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id yy4si1621298pbb.167.2014.10.23.07.22.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 07:22:31 -0700 (PDT)
Date: Thu, 23 Oct 2014 16:22:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 3/6] mm: VMA sequence count
Message-ID: <20141023142224.GL3219@twins.programming.kicks-ass.net>
References: <20141020215633.717315139@infradead.org>
 <20141020222841.361741939@infradead.org>
 <20141022112657.GG30588@node.dhcp.inet.fi>
 <20141022113951.GB21513@worktop.programming.kicks-ass.net>
 <20141022115304.GA31486@node.dhcp.inet.fi>
 <20141022121554.GD21513@worktop.programming.kicks-ass.net>
 <20141022134416.GA15602@worktop.programming.kicks-ass.net>
 <20141023123616.GA8809@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023123616.GA8809@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: torvalds@linux-foundation.org, paulmck@linux.vnet.ibm.com, tglx@linutronix.de, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, oleg@redhat.com, mingo@redhat.com, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, viro@zeniv.linux.org.uk, laijs@cn.fujitsu.com, dave@stgolabs.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 23, 2014 at 03:36:16PM +0300, Kirill A. Shutemov wrote:
> On Wed, Oct 22, 2014 at 03:44:16PM +0200, Peter Zijlstra wrote:
> > On Wed, Oct 22, 2014 at 02:15:54PM +0200, Peter Zijlstra wrote:
> > > On Wed, Oct 22, 2014 at 02:53:04PM +0300, Kirill A. Shutemov wrote:
> > > > Em, no. In this case change_protection() will not touch the pte, since
> > > > it's pte_none() and the pte_same() check will pass just fine.
> > > 
> > > Oh, that's what you meant. Yes that's a problem, yes vm_page_prot
> > > needs wrapping too.
> > 
> > Maybe also vm_policy, is there anything else that can change while a vma
> > lives?
> 
>  - vm_flags, obviously;

Do those ever change? The only thing that jumps out is the VM_LOCKED
thing and that should not really matter one way or the other, but sure
can do.

>  - shared, anon_vma and anon_vma_chain (at least on the first write fault
>    to private mapping);
>  - vm_pgoff (mremap(2) ?);

Right you are. Never thought about that one.

>  - vm_private_data -- it's all over drivers. Potential nightmare, but
>    seems not in use for anon mappings.

Yeah, we need to either audit drivers or otherwise exclude stuff from
speculative faults, Andy already noted that drivers might not expect
.fault after .close or whatnot.

In any case, yes I'll go include them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
