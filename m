Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 563816B0083
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:15:32 -0400 (EDT)
Message-ID: <4A79A1FB.6010406@redhat.com>
Date: Wed, 05 Aug 2009 11:15:07 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com> <4A7993F4.9020008@redhat.com> <4A79A16A.1050401@redhat.com>
In-Reply-To: <4A79A16A.1050401@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:

>> If so, we could unmap them when they get moved from the
>> active to the inactive list, and soft fault them back in
>> on access, emulating the referenced bit for EPT pages and
>> making page replacement on them work like it should.
> 
> It should be easy to implement via the mmu notifier callback: when the 
> mm calls clear_flush_young(), mark it as young, and unmap it from the 
> EPT pagetable.

You mean "mark it as old"?

>> Your approximation of pretending the page is accessed the
>> first time and pretending it's not the second time sounds
>> like it will just lead to less efficient FIFO replacement,
>> not to anything even vaguely approximating LRU.
> 
> Right, it's just a hack that gives EPT pages higher priority, like the 
> original patch suggested.  Note that LRU for VMs is not a good 
> algorithm, since the VM will also reference the least recently used 
> page, leading to thrashing.

That is one of the reasons we use a very coarse two
handed clock algorithm instead of true LRU.

LRU has more overhead and more artifacts :)

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
