Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1A6008D0001
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 20:31:05 -0400 (EDT)
Subject: Re: [PATCH] vmscan: move referenced VM_EXEC pages to active list
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20101101134139.GA2104@barrios-desktop>
References: <1287787911-4257-1-git-send-email-msb@chromium.org>
	 <AANLkTinWp-M4S5EXz6-xJvHAnzdk96_5+d2OJVjCycsm@mail.gmail.com>
	 <1288497532.1945.21.camel@shli-laptop>
	 <20101101134139.GA2104@barrios-desktop>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 02 Nov 2010 08:31:10 +0800
Message-ID: <1288657870.8722.959.camel@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "wad@chromium.org" <wad@chromium.org>, "olofj@chromium.org" <olofj@chromium.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-01 at 21:41 +0800, Minchan Kim wrote:
> On Sun, Oct 31, 2010 at 11:58:52AM +0800, Shaohua Li wrote:
> > On Mon, 2010-10-25 at 06:52 +0800, Minchan Kim wrote:
> > > On Sat, Oct 23, 2010 at 7:51 AM, Mandeep Singh Baines <msb@chromium.org> wrote:
> > > > In commit 64574746, "vmscan: detect mapped file pages used only once",
> > > > Johannes Weiner, added logic to page_check_reference to cycle again
> > > > used once pages.
> > > >
> > > > In commit 8cab4754, "vmscan: make mapped executable pages the first
> > > > class citizen", Wu Fengguang, added logic to shrink_active_list which
> > > > protects file-backed VM_EXEC pages by keeping them in the active_list if
> > > > they are referenced.
> > > >
> > > > This patch adds logic to move such pages from the inactive list to the
> > > > active list immediately if they have been referenced. If a VM_EXEC page
> > > > is seen as referenced during an inactive list scan, that reference must
> > > > have occurred after the page was put on the inactive list. There is no
> > > > need to wait for the page to be referenced again.
> > > >
> > > > Change-Id: I17c312e916377e93e5a92c52518b6c829f9ab30b
> > > > Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
> > > 
> > > It seems to be similar to http://www.spinics.net/lists/linux-mm/msg09617.html.
> > > I don't know what it is going. Shaohua?
> > I should have sent the test result earlier but was offlined last week.
> > Here is my test result:
> > kernel1: base kernel + revert commit 8cab4754
> > kernel2: base kernel
> > kernel3: base kernel + my patch (similar like Mandeep's)
> > I'm using Fengguang's test of commit 8cab4754. But the test result isn't
> > stable, sometimes one kernel above has more majfault, but sometimes the
> > kernel has less majfault. This is true for all the above kernels.
> > Apparently kernel behavior changes (guess because of commit 64574746),
> > and vm_exec protect (even the vm_exec protect in active list) is not
> > important now with new kernel in Fengguang's test suite.
> 
> Tend to agree.
> When I saw 64574746, I doubted 8cab4754's effectiveness.
> When we reviewed 8cab4754, there were many discussion. 
> The thing I kept my mind was a trick of VM_EXEC.
> Someone can whip LRU by VM_EXEC hack intentionally.
> Apparently, It's bad. 
> 
> > 
> > But on the other hand, if I add a new task into Fengguang's test suite.
> > The task produces a lot of used one file page read (sequential read a
> > large sparse file). Kernel2 has less majfault than kernel1, and kernel3
> > has even less majfault than kernel2, so kernel3 has best performance.
> > Basically the majfault number from kernel1 is 3x, kernel2 2x, kernel3
> > 1x. One issue is I'm afraid this isn't a typical desktop usage any more
> > (because of sequential read sparse file), so not sure if we can use this
> > test as a judgment to merge the patch.
> 
> We can't make sure desktop doesn't has such workload and server also can have
> such workload. I mean if it enhance VM by general POV, we can merge it enoughly.
> In your testcase, Removing VM_EXEC test(ie, kernel 2) doesn't have biased.
> It means it's not the best but not worst, either. 
> Although we can't get the best, we can remove VM_EXEC hack. It's not a bad deal.
> So how about removing VM_EXEC hack in this chance?
> 
> I hope we revert VM_EXEC hack in this chance.
> Of course, before we discuss it, we can need more and detail data.
> I hope you could help for the number.
I'm thinking if we should revert VM_EXEC hack too. The headache is we
need find a typical workload which can convince people and get number
under the workload. Fengguang's test case hasn't enough non vm_exec file
pages I think.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
