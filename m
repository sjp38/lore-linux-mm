Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8CF696B2E8D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 03:52:03 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b25-v6so3265455eds.17
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 00:52:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 7-v6si5714539edp.312.2018.08.24.00.52.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 00:52:02 -0700 (PDT)
Date: Fri, 24 Aug 2018 09:52:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: rework memcg kernel stack accounting
Message-ID: <20180824075201.GZ29735@dhcp22.suse.cz>
References: <20180821213559.14694-1-guro@fb.com>
 <20180822141213.GO29735@dhcp22.suse.cz>
 <20180823162347.GA22650@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823162347.GA22650@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>, Shakeel Butt <shakeelb@google.com>

On Thu 23-08-18 09:23:50, Roman Gushchin wrote:
> On Wed, Aug 22, 2018 at 04:12:13PM +0200, Michal Hocko wrote:
[...]
> > > @@ -248,9 +253,20 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> > >  static inline void free_thread_stack(struct task_struct *tsk)
> > >  {
> > >  #ifdef CONFIG_VMAP_STACK
> > > -	if (task_stack_vm_area(tsk)) {
> > > +	struct vm_struct *vm = task_stack_vm_area(tsk);
> > > +
> > > +	if (vm) {
> > >  		int i;
> > >  
> > > +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
> > > +			mod_memcg_page_state(vm->pages[i],
> > > +					     MEMCG_KERNEL_STACK_KB,
> > > +					     -(int)(PAGE_SIZE / 1024));
> > > +
> > > +			memcg_kmem_uncharge(vm->pages[i],
> > > +					    compound_order(vm->pages[i]));
> > 
> > when do we have order > 0 here?
> 
> I guess, it's not possible, but hard-coded 1 looked a bit crappy.
> Do you think it's better?

I guess you meant 0 here. Well, I do not mind, I was just wondering
whether I am missing something.
-- 
Michal Hocko
SUSE Labs
