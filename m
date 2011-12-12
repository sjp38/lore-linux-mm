Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 875F56B00BD
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 01:20:05 -0500 (EST)
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1323665304.22361.392.camel@sli10-conroe>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <alpine.DEB.2.00.1112020842280.10975@router.home>
	 <1323076965.16790.670.camel@debian>
	 <alpine.DEB.2.00.1112061259210.28251@chino.kir.corp.google.com>
	 <1323234673.22361.372.camel@sli10-conroe>
	 <alpine.DEB.2.00.1112062319010.21785@chino.kir.corp.google.com>
	 <1323657793.22361.383.camel@sli10-conroe>
	 <1323663251.16790.6115.camel@debian>
	 <1323664514.22361.385.camel@sli10-conroe>
	 <1323663921.16790.6118.camel@debian>
	 <1323665304.22361.392.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Dec 2011 14:17:13 +0800
Message-ID: <1323670633.16790.6131.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Li, Shaohua" <shaohua.li@intel.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <ak@linux.intel.com>

> > > > > With the per-cpu partial list, I didn't see any workload which is still
> > > > > suffering from the list lock, 
> > > > 
> > > > The merge error that you fixed in 3.2-rc1 for hackbench regression is
> > > > due to add slub to node partial head. And data of hackbench show node
> > > > partial is still heavy used in allocation. 
> > > The patch is already in base kernel, did you mean even with it you still
> > > saw the list locking issue with latest kernel?
> > > 
> > 
> > Yes, list_lock still hurt performance. It will be helpful if you can do
> > some optimize for it. 
> please post data and the workload. In my test, I didn't see the locking
> takes significant time with perf. the slub stat you posted in last mail
> shows most allocation goes the fast path.
> 

It is 'hackbench 100 process 2000' 

How it's proved there are not locking time on list_lock? 

Does the following profile can express sth on slub alloc with my
previous slub stat data?

113517 total                                      0.0164
 11065 unix_stream_recvmsg                        5.9425
 10862 copy_user_generic_string                 169.7188
  6011 __alloc_skb                               18.7844
  5857 __kmalloc_node_track_caller               14.3203
  5748 unix_stream_sendmsg                        5.4124
  4841 kmem_cache_alloc_node                     17.3513
  4494 skb_release_head_state                    34.0455
  3697 __slab_free                                5.3194


Actually, we know lock content is there, because any change on node
partial list may cause clear performance change on hackbench process
benchmark. But for direct evidence. Any debug may heavy press its using,
and make data unbelievable.  So, I'd like hear any suggestions to figure
out it clearly. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
