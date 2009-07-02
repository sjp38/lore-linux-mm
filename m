Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4191F6B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 19:49:36 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n62NvmAs026216
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 3 Jul 2009 08:57:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 656DD45DE57
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 08:57:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A1C345DE52
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 08:57:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFAAA1DB805B
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 08:57:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A26AEE08005
	for <linux-mm@kvack.org>; Fri,  3 Jul 2009 08:57:47 +0900 (JST)
Date: Fri, 3 Jul 2009 08:55:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: +
 memory-hotplug-alloc-page-from-other-node-in-memory-online.patch added to
 -mm tree
Message-Id: <20090703085556.fc711310.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0907020929060.32407@gentwo.org>
References: <1246497073.18688.28.camel@localhost.localdomain>
	<20090702102208.ff480a2d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090702144415.8B21.E1E9C6FF@jp.fujitsu.com>
	<alpine.DEB.1.10.0907020929060.32407@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, yakui <yakui.zhao@intel.com>, "Li, Shaohua" <shaohua.li@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 2 Jul 2009 09:31:04 -0400 (EDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 2 Jul 2009, Yasunori Goto wrote:
> 
> > However, I don't enough time for memory hotplug now,
> > and they are just redundant functions now.
> > If someone create new allocator (and unifying bootmem allocator),
> > I'm very glad. :-)
> 
> "Senior"ities all around.... A move like that would require serious
> commitment of time. None of us older developers can take that on it
> seems.
> 
> Do we need to accept that the zone and page metadata are living on another
> node?
> 
I don't think so. Someone should do. I just think I can't do it _now_.
(because I have more things to do for cgroup..)

And, if not node-hotplug, memmap is allocated from local memory if possible.
"We should _never_ allow fallback to other nodes or not" is problem ?
I think we should allow fallback.
About pgdat, zones, I hope they will be on-cache...

Maybe followings are necessary for allocating pgdat/zones from local node
at node-hotplug.

  a) Add new tiny functions to alloacate memory from not-initialized area.
     allocate pgdat/memmap from here if necessary.
  b) leave allocated memory from (a) as PG_reserved at onlining.
  c) There will be "not unpluggable" section after (b). We should show this to
     users.
  d) For removal, we have to keep precise trace of PG_reserved pages.
  e) vmemmap removal, which uses large page for vmemmap, is a problem.
     edges of section memmap is not aligned to large pages. Then we need
     some clever trick to handle this.

Allocationg memmap from its own section was an idea (I love this) but
IBM's 16MB memory section doesn't allow this.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
