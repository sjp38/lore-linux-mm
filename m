Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 305D66B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 02:31:29 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 74so3069550oty.15
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 23:31:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u189si4894518oif.464.2017.12.19.23.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 23:31:28 -0800 (PST)
Date: Wed, 20 Dec 2017 08:31:21 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Message-ID: <20171220083121.4aaa8a2a@redhat.com>
In-Reply-To: <75f514a6-8121-7d5f-4b6a-7e68d8f226a8@oracle.com>
References: <rao.shoaib@oracle.com>
	<1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
	<20171219214158.353032f0@redhat.com>
	<75f514a6-8121-7d5f-4b6a-7e68d8f226a8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, linux-mm@kvack.org, brouer@redhat.com


On Tue, 19 Dec 2017 13:20:43 -0800 Rao Shoaib <rao.shoaib@oracle.com> wrote:

> On 12/19/2017 12:41 PM, Jesper Dangaard Brouer wrote:
> > On Tue, 19 Dec 2017 09:52:27 -0800 rao.shoaib@oracle.com wrote:
> >  
> >> +/* Main RCU function that is called to free RCU structures */
> >> +static void
> >> +__rcu_bulk_free(struct rcu_head *head, rcu_callback_t func, int cpu, bool lazy)
> >> +{
> >> +	unsigned long offset;
> >> +	void *ptr;
> >> +	struct rcu_bulk_free *rbf;
> >> +	struct rcu_bulk_free_container *rbfc = NULL;
> >> +
> >> +	rbf = this_cpu_ptr(&cpu_rbf);
> >> +
> >> +	if (unlikely(!rbf->rbf_init)) {
> >> +		spin_lock_init(&rbf->rbf_lock);
> >> +		rbf->rbf_cpu = smp_processor_id();
> >> +		rbf->rbf_init = true;
> >> +	}
> >> +
> >> +	/* hold lock to protect against other cpu's */
> >> +	spin_lock_bh(&rbf->rbf_lock);  
> >
> > I'm not sure this will be faster.  Having to take a cross CPU lock here
> > (+ BH-disable) could cause scaling issues.   Hopefully this lock will
> > not be used intensively by other CPUs, right?
> >
[...]
> 
> As Paul has pointed out the lock is a per-cpu lock, the only reason for 
> another CPU to access this lock is if the rcu callbacks run on a 
> different CPU and there is nothing the code can do to avoid that but 
> that should be rare anyways.

(loop in Paul's comment)
On Tue, 19 Dec 2017 12:56:29 -0800
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> Isn't this lock in a per-CPU object?  It -might- go cross-CPU in response
> to CPU-hotplug operations, but that should be rare.

Point taken.  If this lock is very unlikely to be taken on another CPU
then I withdraw my performance concerns (the cacheline can hopefully
stay in Modified(M) state on this CPU, and all other CPUs will have in
in Invalid(I) state based on MESI cache coherence protocol view[1]).

The lock's atomic operation does have some overhead, and _later_ if we
could get fancy and use seqlock (include/linux/seqlock.h) to remove
that.

[1] https://en.wikipedia.org/wiki/MESI_protocol
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
