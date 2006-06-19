Subject: Re: [RFC][PATCH] inactive_clean
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0606191308470.4203@schroedinger.engr.sgi.com>
References: <1150719606.28517.83.camel@lappy>
	 <Pine.LNX.4.64.0606190837450.1184@schroedinger.engr.sgi.com>
	 <1150740624.28517.108.camel@lappy>
	 <Pine.LNX.4.64.0606191202350.23422@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0606191509490.6565@cuia.boston.redhat.com>
	 <Pine.LNX.4.64.0606191223410.3925@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0606191526401.6565@cuia.boston.redhat.com>
	 <Pine.LNX.4.64.0606191257100.3993@schroedinger.engr.sgi.com>
	 <1150747501.28517.114.camel@lappy>
	 <Pine.LNX.4.64.0606191308470.4203@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 19 Jun 2006 22:46:10 +0200
Message-Id: <1150749971.28517.122.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, Nick Piggin <piggin@cyberone.com.au>, linux-mm <linux-mm@kvack.org>, Nikita Danilov <nikita@clusterfs.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2006-06-19 at 13:11 -0700, Christoph Lameter wrote:
> On Mon, 19 Jun 2006, Peter Zijlstra wrote:
> 
> > > Hmmm.. My counter patches add NR_ANON to count the number of anonymous 
> > > pages. These are all potentially dirty. If you throttle on NR_DIRTY + 
> > > NR_ANON then we may have the effect without this patch.
> > 
> > Sure, but what do you do to reach you threshold if there are not enough
> > mapped pages around to clean?
> 
> You reach the threshold and the writeout happens. So there are enough 
> clean pages available.

I think we look at the threshold from differ sides, what I meant was:
we want nr_clean > nr_wanted_clean, where nr_clean = nr_clean_anon +
nr_clean_mapped. Now nr_clean_mapped = nr_mapped - nr_dirty_mapped, what
if nr_mapped < nr_wanted_clean?

You need to increase nr_clean_anon to reach nr_wanted_clean.

> > At that point the only thing left is to make sure some anonymous pages
> > become clean, that is write them out to swap and have them sit around in
> > the swap cache.
> 
> Thats fine. The threshold just insures that you can write out the 
> anonymous pages.

But you need slightly more than just writeout, you need to create a
clean anonymous page, so you need to keep it around.

> > The next question is: 'which pages do I write out?', and there page
> > reclaim comes in; however are you only going to write out anonymous
> > pages and violate page order for file backed pages?
> 
> I would think that one would first write out dirty file backed pages.
> 
> What page order are you talking about?

LRU page order, and having a preference for file-backed pages breaks it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
