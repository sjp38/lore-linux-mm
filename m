Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DCA46B0305
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 08:21:43 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 26so136690291pgy.6
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:21:43 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id m63si22214815pld.15.2016.12.20.05.21.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 05:21:41 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id g1so10101947pgn.0
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 05:21:41 -0800 (PST)
Date: Tue, 20 Dec 2016 23:21:22 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Message-ID: <20161220232122.62c8196e@roar.ozlabs.ibm.com>
In-Reply-To: <20161220125825.hfwyzy2mzc4lna7x@techsingularity.net>
References: <20161219225826.F8CB356F@viggo.jf.intel.com>
	<CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
	<156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com>
	<20161220123113.1e1de7b0@roar.ozlabs.ibm.com>
	<20161220125825.hfwyzy2mzc4lna7x@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, swhiteho@redhat.com, luto@kernel.org, agruenba@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On Tue, 20 Dec 2016 12:58:25 +0000
Mel Gorman <mgorman@techsingularity.net> wrote:

> On Tue, Dec 20, 2016 at 12:31:13PM +1000, Nicholas Piggin wrote:
> > On Mon, 19 Dec 2016 16:20:05 -0800
> > Dave Hansen <dave.hansen@linux.intel.com> wrote:
> >   
> > > On 12/19/2016 03:07 PM, Linus Torvalds wrote:  
> > > >     +wait_queue_head_t *bit_waitqueue(void *word, int bit)
> > > >     +{
> > > >     +       const int __maybe_unused nid = page_to_nid(virt_to_page(word));
> > > >     +
> > > >     +       return __bit_waitqueue(word, bit, nid);
> > > > 
> > > > No can do. Part of the problem with the old coffee was that it did that
> > > > virt_to_page() crud. That doesn't work with the virtually mapped stack.     
> > > 
> > > Ahhh, got it.
> > > 
> > > So, what did you have in mind?  Just redirect bit_waitqueue() to the
> > > "first_online_node" waitqueues?
> > > 
> > > wait_queue_head_t *bit_waitqueue(void *word, int bit)
> > > {
> > >         return __bit_waitqueue(word, bit, first_online_node);
> > > }
> > > 
> > > We could do some fancy stuff like only do virt_to_page() for things in
> > > the linear map, but I'm not sure we'll see much of a gain for it.  None
> > > of the other waitqueue users look as pathological as the 'struct page'
> > > ones.  Maybe:
> > > 
> > > wait_queue_head_t *bit_waitqueue(void *word, int bit)
> > > {
> > > 	int nid
> > > 	if (word >= VMALLOC_START) /* all addrs not in linear map */
> > > 		nid = first_online_node;
> > > 	else
> > > 		nid = page_to_nid(virt_to_page(word));
> > >         return __bit_waitqueue(word, bit, nid);
> > > }  
> > 
> > I think he meant just make the page_waitqueue do the per-node thing
> > and leave bit_waitqueue as the global bit.
> >   
> 
> I'm pressed for time but at a glance, that might require a separate
> structure of wait_queues for page waitqueue. Most users of bit_waitqueue
> are not operating with pages. The first user is based on a word inside
> a block_device for example. All non-page users could assume node-0.

Yes it would require something or other like that. Trivial to keep things
balanced (if not local) over nodes by take a simple hash of the virtual
address to spread over the nodes. Or just keep using this separate global
table for the bit_waitqueue...

But before Linus grumps at me again, let's try to do the waitqueue
avoidance bit first before we worry about that :)

> It
> shrinks the available hash table space but as before, maybe collisions
> are not common enough to actually matter. That would be worth checking
> out. Alternatively, careful auditing to pick a node when it's known it's
> safe to call virt_to_page may work but it would be fragile.
> 
> Unfortunately I won't be able to review or test any patches until January
> 3rd after I'm back online properly. Right now, I have intermittent internet
> access at best. During the next 4 days, I know I definitely will not have
> any internet access.
> 
> The last time around, there were three patch sets to avoid the overhead for
> pages in particular. One was dropped (mine, based on Nick's old work) as
> it was too complicated. Peter had some patches but after enough hammering
> it failed due to a missed wakup that I didn't pin down before having to
> travel to a conference.
> 
> I hadn't tested Nick's prototype although it looked fine because others
> reviewed it before I looked and I was waiting for another version to
> appear. If one appears, I'll take a closer look and bash it across a few
> machines to see if it has any lost wakeup problems.
> 

Sure I'll respin it this week.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
