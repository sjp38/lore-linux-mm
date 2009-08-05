Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 56F7F6B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 12:36:04 -0400 (EDT)
Date: Wed, 5 Aug 2009 18:35:37 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090805163537.GG23385@random.random>
References: <20090805024058.GA8886@localhost>
 <4A793B92.9040204@redhat.com>
 <4A7993F4.9020008@redhat.com>
 <4A79A16A.1050401@redhat.com>
 <4A79A1FB.6010406@redhat.com>
 <4A79A468.2020200@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A79A468.2020200@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 05, 2009 at 06:25:28PM +0300, Avi Kivity wrote:
> On 08/05/2009 06:15 PM, Rik van Riel wrote:
> > Avi Kivity wrote:
> >
> >>> If so, we could unmap them when they get moved from the
> >>> active to the inactive list, and soft fault them back in
> >>> on access, emulating the referenced bit for EPT pages and
> >>> making page replacement on them work like it should.
> >>
> >> It should be easy to implement via the mmu notifier callback: when 
> >> the mm calls clear_flush_young(), mark it as young, and unmap it from 
> >> the EPT pagetable.
> >
> > You mean "mark it as old"?
> 
> I meant 'return young, and drop it from the EPT pagetable'.
> 
> If we use the present bit as a replacement for the accessed bit, present 
> means young, and clear_flush_young means "if present, return young and 
> unmap, otherwise return old'.

This is the only way to provide accurate information, and it's still a
minor fault so not very different than return young first time around
and old second time around without invalidating the spte... but the
only reason I like it more is that it is done at the right time, like
for the ptes, so probably it's best to implement it this way to ensure
total fairness of the VM regardless if it's guest or qemu-kvm touching
the virtual memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
