Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 782356B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 23:46:08 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id r9so27768186ywg.0
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 20:46:08 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id q137si2657438ybq.124.2016.07.27.20.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 20:46:07 -0700 (PDT)
Date: Wed, 27 Jul 2016 23:46:01 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [BUG -next] "random: make /dev/urandom scalable for silly
 userspace programs" causes crash
Message-ID: <20160728034601.GC20032@thunk.org>
References: <20160727071400.GA3912@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160727071400.GA3912@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-next@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Jul 27, 2016 at 09:14:00AM +0200, Heiko Carstens wrote:
> it looks like your patch "random: make /dev/urandom scalable for silly
> userspace programs" within linux-next seems to be a bit broken:
> 
> It causes this allocation failure and subsequent crash on s390 with fake
> NUMA enabled

Thanks for reporting this.  This patch fixes things for you, yes?

       	   	     	    	       	     	    - Ted

commit 59b8d4f1f5d26e4ca92172ff6dcd1492cdb39613
Author: Theodore Ts'o <tytso@mit.edu>
Date:   Wed Jul 27 23:30:25 2016 -0400

    random: use for_each_online_node() to iterate over NUMA nodes
    
    This fixes a crash on s390 with fake NUMA enabled.
    
    Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
    Fixes: 1e7f583af67b ("random: make /dev/urandom scalable for silly userspace programs")
    Signed-off-by: Theodore Ts'o <tytso@mit.edu>

diff --git a/drivers/char/random.c b/drivers/char/random.c
index 8d0af74..7f06224 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1668,13 +1668,12 @@ static int rand_initialize(void)
 #ifdef CONFIG_NUMA
 	pool = kmalloc(num_nodes * sizeof(void *),
 		       GFP_KERNEL|__GFP_NOFAIL|__GFP_ZERO);
-	for (i=0; i < num_nodes; i++) {
+	for_each_online_node(i) {
 		crng = kmalloc_node(sizeof(struct crng_state),
 				    GFP_KERNEL | __GFP_NOFAIL, i);
 		spin_lock_init(&crng->lock);
 		crng_initialize(crng);
 		pool[i] = crng;
-
 	}
 	mb();
 	crng_node_pool = pool;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
