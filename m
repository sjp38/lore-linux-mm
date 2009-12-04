Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 768F26007B9
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 02:12:30 -0500 (EST)
Date: Fri, 4 Dec 2009 16:09:01 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH -mmotm 0/7] memcg: move charge at task migration
 (04/Dec)
Message-Id: <20091204160901.dac2e8bc.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204155317.2d570a55.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
	<20091204155317.2d570a55.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009 15:53:17 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 4 Dec 2009 14:46:09 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > Hi.
> > 
> > These are current patches of my move-charge-at-task-migration feature.
> > 
> > The biggest change from previous(19/Nov) version is improvement in performance.
> > 
> > I measured the elapsed time of "echo [pid] > <some path>/tasks" on KVM guest
> > with 4CPU/4GB(Xeon/3GHz) in three patterns:
> > 
> >   (1) / -> /00
> >   (2) /00 -> /01
> > 
> >   we don't need to call res_counter_uncharge against root, so (1) would be smaller
> >   than (2).
> > 
> >   (3) /00(setting mem.limit to half size of total) -> /01
> > 
> >   To compare the overhead of anon and swap.
> > 
> > In 19/Nov version:
> >        |  252M  |  512M  |   1G
> >   -----+--------+--------+--------
> >    (1) |  0.21  |  0.41  |  0.821
> >   -----+--------+--------+--------
> >    (2) |  0.43  |  0.85  |  1.71
> >   -----+--------+--------+--------
> >    (3) |  0.40  |  0.81  |  1.62
> >   -----+--------+--------+--------
> > 
> > In this version:
> >        |  252M  |  512M  |   1G
> >   -----+--------+--------+--------
> >    (1) |  0.15  |  0.30  |  0.60
> >   -----+--------+--------+--------
> >    (2) |  0.15  |  0.30  |  0.60
> >   -----+--------+--------+--------
> >    (3) |  0.22  |  0.44  |  0.89
> > 
> Nice !
> 
> > Please read patch descriptions for each patch([4/7],[7/7]) for details of
> > how and how much the patch improved the performance.
> > 
> >   [1/7] cgroup: introduce cancel_attach()
> >   [2/7] memcg: add interface to move charge at task migration
> >   [3/7] memcg: move charges of anonymous page
> >   [4/7] memcg: improbe performance in moving charge
> >   [5/7] memcg: avoid oom during moving charge
> >   [6/7] memcg: move charges of anonymous swap
> >   [7/7] memcg: improbe performance in moving swap charge
> > 
> > Current version supports only recharge of non-shared(mapcount == 1) anonymous pages
> > and swaps of those pages. I think it's enough as a first step.
> > 
> Hmm. shared swap entry (very rare one?) is moved ?
> 
Well, do you mean the charge of shared swap entry(IOW, swap entry with swap_count > 1)
is moved ? If so, no. I check swap_count in mem_cgroup_count_swap_user(see [6/7]),
and don't move the charge of it if it's shared.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
