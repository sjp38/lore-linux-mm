Subject: Re: [PATCH] memory hotplug: run lru_add_drain_all() on each cpu
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20081207133450.53D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <1228482500.8392.15.camel@t60p>
	 <1228509818.12681.21.camel@nimitz>
	 <20081207133450.53D8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain
Date: Mon, 08 Dec 2008 08:56:28 -0500
Message-Id: <1228744588.22647.32.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, gerald.schaefer@de.ibm.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Sun, 2008-12-07 at 13:43 +0900, KOSAKI Motohiro wrote:
> CC to Lee Schermerhorn
> 
> 
> > On Fri, 2008-12-05 at 14:08 +0100, Gerald Schaefer wrote:
> > > 
> > > As explained above, the per-cpu pagevec layout should be independent
> > > from NUMA or UNEVICTABLE_LRU, so I guess the right thing to do here
> > > is completely remove the #ifdef as in the patch from Kosaki Motohiro
> > > (or at least replace it with a CONFIG_SMP as suggested by Kamezawa
> > > Hiroyuki).
> > 
> > Thanks for looking into it deeper.  That CONFIG_SMP thing really does
> > look like the right solution.
> 
> Lee, Could you read this thread and explain why you add ifdef CONFIG_UNEVICTABLE_LRU?
> I am not sure about that Dave's proposal is safe change. (but I guess he is right)

I added that back in Patch 17/25 "Mlocked Pages are
non-reclaimable" [before nonreclaimable became unevictable".  I did this
because "lru_add_drain_all()" was only used by numa code prior to this,
and was under #ifdef CONFIG_NUMA".  I called lru_add_drain_all() from
__mlock_vma_pages_range() [since removed] and I wanted the
nonreclaimable/unevictable mlocked pages feature to be independent of
numa.  So, I had to ensure that we defined the function for
nonreclaimable/unevictable lru as well as numa.

Now it appears that hotplug and memcg also depend on
lru_add_drain_all(), so making it depend on 'SMP looks reasonable to me.

Lee 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
