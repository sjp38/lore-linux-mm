Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2DC2D6B0055
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 04:26:17 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n778QNZP002288
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 7 Aug 2009 17:26:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E9AC45DE50
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 17:26:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4246145DE4F
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 17:26:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 298F31DB8037
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 17:26:23 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B3E731DB8042
	for <linux-mm@kvack.org>; Fri,  7 Aug 2009 17:26:19 +0900 (JST)
Date: Fri, 7 Aug 2009 17:24:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-Id: <20090807172425.8554da30.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <661de9470908070054l2fa99ac6w6cac2be63cd5d91f@mail.gmail.com>
References: <4A7AC201.4010202@redhat.com>
	<4A7AD6EB.9090208@redhat.com>
	<20090807120857.5BE2.A69D9226@jp.fujitsu.com>
	<661de9470908070054l2fa99ac6w6cac2be63cd5d91f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Aug 2009 13:24:34 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> On Fri, Aug 7, 2009 at 8:41 AM, KOSAKI
> Motohiro<kosaki.motohiro@jp.fujitsu.com> wrote:
> > Current memcgroup logic also use recent_scan/recent_rotate statistics.
> > Isn't it enought?
> 
> I don't understand the context, I'll look at the problem when I am
> back (I am away from work for the next few days).
> 
Brief summary: (please point out if not correct)

prepare a memcg with
	memory.limit_in_bytex=128MB

Run kvm on it, and use apps, those working-set is near to 256MB (then, heavy swap)
In this case,
  - Anon memory are swapped-out even while there are file caches.
    Especially, a page for stack which is frequently accessed can be
    easily swapped out, again and again.

One of reasone is a recent change as:
"a page mapped with VM_EXEC is not pageout even if no reference"

Without memcg, a user can use Gigabytes of memory, above change
is very welcomed.

Then, current point is "how we can handle this case without bad effect".

One possibility I wonder is this is a problem of configuration mistake.
setting memory.memsw.limit_in_bytes to be proper value may change bahavior.
But it seems just a workaround.

Can't we find algorithmic/heuristic way to avoid too much swap-out ?
I think memcg can check # of swap-ins, but now, we don't have a tag
to see the sign of "recently swapped-out page is reused" case or
executable file pages are too much.

I wonder we can comapre
    # of pageouted file-caches v.s. # of swapout anon.
and keeping  "# of pageouted file-caches < # of swapout anon." (or use swappiness)
This state can be checked by recalim_stat. (per memcg)
Hmm?

I'm sorry I'll be on a trip Aug/11-Aug/17 and response will be delayed.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
