Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D2DCF6B01F9
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:33:42 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2U6Xsmm024492
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 30 Mar 2010 15:33:54 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 093CD45DE55
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:33:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CF72145DE4F
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:33:53 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA5D2E3800B
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:33:53 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 49791E38004
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 15:33:53 +0900 (JST)
Date: Tue, 30 Mar 2010 15:29:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH(v2) -mmotm 2/2] memcg move charge of shmem at task
 migration
Message-Id: <20100330152958.0c31b8d5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100330144458.403b429c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120359.1c6a277d.nishimura@mxp.nes.nec.co.jp>
	<20100329133645.e3bde19f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330103301.b0d20f7e.nishimura@mxp.nes.nec.co.jp>
	<20100330112301.f5bb49d7.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330114903.476af77e.nishimura@mxp.nes.nec.co.jp>
	<20100330121119.fcc7d45b.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330130648.ad559645.nishimura@mxp.nes.nec.co.jp>
	<20100330135159.025b9366.kamezawa.hiroyu@jp.fujitsu.com>
	<20100330050050.GA3308@balbir.in.ibm.com>
	<20100330143038.422459da.nishimura@mxp.nes.nec.co.jp>
	<20100330144458.403b429c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Mar 2010 14:44:58 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 30 Mar 2010 14:30:38 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > On Tue, 30 Mar 2010 10:30:50 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-30 13:51:59]:
> > > Yep, I tend to agree, but I need to take a closer look again at the
> > > patches. 
> > > 
> > I agree it would be more simple. I selected the current policy because
> > I was not sure whether we should move file caches(!tmpfs) with mapcount > 1,
> > and, IMHO, shared memory and file caches are different for users.
> > But it's O.K. for me to change current policy.
> > 
> 
> To explain what I think of, I wrote a patch onto yours. (Maybe overkill for explaination ;)
> 
> Summary.
> 
>  + adding move_anon, move_file, move_shmem information to move_charge_struct.
>  + adding hanlders for each pte types.
>  + checking # of referer should be divided to each type.
>    It's complicated to catch all cases in one "if" sentense.
>  + FILE pages will be moved if it's charged against "from". no mapcount check.
>    i.e. FILE pages should be moved even if it's not page-faulted.
>  + ANON pages will be moved if it's really private.
> 
> For widely shared FILE, "if it's charged against "from"" is enough good limitation.
> 
> 

Hmm....how about changing meanings of new flags ?

1 : a charge of page caches are moved. Page cache means cache of regular files
    and shared memory. But only privately mapped pages (mapcount==1) are moved.

2 : a charge of page caches are moved. Page cache means cache of regular files
    and shared memory. They are moved even if it's shared among processes.

When both of 1 and 2 are specified, "2" is used. Anonymous pages will not be
moved if it's shared.

Then, total view of user interface will be simple and I think this will allow
what you want.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
