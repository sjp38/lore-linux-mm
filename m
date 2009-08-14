Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5106B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 05:12:00 -0400 (EDT)
Date: Fri, 14 Aug 2009 11:10:55 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090814091055.GA29338@cmpxchg.org>
References: <20090807121443.5BE5.A69D9226@jp.fujitsu.com> <20090812074820.GA29631@localhost> <4A82D24D.6020402@redhat.com> <20090813010356.GA7619@localhost> <4A843565.3010104@redhat.com> <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com> <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A850F4A.9020507@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 10:16:26AM +0300, Avi Kivity wrote:
> On 08/14/2009 12:16 AM, Johannes Weiner wrote:
> >
> >>- do not ignore the referenced bit
> >>- if you see a run of N pages which all have the referenced bit set, do
> >>swap one
> >>
> >>     
> >
> >But it also means destroying the LRU order.
> >
> >   
> 
> True, it would, but if we ignore the referenced bit, LRU order is really 
> FIFO.

For the active list, yes.  But it's not that we degrade to First Fault
First Out in a global scope, we still update the order from
mark_page_accessed() and by activating referenced pages in
shrink_page_list() etc.

So even with the active list being a FIFO, we keep usage information
gathered from the inactive list.  If we deactivate pages in arbitrary
list intervals, we throw this away.

And while global FIFO-based reclaim does not work too well, initial
fault order is a valuable hint in the aspect of referential locality
as the pages get used in groups and thus move around the lists in
groups.

Our granularity for regrouping decisions is pretty coarse, for
non-filecache pages it's basically 'referenced or not refrenced in the
last list round-trip', so it will take quite some time to regroup
pages that are used in truly similar intervals.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
