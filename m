Subject: Update:  [Automatic] NUMA replicated pagecache on 2.6.23-rc4-mm1
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070813074351.GA15609@wotan.suse.de>
References: <20070727084252.GA9347@wotan.suse.de>
	 <1186604723.5055.47.camel@localhost> <1186780099.5246.6.camel@localhost>
	 <20070813074351.GA15609@wotan.suse.de>
Content-Type: text/plain
Date: Tue, 11 Sep 2007 16:52:42 -0400
Message-Id: <1189543962.5036.97.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, balbir@linux.vnet.ibm.com, Joachim Deguara <joachim.deguara@amd.com>, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@csn.ul.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

[Balbir:  see notes re:  replication and memory controller below]

A quick update:  I have rebased the automatic/lazy page migration and
replication patches to 23-rc4-mm1.  If interested, you can find the
entire series that I push in the '070911' tarball at:

	http://free.linux.hp.com/~lts/Patches/Replication/

I haven't gotten around to some of the things you suggested to address
the soft lockups. etc.  I just wanted to keep the patches up to date.  

In the process of doing a quick sanity test, I encountered an issue with
replication and the new memory controller patches.  I had built the
kernel with the memory controller enabled.  I encountered a panic in
reclaim, while attempting to "drop caches", because replication was not
"charging" the replicated pages and reclaim tried to deref a null
"page_container" pointer.  [!!! new member in page struct !!!]

I added code to try_to_create_replica(), __remove_replicated_page() and
release_pcache_desc() to charge/uncharge where I thought appropriate
[replication patch # 02].  That seemed to solve the panic during drop
caches triggered reclaim.  However, when I tried a more stressful load,
I hit another panic ["NaT Consumption" == ia64-ese for invalid pointer
deref, I think] in shrink_active_list() called from direct reclaim.
Still to be investigated.  I wanted to give you and Balbir a heads up
about the interaction of memory controllers with page replication.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
