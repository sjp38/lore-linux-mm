Date: Fri, 2 Mar 2007 16:24:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
Message-Id: <20070302162430.27489cec.akpm@linux-foundation.org>
In-Reply-To: <45E8B32B.4050903@mbligh.org>
References: <20070301101249.GA29351@skynet.ie>
	<20070301160915.6da876c5.akpm@linux-foundation.org>
	<45E842F6.5010105@redhat.com>
	<20070302085838.bcf9099e.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703020919350.16719@schroedinger.engr.sgi.com>
	<20070302093501.34c6ef2a.akpm@linux-foundation.org>
	<45E8624E.2080001@redhat.com>
	<20070302100619.cec06d6a.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703021012170.17676@schroedinger.engr.sgi.com>
	<45E86BA0.50508@redhat.com>
	<20070302211207.GJ10643@holomorphy.com>
	<45E894D7.2040309@redhat.com>
	<20070302135243.ada51084.akpm@linux-foundation.org>
	<45E89F1E.8020803@redhat.com>
	<20070302142256.0127f5ac.akpm@linux-foundation.org>
	<45E8A677.7000205@redhat.com>
	<45E8AA64.3050506@mbligh.org>
	<45E8AB36.3030104@redhat.com>
	<45E8B32B.4050903@mbligh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Rik van Riel <riel@redhat.com>, Bill Irwin <bill.irwin@oracle.com>, Christoph Lameter <clameter@engr.sgi.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 02 Mar 2007 15:28:43 -0800
"Martin J. Bligh" <mbligh@mbligh.org> wrote:

> >>> 32GB is pretty much the minimum size to reproduce some of these
> >>> problems. Some workloads may need larger systems to easily trigger
> >>> them.
> >>
> >> We can find a 32GB system here pretty easily to test things on if
> >> need be.  Setting up large commercial databases is much harder.
> > 
> > That's my problem, too.
> > 
> > There does not seem to exist any single set of test cases that
> > accurately predicts how the VM will behave with customer
> > workloads.
> 
> Tracing might help? Showing Andrew traces of what happened in
> production for the prev_priority change made it much easier to
> demonstrate and explain the real problem ...
> 

Tracing is one way.

The other way is the old scientific method:

- develop a theory
- add sufficient instrumentation to prove or disprove that theory
- run workload, crunch on numbers
- repeat

Of course, multiple theories can be proven/disproven in a single pass.

Practically, this means adding one new /prov/vmstat entry for each `goto
keep*' in shrink_page_list().  And more instrumentation in
shrink_active_list() to determine the behaviour of swap_tendency.

Once that process is finished, we should have a thorough understanding of
what the problem is.  We can then construct a testcase (it'll be a couple
hundred lines only) and use that testcase to determine what implementation
changes are needed, and whether it actually worked.

Then go back to the real workload, verify that it's still fixed.

Then do whitebox testing of other workloads to check that they haven't
regressed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
