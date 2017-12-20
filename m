Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 72DAE6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:19:11 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id q16so2433156qkq.6
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 21:19:11 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m24si5643855qta.98.2017.12.19.21.19.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 21:19:10 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vBK5DfbE016251
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:19:10 -0500
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2eygu31hr6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 00:19:09 -0500
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 20 Dec 2017 00:19:09 -0500
Date: Tue, 19 Dec 2017 21:19:18 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] kfree_rcu() should use the new kfree_bulk() interface
 for freeing rcu structures
Reply-To: paulmck@linux.vnet.ibm.com
References: <rao.shoaib@oracle.com>
 <1513705948-31072-1-git-send-email-rao.shoaib@oracle.com>
 <20171219214158.353032f0@redhat.com>
 <20171219221206.GA22696@bombadil.infradead.org>
 <20171220002051.GJ7829@linux.vnet.ibm.com>
 <20171220015336.GA7748@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171220015336.GA7748@bombadil.infradead.org>
Message-Id: <20171220051918.GK7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, rao.shoaib@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 19, 2017 at 05:53:36PM -0800, Matthew Wilcox wrote:
> On Tue, Dec 19, 2017 at 04:20:51PM -0800, Paul E. McKenney wrote:
> > If we are going to make this sort of change, we should do so in a way
> > that allows the slab code to actually do the optimizations that might
> > make this sort of thing worthwhile.  After all, if the main goal was small
> > code size, the best approach is to drop kfree_bulk() and get on with life
> > in the usual fashion.
> > 
> > I would prefer to believe that something like kfree_bulk() can help,
> > and if that is the case, we should give it a chance to do things like
> > group kfree_rcu() requests by destination slab and soforth, allowing
> > batching optimizations that might provide more significant increases
> > in performance.  Furthermore, having this in slab opens the door to
> > slab taking emergency action when memory is low.
> 
> kfree_bulk does sort by destination slab; look at build_detached_freelist.

Understood, but beside the point.  I suspect that giving it larger
scope makes it more efficient, similar to disk drives in the old days.
Grouping on the stack when processing RCU callbacks limits what can
reasonably be done.  Furthermore, using the vector approach going into the
grace period is much more cache-efficient than the linked-list approach,
given that the blocks have a reasonable chance of going cache-cold during
the grace period.

And the slab-related operations should really be in the slab code in any
case rather than within RCU.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
