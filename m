Message-ID: <4213D8DB.6080807@sgi.com>
Date: Wed, 16 Feb 2005 17:35:55 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
References: <20050215185943.GA24401@lnx-holt.americas.sgi.com> <16914.28795.316835.291470@wombat.chubb.wattle.id.au> <421283E6.9030707@sgi.com> <31650000.1108511464@flay> <421295FB.3050005@sgi.com> <20050216004401.GB8237@wotan.suse.de> <51210000.1108515262@flay> <20050216100229.GB14545@wotan.suse.de> <232990000.1108567298@[10.10.2.4]> <20050216074923.63cf1b6b.pj@sgi.com> <20050216160833.GB6604@wotan.suse.de> <60510000.1108572918@flay>
In-Reply-To: <60510000.1108572918@flay>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Andi Kleen <ak@suse.de>, Paul Jackson <pj@sgi.com>, peterc@gelato.unsw.edu.au, raybry@austin.rr.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin J. Bligh wrote:
> --On Wednesday, February 16, 2005 17:08:33 +0100 Andi Kleen <ak@suse.de> wrote:
> 
> 
>>On Wed, Feb 16, 2005 at 07:49:23AM -0800, Paul Jackson wrote:
>>
>>>Martin wrote:
>>>
>>>>From reading the code (not actual experiments, yet), it seems like we won't
>>>>even wake up the local kswapd until all the nodes are full. And ...
>>>
>>>Martin - is there a Cliff Notes summary you could provide of this
>>>subthread you and Andi are having?  I got lost somewhere along the way.
>>
>>I didn't really have much thread, but as far as I understood it
>>Martin just wants kswapd to be a bit more aggressive in making sure
>>all nodes always have local memory to allocate from.
>>
>>I don't see it as a pressing problem right now, but it may help
>>for some memory intensive workloads a bit (see numastat numa_miss output for
>>various nodes on how often a "wrong node" fallback happens) 
> 
> 
> Yeah - I think I'm just worried that people are proposing a manual rather
> than automatic solution to solve fallback issues. We ought to be able
> to fix that without tweaking things up the wazoo by hand.
> 
> M.
> 
> 
Martin,

We are not trying to solve the problem you apparently think we are.
The page migration work we are doing is to support a batch scheduler
for a large NUMA system.  If you haven't done so already, please go
back and read the overview note from the posting that started this
thread.

Solving the fallback problem is mostly a problem of determing when
local allocation is desired, and then freeing up memory on that node
if the local allocation fails.  Our intent there is to implement a
solution similar to Nick Piggin's "Try Local Harder" patch, except
that in addition to running kswapd, we will also automatically
scan for idle, clean, unused page cache pages as well.  We have
code in our 2.4.21 based kernel for Altix that does this today
and it results in almost no local allocations spilling off node
(unless the node becomes full of mapped pages, in which case we
have little other choice).

In general, we don't think it is necessary to migrate pages off
of the current node to avoid the fallback allocation.  In particular,
we don't think it is useful to migrate page cache pages to another
node to free up local storage.  The reason is that if you do this
you are expending significant resource to move a page that in all
likelyhood will never be referenced again.  It is better just to
toss the page and let it be read in again if it is really needed.

Take a look at the patch that Martin Hicks has posted to see where
we would like to go for freeing of page cache pages.  That patch
patch is also "manual", and that is not a good thing.  We, like
you, want automatic clean up of useless page cache pages on a
node to avoid allocations from spilling off node.  Here is the
link to Martin's post:

http://marc.theaimsgroup.com/?l=linux-kernel&m=110839604924587&w=2

-- 
-----------------------------------------------
Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
	 so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
