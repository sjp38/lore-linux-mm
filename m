Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m6UCG3s3237840
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 12:16:03 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6UCG3RN4272242
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:16:03 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6UCG2V7001748
	for <linux-mm@kvack.org>; Wed, 30 Jul 2008 13:16:03 +0100
Subject: Re: memory hotplug: hot-remove fails on lowest chunk in
	ZONE_MOVABLE
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com>
References: <20080723105318.81BC.E1E9C6FF@jp.fujitsu.com>
	 <1217347653.4829.17.camel@localhost.localdomain>
	 <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain
Date: Wed, 30 Jul 2008 14:16:01 +0200
Message-Id: <1217420161.4545.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-07-30 at 12:16 +0900, Yasunori Goto wrote:
> Well, I didn't mean changing pages_min value. There may be side effect as
> you are saying.
> I meant if some pages were MIGRATE_RESERVE attribute when hot-remove are
> -executing-, their attribute should be changed.
> 
> For example, how is like following dummy code?  Is it impossible?
> (Not only here, some places will have to be modified..)

Right, this should be possible. I was somewhat wandering from the subject,
because I noticed that there may be a bigger problem with MIGRATE_RESERVE
pages in ZONE_MOVABLE, and that we may not want to have them in the first
place.

The more memory we add to ZONE_MOVABLE, the less reserved pages will
remain to the other zones. In setup_per_zone_pages_min(), min_free_kbytes
will be redistributed to a zone where the kernel cannot make any use of
it, effectively reducing the available min_free_kbytes. This just doesn't
sound right. I believe that a similar situation is the reason why highmem
pages are skipped in the calculation and I think that we need that for
ZONE_MOVABLE too. Any thoughts on that problem?

Setting pages_min to 0 for ZONE_MOVABLE, while not capping pages_low
and pages_high, could be an option. I don't have a sufficient memory
managment overview to tell if that has negative side effects, maybe
someone with a deeper insight could comment on that.

Thanks,
Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
