Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 442788D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 09:15:04 -0500 (EST)
Date: Thu, 27 Jan 2011 15:14:51 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] memcg: prevent endless loop on huge page charge
Message-ID: <20110127141451.GA14512@cmpxchg.org>
References: <20110121153431.191134dd.kamezawa.hiroyu@jp.fujitsu.com>
 <20110121154430.70d45f15.kamezawa.hiroyu@jp.fujitsu.com>
 <20110127103438.GC2401@cmpxchg.org>
 <20110127134645.GA14309@cmpxchg.org>
 <20110127140024.GR14750@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110127140024.GR14750@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Gleb,

On Thu, Jan 27, 2011 at 04:00:24PM +0200, Gleb Natapov wrote:
> On Thu, Jan 27, 2011 at 02:46:45PM +0100, Johannes Weiner wrote:
> > The charging code can encounter a charge size that is bigger than a
> > regular page in two situations: one is a batched charge to fill the
> > per-cpu stocks, the other is a huge page charge.
> > 
> > This code is distributed over two functions, however, and only the
> > outer one is aware of huge pages.  In case the charging fails, the
> > inner function will tell the outer function to retry if the charge
> > size is bigger than regular pages--assuming batched charging is the
> > only case.  And the outer function will retry forever charging a huge
> > page.
> > 
> > This patch makes sure the inner function can distinguish between batch
> > charging and a single huge page charge.  It will only signal another
> > attempt if batch charging failed, and go into regular reclaim when it
> > is called on behalf of a huge page.
> > 
> Yeah, that is exactly the case I am debugging right now. Came up with
> different solution: pass page_size to __mem_cgroup_do_charge() and
> compare csize with page_size (not CHARGE_SIZE). Not sure which solution
> it more correct.

I guess it makes no difference, but using CHARGE_SIZE gets away
without adding another parameter to __mem_cgroup_do_charge().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
