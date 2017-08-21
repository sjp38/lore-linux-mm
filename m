Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 911FF280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 09:08:56 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id r79so13423166wrb.0
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 06:08:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y46si11386589edd.121.2017.08.21.06.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Aug 2017 06:08:55 -0700 (PDT)
Date: Mon, 21 Aug 2017 09:08:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: memcg Can't context between v1 and v2 because css->refcnt not
 released
Message-ID: <20170821130848.GB1371@cmpxchg.org>
References: <CADK2BfzM9V=C3Kk6v714K3NVX58Q6pEaAMiHDGSyr6PakC2O=w@mail.gmail.com>
 <20170810071059.GC23863@dhcp22.suse.cz>
 <CADK2BfwC3WDGwoDPSjX1UpwP-4fDz5fSBjdENbxn5XQL8y3K3A@mail.gmail.com>
 <20170810081920.GG23863@dhcp22.suse.cz>
 <CADK2BfxJim8MvLPY497a+JAK2t9OTq+f1BY0o4qK0ihaWsoEMQ@mail.gmail.com>
 <CADK2BfzarAEQz=_Um23mywmdRvhNbe5OL_7k13XD3D5==nn0qg@mail.gmail.com>
 <CADK2Bfwxp3gSDrYXAxhgoYne2T=1_RyPXqQt_cGHz86dfWgsqg@mail.gmail.com>
 <20170810103405.GL23863@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170810103405.GL23863@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: wang Yu <yuwang668899@gmail.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 10, 2017 at 12:34:06PM +0200, Michal Hocko wrote:
> [restoring the CC list]
> 
> On Thu 10-08-17 17:57:38, wang Yu wrote:
> > 2017-08-10 17:28 GMT+08:00 wang Yu <yuwang668899@gmail.com>:
> [...]
> > > after drop caches, memory.stat  shows not pages belong the group, but
> > > memory.usage_in_bytes not zero, so maybe other pages
> > > has wrong to belong this group
> >
> > after drop cache, there maybe have kmem pages ,e.g. slab
> > it can't free both drop cache or tasks free,
> > so back this problem, without mem_cgroup_reparent_charges,
> > cgroup v1 can't umount , and cgroup v2 can't mount
> 
> Ohh, right. It is true that there is no explicit control over kmem page
> life time. I am afraid this is something non-trivial to address though.
> I am not sure swithing between cgroup versions is a strong enough use
> case to implement something like that but you can definitely try to do
> that.

Pretty much.

The idea was being able to switch after bootup to make interaction
with the init system easier (automatic mounts etc.), not that you can
switch back and forth between using v1 and v2 controllers.

Once the controller has been used and accumulated state, switching
controller versions is no longer supported.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
