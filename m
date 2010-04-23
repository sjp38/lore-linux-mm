Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id B24B16B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:39:46 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e4.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3N3RXOj005069
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:27:33 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3N3dZER122732
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:39:35 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3N3dYpE023184
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 23:39:35 -0400
Date: Thu, 22 Apr 2010 20:39:33 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-ID: <20100423033933.GA2619@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1004211027120.4959@router.home>
 <20100421153421.GM30306@csn.ul.ie>
 <alpine.DEB.2.00.1004211038020.4959@router.home>
 <20100422092819.GR30306@csn.ul.ie>
 <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
 <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
 <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
 <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
 <1271946226.2100.211.camel@barrios-desktop>
 <alpine.DEB.2.00.1004221009150.32107@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004221009150.32107@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 22, 2010 at 10:14:04AM -0500, Christoph Lameter wrote:
> On Thu, 22 Apr 2010, Minchan Kim wrote:
> 
> > For further optimization, we can hold vma->adjust_lock if vma_address
> > returns -EFAULT. But I hope we redesigns it without new locking.
> > But I don't have good idea, now. :(
> 
> You could make it atomic through the use of RCU.
> 
> Create a new vma entry with the changed parameters and then atomically
> switch to the new vma.
> 
> Problem is that you have some list_heads in there.

Indeed, it would be necessary to update -all- pointers to the old
vma entry to point to the new vma entry.  The question at that point
will be "is it OK to switch the pointers over one at a time?"

In many situations, the answer is "yes", but it is necessary to check
carefully.

						Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
