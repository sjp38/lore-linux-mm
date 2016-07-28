Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6F70A6B025F
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:56:01 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p85so9299335lfg.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 22:56:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a64si11751206wmc.86.2016.07.27.22.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 22:56:00 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6S5naFj010705
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:55:58 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24e5wec9ku-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 01:55:58 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Thu, 28 Jul 2016 06:55:57 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (d06relay13.portsmouth.uk.ibm.com [9.149.109.198])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 66FEB1B0804B
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 06:57:18 +0100 (BST)
Received: from d06av08.portsmouth.uk.ibm.com (d06av08.portsmouth.uk.ibm.com [9.149.37.249])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u6S5tobS43385048
	for <linux-mm@kvack.org>; Thu, 28 Jul 2016 05:55:50 GMT
Received: from d06av08.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av08.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u6S5tof9017583
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:55:50 -0600
Date: Thu, 28 Jul 2016 07:55:48 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG -next] "random: make /dev/urandom scalable for silly
 userspace programs" causes crash
References: <20160727071400.GA3912@osiris>
 <20160728034601.GC20032@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160728034601.GC20032@thunk.org>
Message-Id: <20160728055548.GA3942@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Jul 27, 2016 at 11:46:01PM -0400, Theodore Ts'o wrote:
> On Wed, Jul 27, 2016 at 09:14:00AM +0200, Heiko Carstens wrote:
> > it looks like your patch "random: make /dev/urandom scalable for silly
> > userspace programs" within linux-next seems to be a bit broken:
> > 
> > It causes this allocation failure and subsequent crash on s390 with fake
> > NUMA enabled
> 
> Thanks for reporting this.  This patch fixes things for you, yes?
> 
>        	   	     	    	       	     	    - Ted

Yes, it does. It's actually the same what I did to fix this ;)

> commit 59b8d4f1f5d26e4ca92172ff6dcd1492cdb39613
> Author: Theodore Ts'o <tytso@mit.edu>
> Date:   Wed Jul 27 23:30:25 2016 -0400
> 
>     random: use for_each_online_node() to iterate over NUMA nodes
>     
>     This fixes a crash on s390 with fake NUMA enabled.
>     
>     Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
>     Fixes: 1e7f583af67b ("random: make /dev/urandom scalable for silly userspace programs")
>     Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> 
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 8d0af74..7f06224 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1668,13 +1668,12 @@ static int rand_initialize(void)
>  #ifdef CONFIG_NUMA
>  	pool = kmalloc(num_nodes * sizeof(void *),
>  		       GFP_KERNEL|__GFP_NOFAIL|__GFP_ZERO);
> -	for (i=0; i < num_nodes; i++) {
> +	for_each_online_node(i) {
>  		crng = kmalloc_node(sizeof(struct crng_state),
>  				    GFP_KERNEL | __GFP_NOFAIL, i);
>  		spin_lock_init(&crng->lock);
>  		crng_initialize(crng);
>  		pool[i] = crng;
> -
>  	}
>  	mb();
>  	crng_node_pool = pool;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
