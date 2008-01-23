Date: Wed, 23 Jan 2008 04:52:47 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080123105246.GG26420@sgi.com>
References: <478F9C9C.7070500@qumranet.com> <20080117193252.GC24131@v2.random> <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <479716AD.5070708@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <479716AD.5070708@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 23, 2008 at 12:27:57PM +0200, Avi Kivity wrote:
>> The approach with the export notifier is page based not based on the
>> mm_struct. We only need a single page count for a page that is exported to
>> a number of remote instances of linux. The page count is dropped when all
>> the remote instances have unmapped the page.
>
> That won't work for kvm.  If we have a hundred virtual machines, that means
> 99 no-op notifications.

But 100 callouts holding spinlocks will not work for our implementation
and even if the callouts are made with spinlocks released, we would very
strongly prefer a single callout which messages the range to the other
side.

> Also, our rmap key for finding the spte is keyed on (mm, va).  I imagine
> most RDMA cards are similar.

For our RDMA rmap, it is based upon physical address.

>> There is only the need to walk twice for pages that are marked Exported.
>> And the double walk is only necessary if the exporter does not have its
>> own rmap. The cross partition thing that we are doing has such an rmap and
>> its a matter of walking the exporters rmap to clear out the external
>> references and then we walk the local rmaps. All once.
>>
>
> The problem is that external mmus need a reverse mapping structure to
> locate their ptes.  We can't expand struct page so we need to base it on mm
> + va.

Our rmap takes a physical address and turns it into mm+va.

> Can they wait on that bit?

PageLocked(page) should work, right?  We already have a backoff
mechanism so we expect to be able to adapt it to include a
PageLocked(page) check.


Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
