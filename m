Date: Sat, 21 Aug 2004 13:56:24 +0900 (JST)
Message-Id: <20040821.135624.74737461.taka@valinux.co.jp>
Subject: Re: [Lhms-devel] Re: [RFC] free_area[] bitmap elimination [0/3]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040821025543.GS11200@holomorphy.com>
References: <4126B3F9.90706@jp.fujitsu.com>
	<20040821025543.GS11200@holomorphy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: wli@holomorphy.com, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hello,

I also impressed by your patch.

In my understanding, the patch assumes that size of mem_map[] in each
zone must be multiple of 2^MAX_ORDER, right?
But it doesn't seem it's a big problem, as we can just allocate extra
mem_map[] to round up if it isn't.

> On Sat, Aug 21, 2004 at 11:31:21AM +0900, Hiroyuki KAMEZAWA wrote:
> > This patch removes bitmap from buddy allocator used in
> > alloc_pages()/free_pages() in the kernel 2.6.8.1.
> > Currently, Linux's page allocator uses bitmaps to record an order
> > of a free page.
> > This patch removes bitmap from buddy allocator, and uses
> > page->private field to record an order of a page.
> > My purpose is to reduce complexity of buddy allocator, when we want to
> > hotplug memory. For memory hotplug, we have to resize memory management
> > structures. Major two of them are mem_map and bitmap.If this patch removes
> > bitmap from buddy allocator, resizeing bitmap will be needless.
> > I tested this patch on my small PC box(Celeron900MHz,256MB memory)
> > and a server machine(Xeon x 2, 4GB memory).
> 
> Complexity maybe. But one serious issue this addresses beyond the needs
> of hotplug memory is that the buddy bitmaps are a heavily random-access
> data structures not used elsewhere. Consolidating them into the page
> structures should improve cache locality and motivate this patch beyond
> just the needs of hotplug memory. Furthermore, the patch also reduces
> the kernel's overall memory footprint by a small amount.

Agreed.

> However, I'm concerned about the effectiveness of this specific
> algorithm for coalescing. A more detailed description may help explain
> why the effectiveness of coalescing is preserved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
