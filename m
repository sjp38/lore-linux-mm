Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 509726B004D
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 03:27:03 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o228R0pw008002
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 2 Mar 2010 17:27:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C371045DE60
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:26:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 94A2D45DE6F
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:26:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AA051DB8041
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:26:59 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DF06E18004
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 17:26:55 +0900 (JST)
Date: Tue, 2 Mar 2010 17:23:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-Id: <20100302172316.b959b04c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100302080056.GA1548@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100302092309.bff454d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100302080056.GA1548@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Mar 2010 09:01:58 +0100
Andrea Righi <arighi@develer.com> wrote:

> On Tue, Mar 02, 2010 at 09:23:09AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon,  1 Mar 2010 22:23:40 +0100
> > Andrea Righi <arighi@develer.com> wrote:
> > 
> > > Apply the cgroup dirty pages accounting and limiting infrastructure to
> > > the opportune kernel functions.
> > > 
> > > Signed-off-by: Andrea Righi <arighi@develer.com>
> > 
> > Seems nice.
> > 
> > Hmm. the last problem is moving account between memcg.
> > 
> > Right ?
> 
> Correct. This was actually the last item of the TODO list. Anyway, I'm
> still considering if it's correct to move dirty pages when a task is
> migrated from a cgroup to another. Currently, dirty pages just remain in
> the original cgroup and are flushed depending on the original cgroup
> settings. That is not totally wrong... at least moving the dirty pages
> between memcgs should be optional (move_charge_at_immigrate?).
> 

My concern is 
 - migration between memcg is already suppoted
    - at task move
    - at rmdir

Then, if you leave DIRTY_PAGE accounting to original cgroup,
the new cgroup (migration target)'s Dirty page accounting may
goes to be negative, or incorrect value. Please check FILE_MAPPED
implementation in __mem_cgroup_move_account()

As
       if (page_mapped(page) && !PageAnon(page)) {
                /* Update mapped_file data for mem_cgroup */
                preempt_disable();
                __this_cpu_dec(from->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
                __this_cpu_inc(to->stat->count[MEM_CGROUP_STAT_FILE_MAPPED]);
                preempt_enable();
        }
then, FILE_MAPPED never goes negative.


Thanks,
-Kame

> Thanks for your ack and the detailed review!
> 
> -Andrea
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
