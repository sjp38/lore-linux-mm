Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BF7C96B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 09:10:49 -0500 (EST)
Date: Tue, 2 Feb 2010 15:10:36 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100202141036.GL4135@random.random>
References: <20100202040145.555474000@alcatraz.americas.sgi.com>
 <20100202080947.GA28736@infradead.org>
 <20100202125943.GH4135@random.random>
 <20100202131341.GI4135@random.random>
 <20100202132919.GO6653@sgi.com>
 <20100202134047.GJ4135@random.random>
 <20100202135141.GH6616@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100202135141.GH6616@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 07:51:41AM -0600, Robin Holt wrote:
> I don't see the change in API with this method either.

The API change I'm referring to, is the reason that you had to patch
virt/kvm/kvm_main.c and drivers/misc/sgi-gru/grutlbpurge.c to prevent
compile failure. That isn't needed if we really make mmu notifier
sleepable like my old patched did just fine. Except they slowed down
the locking to achieve it... (the slowdown should be confined to
config option) and you don't want that I guess. But if you didn't need
to return -EINVAL I think your userland would also be safer. Only
problem I can see is that you would then have trouble to convince
distro to build with the slower locking and you basically are ok to
break userland in truncate to be sure your module will work with
default binary distro kernel. It's a tradeoff and I'm not against it
but it has to be well documented that this is an hack to be practical
on binary shipped kernels.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
