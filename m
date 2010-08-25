Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id E25386B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:21:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7P0P7lY007713
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Aug 2010 09:25:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3EE245DE55
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:25:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 680A345DD77
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:25:07 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A0951DB803B
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:25:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EBF321DB803A
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 09:25:06 +0900 (JST)
Date: Wed, 25 Aug 2010 09:20:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
Message-Id: <20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Aug 2010 17:09:25 -0700
Paul Menage <menage@google.com> wrote:

> On Fri, Aug 20, 2010 at 2:58 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > CC'ed to Paul Menage and Li Zefan.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > When cgroup subsystem use ID (ss->use_id==1), each css's ID is assigned
> > after successful call of ->create(). css_ID is tightly coupled with
> > css struct itself but it is allocated by ->create() call, IOW,
> > per-subsystem special allocations.
> >
> > To know css_id before creation, this patch adds id_attached() callback.
> > after css_ID allocation. This will be used by memory cgroup's quick lookup
> > routine.
> >
> > Maybe you can think of other implementations as
> > A  A  A  A - pass ID to ->create()
> > A  A  A  A or
> > A  A  A  A - add post_create()
> > A  A  A  A etc...
> > But when considering dirtiness of codes, this straightforward patch seems
> > good to me. If someone wants post_create(), this patch can be replaced.
> 
> I think I'd prefer the approach where any necessary css_ids are
> allocated prior to calling any create methods (which gives the
> additional advantage of removing the need to roll back partial
> creation of a cgroup in the event of alloc_css_id() failing) and then
> passed in to the create() method. The main cgroups framework would
> still be responsible for actually filling the css->id field with the
> allocated id.
> 

Hmm, sure. I'll change the ->create() interface.  O.K. ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
