Date: Wed, 30 Jan 2008 18:56:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] mmu_notifier: invalidate_range_start with lock=1
In-Reply-To: <20080131023401.GY26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801301851310.14263@schroedinger.engr.sgi.com>
References: <20080130000039.GA7233@v2.random> <20080130161123.GS26420@sgi.com>
 <20080130170451.GP7233@v2.random> <20080130173009.GT26420@sgi.com>
 <20080130182506.GQ7233@v2.random> <Pine.LNX.4.64.0801301147330.30568@schroedinger.engr.sgi.com>
 <20080130235214.GC7185@v2.random> <Pine.LNX.4.64.0801301555550.1722@schroedinger.engr.sgi.com>
 <20080131003434.GE7185@v2.random> <Pine.LNX.4.64.0801301728110.2454@schroedinger.engr.sgi.com>
 <20080131023401.GY26420@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <andrea@qumranet.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

One possible way that XPmem could deal with a call of 
invalidate_range_start with the lock flag set:

Scan through the rmaps you have for ptes. If you find one then elevate the 
refcount of the corresponding page and mark in the maps that you have done 
so. Also make them readonly. The increased refcount will prevent the 
freeing of the page. The page will be unmapped from the process and XPmem 
will retain the only reference.

Then some shepherding process that you have anyways with XPmem can 
sometime later zap the remote ptes and free the pages. Would leave stale 
data visible on the remote side for awhile. Would that be okay?

This would only be used for truncate that uses the unmap_mapping_range 
call. So we are not in reclaim or other distress.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
