Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m09LlCOg024856
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 16:47:12 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m09LlBY1157280
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:47:12 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m09Lkh1j029906
	for <linux-mm@kvack.org>; Wed, 9 Jan 2008 14:46:43 -0700
Date: Wed, 9 Jan 2008 13:47:07 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [BUG]  at mm/slab.c:3320
Message-ID: <20080109214707.GA26941@us.ibm.com>
References: <Pine.LNX.4.64.0801021227580.20331@schroedinger.engr.sgi.com> <20080103155046.GA7092@skywalker> <20080107102301.db52ab64.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801071008050.22642@schroedinger.engr.sgi.com> <20080108104016.4fa5a4f3.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0801072131350.28725@schroedinger.engr.sgi.com> <20080109065015.GG7602@us.ibm.com> <Pine.LNX.4.64.0801090949440.10163@schroedinger.engr.sgi.com> <20080109185859.GD11852@skywalker> <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801091122490.11317@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, lee.schermerhorn@hp.com, bob.picco@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On 09.01.2008 [11:23:59 -0800], Christoph Lameter wrote:
> On Thu, 10 Jan 2008, Aneesh Kumar K.V wrote:
> 
> > kernel BUG at mm/slab.c:3323!
> 
> That is 
> 
>         l3 = cachep->nodelists[nodeid];
>         BUG_ON(!l3);
> 
> retry:
>         check_irq_off();
>         ^^^^ this statment?
> 
> or the BUG_ON(!l3)?

Given that Aneesh's mail had this patch-hunk:

@@ -2977,6 +2977,9 @@ retry:
	}
	l3 = cachep->nodelists[node];

+	if (!l3)
+		return NULL;
+
	BUG_ON(ac->avail > 0 || !l3);
	spin_lock(&l3->list_lock);

And given that the original mail has bug at mm/slab.c:3320, I assume we're
still hitting the

BUG_ON(ac->avail > 0 || !l3);

Hrm, shouldn't we remove the !l3 bit from the BUG_ON? But even so, unless for
some reason the BUG_ON is being checked before the if (!l3), are we hitting
(ac->avail > 0)?

Aneesh, maybe split the conditions into two separate BUG_ON()'s to verify?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
