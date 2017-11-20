Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id E1E796B025F
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 13:28:44 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 78so5193657qkz.13
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 10:28:44 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v23si3579432qkl.430.2017.11.20.10.28.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 10:28:43 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vAKIPX3h009905
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 13:28:42 -0500
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ec16qbjqv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 13:28:42 -0500
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Mon, 20 Nov 2017 13:28:41 -0500
Date: Mon, 20 Nov 2017 10:28:38 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Reply-To: paulmck@linux.vnet.ibm.com
References: <20171117173521.GA21692@infradead.org>
 <20171120092526.llj2q3lqbbxwn4g4@dhcp22.suse.cz>
 <20171120093309.GA19627@infradead.org>
 <20171120094237.z6h3kx3ne5ld64pl@dhcp22.suse.cz>
 <20171120104129.GA25042@infradead.org>
 <201711201956.IIB86978.OFMVFFOJLtOSHQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711201956.IIB86978.OFMVFFOJLtOSHQ@I-love.SAKURA.ne.jp>
Message-Id: <20171120182838.GU3624@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hch@infradead.org, mhocko@kernel.org, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, hannes@cmpxchg.org, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 20, 2017 at 07:56:28PM +0900, Tetsuo Handa wrote:
> Christoph Hellwig wrote:
> > On Mon, Nov 20, 2017 at 10:42:37AM +0100, Michal Hocko wrote:
> > > The patch has been dropped because allnoconfig failed to compile back
> > > then http://lkml.kernel.org/r/CAP=VYLr0rPWi1aeuk4w1On9CYRNmnEWwJgGtaX=wEvGaBURtrg@mail.gmail.com
> > > I have problem to find the follow up discussion though. The main
> > > argument was that SRC is not generally available and so the core
> > > kernel should rely on it.
> > 
> > Paul,
> > 
> > isthere any good reason to not use SRCU in the core kernel and
> > instead try to reimplement it using atomic counters?
> 
> CONFIG_SRCU was added in order to save system size. There are users who run Linux on very
> small systems ( https://www.elinux.org/images/5/52/Status-of-embedded-Linux-2017-09-JJ62.pdf ).
> 
> Also, atomic counters are not mandatory for shrinker case; e.g.
> http://lkml.kernel.org/r/201711161956.EBF57883.QFFMOLOVSOHJFt@I-love.SAKURA.ne.jp .

CONFIG_SRCU was indeed added in order to shrink single-CPU systems.
But many architectures are now requiring SRCU for one reason or another,
in more and more situations.

So I recently implemented a UP-only Tiny SRCU, which is quite a bit
smaller than its scalable counterpart, Tree SRCU:

   text	   data	    bss	    dec	    hex	filename
    983	     64	      0	   1047	    417	/tmp/c/kernel/rcu/srcutiny.o

   text	   data	    bss	    dec	    hex	filename
   6844	    193	      0	   7037	   1b7d	/tmp/b/kernel/rcu/srcutree.o

So perhaps it is time to unconditionally enable SRCU?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
