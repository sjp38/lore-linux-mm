Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DBDD28024C
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:30:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so69538839wmg.3
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:30:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j189si14451898wmj.143.2016.09.29.03.30.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Sep 2016 03:30:06 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8TASJE7034528
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:30:04 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25s01eb38s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 06:30:04 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 29 Sep 2016 04:30:03 -0600
Date: Thu, 29 Sep 2016 03:30:02 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Soft lockup in __slab_free (SLUB)
Reply-To: paulmck@linux.vnet.ibm.com
References: <57E8D270.8040802@kyup.com>
 <20160928053114.GC22706@js1304-P5Q-DELUXE>
 <57EB6DF5.2010503@kyup.com>
 <20160929014024.GA29250@js1304-P5Q-DELUXE>
 <20160929021100.GI14933@linux.vnet.ibm.com>
 <20160929123007.436e30d0@roar.ozlabs.ibm.com>
 <20160929024705.GK14933@linux.vnet.ibm.com>
 <20160929131329.0e21a8d4@roar.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929131329.0e21a8d4@roar.ozlabs.ibm.com>
Message-Id: <20160929103002.GM14933@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Nikolay Borisov <kernel@kyup.com>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, brouer@redhat.com

On Thu, Sep 29, 2016 at 01:13:29PM +1000, Nicholas Piggin wrote:
> On Wed, 28 Sep 2016 19:47:05 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Thu, Sep 29, 2016 at 12:30:07PM +1000, Nicholas Piggin wrote:
> > > On Wed, 28 Sep 2016 19:11:00 -0700
> > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:  
> > > > On Thu, Sep 29, 2016 at 10:40:24AM +0900, Joonsoo Kim wrote:  
> > > > > On Wed, Sep 28, 2016 at 10:15:01AM +0300, Nikolay Borisov wrote:    
> > > > > > 
> > > > > > I don't think it's an RCU problem per-se since ext4_i_callback is being
> > > > > > called from RCU due to the way inodes are being freed.    
> > > > > 
> > > > > That doesn't mean that RCU has no problem. IIUC, the fact is that RCU
> > > > > has no scheduling point in rcu_process_callbacks() and it would be
> > > > > problematic. It just depends on workload.    
> > > > 
> > > > You mean rcu_do_batch()?  It does limit the callbacks invoked per call
> > > > to rcu_do_batch() under normal conditions, see the "++count >= bl" check.
> > > > 
> > > > Now, if you dump a huge number of callbacks down call_rcu()'s throat,
> > > > it will stop being Mr. Nice Guy and will start executing the callbacks
> > > > as fast as it can for potentially quite some time.  But a huge number
> > > > will be in the millions.  Per CPU.  In which case I just might have a
> > > > few questions about exactly what you are trying to do.
> > > > 
> > > > Nevertheless, it is entirely possible that RCU's callback-invocation
> > > > throttling strategy needs improvement.  
> > > 
> > > Would it be useful to have a call_rcu variant that may sleep. Callers would
> > > use it preferentially if they can. Implementation might be exactly the same
> > > for now, but it would give you more flexibility with throttling strategies
> > > in future.  
> > 
> > You can specify callback-offloading at build and boot time, which will have
> > each CPU's callbacks being processed by a kernel thread:
> > 
> > CONFIG_RCU_NOCB_CPU
> > CONFIG_RCU_NOCB_CPU_{NONE,ZERO,ALL}
> > rcu_nocbs=
> > 
> > However, this still executes the individual callbacks with bh disabled.
> > If you want the actual callbacks themselves to be able to sleep, make
> > the callback hand off to a workqueue, wake up a kthread, or some such.
> > 
> > But yes, if enough people were just having the RCU callback immediately
> > invoke a workqueue, that could easily be special cased, just as
> > kfree_rcu() is now.
> > 
> > Or am I missing your point?
> 
> I just meant where the call_rcu() caller can sleep. RCU could block
> there to throttle production if necessary.

Good point!  Yes, if the problem is RCU getting flooded with callbacks,
this would be one possible resolution.  I am hoping that ftrace will
better identify the actual problem.  Naive of me, I know!  ;-)

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
