Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 463F16008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:26:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o734UsP6008653
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 3 Aug 2010 13:30:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B0D0B45DE5D
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:30:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DC8845DE4E
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:30:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 71A791DB803B
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:30:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 311241DB8038
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 13:30:54 +0900 (JST)
Date: Tue, 3 Aug 2010 13:25:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mm 5/5] memcg: use spinlock in page_cgroup instead of
 bit_spinlock
Message-Id: <20100803132559.9d0fcb69.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100803040645.GH3863@balbir.in.ibm.com>
References: <20100802191113.05c982e4.kamezawa.hiroyu@jp.fujitsu.com>
	<20100802192006.a395889a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100803040645.GH3863@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, vgoyal@redhat.com, m-ikeda@ds.jp.nec.com, gthelen@google.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2010 09:36:45 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-08-02 19:20:06]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > This patch replaces bit_spinlock with spinlock. In general,
> > spinlock has good functinality than bit_spin_lock and we should use
> > it if we have a room for it. In 64bit arch, we have extra 4bytes.
> > Let's use it.
> > expected effects:
> >  - use better codes.
> >  - ticket lock on x86-64
> >  - para-vitualization aware lock
> > etc..
> > 
> > Chagelog: 20090729
> >  - fixed page_cgroup_is_locked().
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > --
> 
> The additional space usage is a big concern, I think saving space
> would be of highest priority. I understand the expected benefits, but
> a spinlock_t per page_cgroup is quite expensive at the moment. If
> anything I think it should be a config option under CONFIG_DEBUG or
> something else to play with and see the side effects.
> 

Hmm. As I already wrote, packing id to flags is not easy. 
leave 4 bytes space _pad for a while and drop this patch ?

I don't like to add CONFIG_DEBUG in this core.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
