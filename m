Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 5891B6B02A3
	for <linux-mm@kvack.org>; Tue, 27 Jul 2010 22:40:21 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6S2eHxs021698
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 28 Jul 2010 11:40:18 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 19B0D45DE4E
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:40:17 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E427B45DE4F
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:40:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id ADDE31DB8016
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:40:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 47DC31DB8013
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 11:40:16 +0900 (JST)
Date: Wed, 28 Jul 2010 11:35:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/7][memcg] cgroup arbitarary ID allocation
Message-Id: <20100728113529.f086716d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100728023027.GD12642@redhat.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165417.dacbe199.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728023027.GD12642@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 Jul 2010 22:30:27 -0400
Vivek Goyal <vgoyal@redhat.com> wrote:

> > Index: mmotm-2.6.35-0719/Documentation/cgroups/cgroups.txt
> > ===================================================================
> > --- mmotm-2.6.35-0719.orig/Documentation/cgroups/cgroups.txt
> > +++ mmotm-2.6.35-0719/Documentation/cgroups/cgroups.txt
> > @@ -621,6 +621,15 @@ and root cgroup. Currently this will onl
> >  the default hierarchy (which never has sub-cgroups) and a hierarchy
> >  that is being created/destroyed (and hence has no sub-cgroups).
> >  
> > +void custom_id(struct cgroup_subsys *ss, struct cgroup *cgrp)
> > +
> > +Called at assigning a new ID to cgroup subsystem state struct. This
> > +is called when ss->use_id == true. If this function is not provided,
> > +a new ID is automatically assigned. If you enable ss->use_id,
> > +you can use css_lookup()  and css_get_next() to access "css" objects
> > +via IDs.
> > +
> 
> Couple of lines to explain why a subsystem would like to assign its
> own ids and not be happy with generic cgroup assigned id be helpful.
> In this case, I think you are using this id as index into array
> and want to control the index, hence you seem to be doing it.
> 
> But I am not sure again why do you want to control index?
> 

Now, the subsystem allocation/id-allocation order is

	->create()
	alloc_id.

Otherwise "id" of memory cgroup is just determined by the place in virtual-indexed
array. 
As
	memcg =	mem_cgroup_base + id

This "id" is determined at create().

If "id" is determined regardless of memory cgroup's placement, it's of no use.
My original design of css_id() allocates id in create() but it was moved to
generic part. So, this is expected change in my plan.

We have 2 choices.
	id = alloc_id()
	create(id)
or
	this patch.

Both are okay for me. But alloc id before create() may add some ugly rollback.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
