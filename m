Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 599EB6B0269
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 22:30:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n24so126317547pfb.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:30:14 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id z64si11691615pfk.70.2016.09.28.19.30.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 19:30:13 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id cd13so19196101pac.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:30:13 -0700 (PDT)
Date: Thu, 29 Sep 2016 12:30:07 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: Soft lockup in __slab_free (SLUB)
Message-ID: <20160929123007.436e30d0@roar.ozlabs.ibm.com>
In-Reply-To: <20160929021100.GI14933@linux.vnet.ibm.com>
References: <57E8D270.8040802@kyup.com>
	<20160928053114.GC22706@js1304-P5Q-DELUXE>
	<57EB6DF5.2010503@kyup.com>
	<20160929014024.GA29250@js1304-P5Q-DELUXE>
	<20160929021100.GI14933@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Nikolay Borisov <kernel@kyup.com>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, brouer@redhat.com

On Wed, 28 Sep 2016 19:11:00 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> On Thu, Sep 29, 2016 at 10:40:24AM +0900, Joonsoo Kim wrote:
> > On Wed, Sep 28, 2016 at 10:15:01AM +0300, Nikolay Borisov wrote:  
> > > 
> > > I don't think it's an RCU problem per-se since ext4_i_callback is being
> > > called from RCU due to the way inodes are being freed.  
> > 
> > That doesn't mean that RCU has no problem. IIUC, the fact is that RCU
> > has no scheduling point in rcu_process_callbacks() and it would be
> > problematic. It just depends on workload.  
> 
> You mean rcu_do_batch()?  It does limit the callbacks invoked per call
> to rcu_do_batch() under normal conditions, see the "++count >= bl" check.
> 
> Now, if you dump a huge number of callbacks down call_rcu()'s throat,
> it will stop being Mr. Nice Guy and will start executing the callbacks
> as fast as it can for potentially quite some time.  But a huge number
> will be in the millions.  Per CPU.  In which case I just might have a
> few questions about exactly what you are trying to do.
> 
> Nevertheless, it is entirely possible that RCU's callback-invocation
> throttling strategy needs improvement.

Would it be useful to have a call_rcu variant that may sleep. Callers would
use it preferentially if they can. Implementation might be exactly the same
for now, but it would give you more flexibility with throttling strategies
in future.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
