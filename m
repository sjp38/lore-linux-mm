Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E88626B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:24:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h186so39570760pfg.2
        for <linux-mm@kvack.org>; Thu, 28 Jul 2016 00:24:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id uz10si10980130pac.114.2016.07.28.00.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jul 2016 00:24:43 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6S7OgvC037937
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:24:42 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24e1ha8qpu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 03:24:40 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Thu, 28 Jul 2016 08:24:12 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id BF085219004D
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 08:23:36 +0100 (BST)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6S7OAdV21954688
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 07:24:10 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6S7O9Iq002125
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:24:09 -0600
Date: Thu, 28 Jul 2016 09:24:08 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG -next] "random: make /dev/urandom scalable for silly
 userspace programs" causes crash
References: <20160727071400.GA3912@osiris>
 <20160728034601.GC20032@thunk.org>
 <20160728055548.GA3942@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160728055548.GA3942@osiris>
Message-Id: <20160728072408.GB3942@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-s390@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On Thu, Jul 28, 2016 at 07:55:48AM +0200, Heiko Carstens wrote:
> On Wed, Jul 27, 2016 at 11:46:01PM -0400, Theodore Ts'o wrote:
> > On Wed, Jul 27, 2016 at 09:14:00AM +0200, Heiko Carstens wrote:
> > > it looks like your patch "random: make /dev/urandom scalable for silly
> > > userspace programs" within linux-next seems to be a bit broken:
> > > 
> > > It causes this allocation failure and subsequent crash on s390 with fake
> > > NUMA enabled
> > 
> > Thanks for reporting this.  This patch fixes things for you, yes?
> > 
> >        	   	     	    	       	     	    - Ted
> 
> Yes, it does. It's actually the same what I did to fix this ;)

Oh, I just realized that Linus pulled your changes. Actually I was hoping
we could get this fixed before the broken code would be merged.
Could you please make sure the bug fix gets included as soon as possible?

Right now booting a kernel with any defconfig on s390 will crash because of
this.

I will also change the fake NUMA code on s390, since it doesn't make sense
to have possible but not online nodes (in this case).

> > commit 59b8d4f1f5d26e4ca92172ff6dcd1492cdb39613
> > Author: Theodore Ts'o <tytso@mit.edu>
> > Date:   Wed Jul 27 23:30:25 2016 -0400
> > 
> >     random: use for_each_online_node() to iterate over NUMA nodes
> >     
> >     This fixes a crash on s390 with fake NUMA enabled.
> >     
> >     Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> >     Fixes: 1e7f583af67b ("random: make /dev/urandom scalable for silly userspace programs")
> >     Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> > 
> > diff --git a/drivers/char/random.c b/drivers/char/random.c
> > index 8d0af74..7f06224 100644
> > --- a/drivers/char/random.c
> > +++ b/drivers/char/random.c
> > @@ -1668,13 +1668,12 @@ static int rand_initialize(void)
> >  #ifdef CONFIG_NUMA
> >  	pool = kmalloc(num_nodes * sizeof(void *),
> >  		       GFP_KERNEL|__GFP_NOFAIL|__GFP_ZERO);
> > -	for (i=0; i < num_nodes; i++) {
> > +	for_each_online_node(i) {
> >  		crng = kmalloc_node(sizeof(struct crng_state),
> >  				    GFP_KERNEL | __GFP_NOFAIL, i);
> >  		spin_lock_init(&crng->lock);
> >  		crng_initialize(crng);
> >  		pool[i] = crng;
> > -
> >  	}
> >  	mb();
> >  	crng_node_pool = pool;
> > 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
