Date: Fri, 20 Aug 2004 19:55:43 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC]  free_area[]  bitmap elimination [0/3]
Message-ID: <20040821025543.GS11200@holomorphy.com>
References: <4126B3F9.90706@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4126B3F9.90706@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LHMS <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 21, 2004 at 11:31:21AM +0900, Hiroyuki KAMEZAWA wrote:
> This patch removes bitmap from buddy allocator used in
> alloc_pages()/free_pages() in the kernel 2.6.8.1.
> Currently, Linux's page allocator uses bitmaps to record an order
> of a free page.
> This patch removes bitmap from buddy allocator, and uses
> page->private field to record an order of a page.
> My purpose is to reduce complexity of buddy allocator, when we want to
> hotplug memory. For memory hotplug, we have to resize memory management
> structures. Major two of them are mem_map and bitmap.If this patch removes
> bitmap from buddy allocator, resizeing bitmap will be needless.
> I tested this patch on my small PC box(Celeron900MHz,256MB memory)
> and a server machine(Xeon x 2, 4GB memory).

Complexity maybe. But one serious issue this addresses beyond the needs
of hotplug memory is that the buddy bitmaps are a heavily random-access
data structures not used elsewhere. Consolidating them into the page
structures should improve cache locality and motivate this patch beyond
just the needs of hotplug memory. Furthermore, the patch also reduces
the kernel's overall memory footprint by a small amount.

However, I'm concerned about the effectiveness of this specific
algorithm for coalescing. A more detailed description may help explain
why the effectiveness of coalescing is preserved.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
