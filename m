Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id C41576B0037
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 21:38:53 -0400 (EDT)
Message-ID: <1375839529.2134.50.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH 17/18] mm, hugetlb: retry if we fail to allocate a
 hugepage with use_reserve
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Tue, 06 Aug 2013 18:38:49 -0700
In-Reply-To: <20130807010312.GA17110@voom.redhat.com>
References: <1375075929-6119-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <1375075929-6119-18-git-send-email-iamjoonsoo.kim@lge.com>
	 <20130729072823.GD29970@voom.fritz.box> <20130731053753.GM2548@lge.com>
	 <20130803104302.GC19115@voom.redhat.com> <20130805073647.GD27240@lge.com>
	 <1375834724.2134.49.camel@buesod1.americas.hpqcorp.net>
	 <20130807010312.GA17110@voom.redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>

On Wed, 2013-08-07 at 11:03 +1000, David Gibson wrote:
> On Tue, Aug 06, 2013 at 05:18:44PM -0700, Davidlohr Bueso wrote:
> > On Mon, 2013-08-05 at 16:36 +0900, Joonsoo Kim wrote:
> > > > Any mapping that doesn't use the reserved pool, not just
> > > > MAP_NORESERVE.  For example, if a process makes a MAP_PRIVATE mapping,
> > > > then fork()s then the mapping is instantiated in the child, that will
> > > > not draw from the reserved pool.
> > > > 
> > > > > Should we ensure them to allocate the last hugepage?
> > > > > They map a region with MAP_NORESERVE, so don't assume that their requests
> > > > > always succeed.
> > > > 
> > > > If the pages are available, people get cranky if it fails for no
> > > > apparent reason, MAP_NORESERVE or not.  They get especially cranky if
> > > > it sometimes fails and sometimes doesn't due to a race condition.
> > > 
> > > Hello,
> > > 
> > > Hmm... Okay. I will try to implement another way to protect race condition.
> > > Maybe it is the best to use a table mutex :)
> > > Anyway, please give me a time, guys.
> > 
> > So another option is to take the mutex table patchset for now as it
> > *does* improve things a great deal, then, when ready, get rid of the
> > instantiation lock all together.
> 
> We still don't have a solid proposal for doing that. Joonsoo Kim's
> patchset misses cases (non reserved mappings).  I'm also not certain
> there aren't a few edge cases which can lead to even reserved mappings
> failing, and if that happens the patches will lead to livelock.
> 

Exactly, which is why I suggest minimizing the lock contention until we
do have such a proposal.

> Getting rid of the instantiation mutex is a lot harder than it appears.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
