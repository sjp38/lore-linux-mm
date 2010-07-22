Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3ED996B024D
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 13:39:25 -0400 (EDT)
Date: Thu, 22 Jul 2010 19:39:20 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUGFIX][PATCH] Fix false positive BUG_ON in
 __page_set_anon_rmap
Message-ID: <20100722173920.GI24928@random.random>
References: <20100722164118.d500b850.kamezawa.hiroyu@jp.fujitsu.com>
 <4C4844BC.4090709@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C4844BC.4090709@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 09:16:44AM -0400, Rik van Riel wrote:
> On 07/22/2010 03:41 AM, KAMEZAWA Hiroyuki wrote:
> > Rik, how do you think ?
> >
> > ==
> > From: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Problem: wrong BUG_ON() in  __page_set_anon_rmap().
> > Kernel version: mmotm-0719
> 
> > Description:
> >    Even if SwapCache is fully unmapped and mapcount goes down to 0,
> >    page->mapping is not cleared and will remain on memory until kswapd or some
> >    finds it. If a thread cause a page fault onto such "unmapped-but-not-discarded"
> >    swapcache, it will see a swap cache whose mapcount is 0 but page->mapping has a
> >    valid value.
> >
> >    When it's reused at do_swap_page(), __page_set_anon_rmap() is called with
> >    "exclusive==1" and hits BUG_ON(). But this BUG_ON() is wrong. Nothing bad
> >    with rmapping a page which has page->mapping isn't 0.
> 
> Yes, you are absolutely right.
> 

I already noticed the problem when I merged your patch in aa.git
(before it would only be exclusive=0 in do_swap_page so it wasn't a
false positive), and I fixed it this way:

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commitdiff;h=2fe4f42f0f17498984b3f86b2339d583004b45de;hp=ffd146080305632406d97c7f6f984a648854d755

So I retained the BUG_ON for the real page_add_anon_rmap. Maybe not
worth it but you can have a look at my solution if you're interested
to retain it too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
