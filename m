Date: Wed, 30 Jan 2008 18:37:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [kvm-devel] [patch 2/6] mmu_notifier: Callbacks to invalidate
 address ranges
In-Reply-To: <20080131023401.GY26420@sgi.com>
Message-ID: <Pine.LNX.4.64.0801301835310.14177@schroedinger.engr.sgi.com>
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

On Wed, 30 Jan 2008, Robin Holt wrote:

> > Well the GRU uses follow_page() instead of get_user_pages. Performance is 
> > a major issue for the GRU. 
> 
> Worse, the GRU takes its TLB faults from within an interrupt so we
> use follow_page to prevent going to sleep.  That said, I think we
> could probably use follow_page() with FOLL_GET set to accomplish the
> requirements of mmu_notifier invalidate_range call.  Doesn't look too
> promising for hugetlb pages.

There may be no need to with the range_start/end scheme. The driver can 
have its own lock to make follow page secure. The lock needs to serialize 
the follow_page handler and the range_start/end calls as well as the 
invalidate_page callouts. I think that avoids the need for 
get_user_pages().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
