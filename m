Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 83A418E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 13:59:16 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x67so828198pfk.16
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 10:59:16 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n20si19490054plp.294.2019.01.07.10.59.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 10:59:15 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x07Ii0Dt131076
	for <linux-mm@kvack.org>; Mon, 7 Jan 2019 13:59:14 -0500
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2pv9atkfba-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Jan 2019 13:59:14 -0500
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 7 Jan 2019 18:59:13 -0000
Date: Mon, 7 Jan 2019 10:59:31 -0800
From: "Paul E. McKenney" <paulmck@linux.ibm.com>
Subject: Re: [PATCH] mm: kmemleak: Turn kmemleak_lock to spin lock and RCU
 primitives
Reply-To: paulmck@linux.ibm.com
References: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
 <20190104183715.GC187360@arrakis.emea.arm.com>
 <f923e9e9-ed73-5054-3d82-b2244c67a65e@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f923e9e9-ed73-5054-3d82-b2244c67a65e@windriver.com>
Message-Id: <20190107185931.GE1215@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: He Zhe <zhe.he@windriver.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, josh@joshtriplett.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 07, 2019 at 03:31:18PM +0800, He Zhe wrote:
> 
> 
> On 1/5/19 2:37 AM, Catalin Marinas wrote:
> > On Fri, Jan 04, 2019 at 10:29:13PM +0800, zhe.he@windriver.com wrote:
> >> It's not necessary to keep consistency between readers and writers of
> >> kmemleak_lock. RCU is more proper for this case. And in order to gain better
> >> performance, we turn the reader locks to RCU read locks and writer locks to
> >> normal spin locks.
> > This won't work.
> >
> >> @@ -515,9 +515,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
> >>  	struct kmemleak_object *object;
> >>  
> >>  	rcu_read_lock();
> >> -	read_lock_irqsave(&kmemleak_lock, flags);
> >>  	object = lookup_object(ptr, alias);
> >> -	read_unlock_irqrestore(&kmemleak_lock, flags);
> > The comment on lookup_object() states that the kmemleak_lock must be
> > held. That's because we don't have an RCU-like mechanism for removing
> > removing objects from the object_tree_root:
> >
> >>  
> >>  	/* check whether the object is still available */
> >>  	if (object && !get_object(object))
> >> @@ -537,13 +535,13 @@ static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int ali
> >>  	unsigned long flags;
> >>  	struct kmemleak_object *object;
> >>  
> >> -	write_lock_irqsave(&kmemleak_lock, flags);
> >> +	spin_lock_irqsave(&kmemleak_lock, flags);
> >>  	object = lookup_object(ptr, alias);
> >>  	if (object) {
> >>  		rb_erase(&object->rb_node, &object_tree_root);
> >>  		list_del_rcu(&object->object_list);
> >>  	}
> >> -	write_unlock_irqrestore(&kmemleak_lock, flags);
> >> +	spin_unlock_irqrestore(&kmemleak_lock, flags);
> > So here, while list removal is RCU-safe, rb_erase() is not.
> >
> > If you have time to implement an rb_erase_rcu(), than we could reduce
> > the locking in kmemleak.
> 
> Thanks, I really neglected that rb_erase is not RCU-safe here.
> 
> I'm not sure if it is practically possible to implement rb_erase_rcu. Here
> is my concern:
> In the code paths starting from rb_erase, the tree is tweaked at many
> places, in both __rb_erase_augmented and ____rb_erase_color. To my
> understanding, there are many intermediate versions of the tree
> during the erasion. In some of the versions, the tree is incomplete, i.e.
> some nodes(not the one to be deleted) are invisible to readers. I'm not
> sure if this is acceptable as an RCU implementation. Does it mean we
> need to form a rb_erase_rcu from scratch?
> 
> And are there any other concerns about this attempt?
> 
> Let me add RCU supporters Paul and Josh here. Your advice would be
> highly appreciated.

If updates and rebalancing are handled carefully, it can be made to work.
The classic paper by Kung and Lehman covers the rebalancing issues:
http://www.eecs.harvard.edu/~htk/publication/1980-tods-kung-lehman.pdf

							Thanx, Paul
