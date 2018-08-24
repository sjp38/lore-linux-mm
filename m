Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E602B6B305D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:42:29 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id y135-v6so2166438oie.11
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 08:42:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w10-v6si5579842oig.308.2018.08.24.08.42.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 08:42:28 -0700 (PDT)
Date: Fri, 24 Aug 2018 08:42:11 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v2 1/3] mm: rework memcg kernel stack accounting
Message-ID: <20180824154208.GA23633@tower.DHCP.thefacebook.com>
References: <20180821213559.14694-1-guro@fb.com>
 <20180822141213.GO29735@dhcp22.suse.cz>
 <20180823162347.GA22650@tower.DHCP.thefacebook.com>
 <20180824125052.GA13774@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180824125052.GA13774@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Andy Lutomirski <luto@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Tejun Heo <tj@kernel.org>, Shakeel Butt <shakeelb@google.com>

On Fri, Aug 24, 2018 at 08:50:52AM -0400, Johannes Weiner wrote:
> On Thu, Aug 23, 2018 at 09:23:50AM -0700, Roman Gushchin wrote:
> > On Wed, Aug 22, 2018 at 04:12:13PM +0200, Michal Hocko wrote:
> > > On Tue 21-08-18 14:35:57, Roman Gushchin wrote:
> > > > @@ -248,9 +253,20 @@ static unsigned long *alloc_thread_stack_node(struct task_struct *tsk, int node)
> > > >  static inline void free_thread_stack(struct task_struct *tsk)
> > > >  {
> > > >  #ifdef CONFIG_VMAP_STACK
> > > > -	if (task_stack_vm_area(tsk)) {
> > > > +	struct vm_struct *vm = task_stack_vm_area(tsk);
> > > > +
> > > > +	if (vm) {
> > > >  		int i;
> > > >  
> > > > +		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
> > > > +			mod_memcg_page_state(vm->pages[i],
> > > > +					     MEMCG_KERNEL_STACK_KB,
> > > > +					     -(int)(PAGE_SIZE / 1024));
> > > > +
> > > > +			memcg_kmem_uncharge(vm->pages[i],
> > > > +					    compound_order(vm->pages[i]));
> > > 
> > > when do we have order > 0 here?
> > 
> > I guess, it's not possible, but hard-coded 1 looked a bit crappy.
> > Do you think it's better?
> 
> Yes, specifying the known value (order 0) is much better. I asked
> myself the same question as Michal: we're walking through THREAD_SIZE
> in PAGE_SIZE steps, how could it possibly be a higher order page?
> 
> It adds an unnecessary branch to the code and the reader's brain.

Fair enough. Will switch over hard-coded order 0 in v3.

Thanks!
