Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8C1rRph013885
	for <linux-mm@kvack.org>; Wed, 12 Sep 2007 11:53:27 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8C1rS7w3080318
	for <linux-mm@kvack.org>; Wed, 12 Sep 2007 11:53:28 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8C1rB4n006084
	for <linux-mm@kvack.org>; Wed, 12 Sep 2007 11:53:11 +1000
Message-ID: <46E74679.9020805@linux.vnet.ibm.com>
Date: Wed, 12 Sep 2007 07:22:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Update:  [Automatic] NUMA replicated pagecache on 2.6.23-rc4-mm1
References: <20070727084252.GA9347@wotan.suse.de> <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost> <20070813074351.GA15609@wotan.suse.de> <1189543962.5036.97.camel@localhost>
In-Reply-To: <1189543962.5036.97.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> [Balbir:  see notes re:  replication and memory controller below]
> 
> A quick update:  I have rebased the automatic/lazy page migration and
> replication patches to 23-rc4-mm1.  If interested, you can find the
> entire series that I push in the '070911' tarball at:
> 
> 	http://free.linux.hp.com/~lts/Patches/Replication/
> 
> I haven't gotten around to some of the things you suggested to address
> the soft lockups. etc.  I just wanted to keep the patches up to date.  
> 
> In the process of doing a quick sanity test, I encountered an issue with
> replication and the new memory controller patches.  I had built the
> kernel with the memory controller enabled.  I encountered a panic in
> reclaim, while attempting to "drop caches", because replication was not
> "charging" the replicated pages and reclaim tried to deref a null
> "page_container" pointer.  [!!! new member in page struct !!!]
> 
> I added code to try_to_create_replica(), __remove_replicated_page() and
> release_pcache_desc() to charge/uncharge where I thought appropriate
> [replication patch # 02].  That seemed to solve the panic during drop
> caches triggered reclaim.  However, when I tried a more stressful load,
> I hit another panic ["NaT Consumption" == ia64-ese for invalid pointer
> deref, I think] in shrink_active_list() called from direct reclaim.
> Still to be investigated.  I wanted to give you and Balbir a heads up
> about the interaction of memory controllers with page replication.
> 

Hi, Lee,

Thanks for testing the memory controller with page replication. I do
have some questions on the problem you are seeing

Did you see the problem with direct reclaim or container reclaim?
drop_caches calls remove_mapping(), which should eventually call
the uncharge routine. We have some sanity checks in there.

We do try to see at several places if the page->page_container is NULL
and check for it. I'll look at your patches to see if there are any
changes to the reclaim logic. I tried looking for the oops you
mentioned, but could not find it in your directory, I saw the soft
lockup logs though. Do you still have the oops saved somewhere?

I think the fix you have is correct and makes things works, but it
worries me that in direct reclaim we dereference the page_container
pointer without the page belonging to a container? What are the
properties of replicated pages? Are they assumed to be exact
replicas (struct page mappings, page_container expected to be the
same for all replicated pages) of the replicated page?


> Later,
> Lee
> 
-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
