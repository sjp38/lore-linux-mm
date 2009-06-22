Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0A76B6B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 07:26:33 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.14.3/8.13.8) with ESMTP id n5MBR4LK588572
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 11:27:04 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5MBR40J3403848
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 13:27:04 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5MBR45J027447
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 13:27:04 +0200
Date: Mon, 22 Jun 2009 13:27:02 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: [RFC] transcendent memory for Linux
Message-ID: <20090622132702.6638d841@skybase>
In-Reply-To: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
References: <cd40cd91-66e9-469d-b079-3a899a3ccadb@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

On Fri, 19 Jun 2009 16:53:45 -0700 (PDT)
Dan Magenheimer <dan.magenheimer@oracle.com> wrote:

> Tmem has some similarity to IBM's Collaborative Memory Management,
> but creates more of a partnership between the kernel and the
> "privileged entity" and is not very invasive.  Tmem may be
> applicable for KVM and containers; there is some disagreement on
> the extent of its value. Tmem is highly complementary to ballooning
> (aka page granularity hot plug) and memory deduplication (aka
> transparent content-based page sharing) but still has value
> when neither are present.

The basic idea seems to be that you reduce the amount of memory
available to the guest and as a compensation give the guest some
tmem, no? If that is the case then the effect of tmem is somewhat
comparable to the volatile page cache pages.

The big advantage of this approach is its simplicity, but there
are down sides as well:
1) You need to copy the data between the tmem pool and the page
cache. At least temporarily there are two copies of the same
page around. That increases the total amount of used memory.
2) The guest has a smaller memory size. Either the memory is
large enough for the working set size in which case tmem is
ineffective, or the working set does not fit which increases
the memory pressure and the cpu cycles spent in the mm code.
3) There is an additional turning knob, the size of the tmem pool
for the guest. I see the need for a clever algorithm to determine
the size for the different tmem pools.

Overall I would say its worthwhile to investigate the performance
impacts of the approach.

-- 
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
