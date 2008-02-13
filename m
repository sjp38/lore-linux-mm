Date: Wed, 13 Feb 2008 12:32:12 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <20080213194621.GD19742@mv.qlogic.com>
Message-ID: <Pine.LNX.4.64.0802131227200.20156@schroedinger.engr.sgi.com>
References: <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com>
 <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com>
 <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com>
 <20080213012638.GD31435@obsidianresearch.com>
 <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com>
 <20080213040905.GQ29340@mv.qlogic.com> <Pine.LNX.4.64.0802131052360.18472@schroedinger.engr.sgi.com>
 <20080213194621.GD19742@mv.qlogic.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Bell <christian.bell@qlogic.com>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, 13 Feb 2008, Christian Bell wrote:

> not always be in the thousands but you're still claiming scalability
> for a mechanism that essentially logs who accesses the regions.  Then
> there's the fact that reclaim becomes a collective communication
> operation over all region accessors.  Makes me nervous.

Well reclaim is not a very fast process (and we usually try to avoid it 
as much as possible for our HPC). Essentially its only there to allow 
shifts of processing loads and to allow efficient caching of application 
data.

> However, short of providing user-level notifications for pinned pages
> that are inadvertently released to the O/S, I don't believe that the
> patchset provides any significant added value for the HPC community
> that can't optimistically do RDMA demand paging.

We currently also run XPmem with pinning. Its great as long as you just 
run one load on the system. No reclaim ever iccurs.

However, if you do things that require lots of allocations etc etc then 
the page pinning can easily lead to livelock if reclaim is finally 
triggerd and also strange OOM situations since the VM cannot free any 
pages. So the main issue that is addressed here is reliability of pinned 
page operations. Better VM integration avoids these issues because we can 
unpin on request to deal with memory shortages.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
