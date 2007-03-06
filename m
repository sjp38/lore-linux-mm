Date: Tue, 6 Mar 2007 09:33:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] [PATCH] Power Managed memory base enabling
In-Reply-To: <20070306172039.GA26038@linux.intel.com>
Message-ID: <Pine.LNX.4.64.0703060925550.27341@chino.kir.corp.google.com>
References: <20070305181826.GA21515@linux.intel.com>
 <Pine.LNX.4.64.0703051941310.18703@chino.kir.corp.google.com>
 <20070306164722.GB22725@linux.intel.com> <Pine.LNX.4.64.0703060904380.27341@chino.kir.corp.google.com>
 <20070306172039.GA26038@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Gross <mgross@linux.intel.com>
Cc: linux-mm@kvack.org, linux-pm@lists.osdl.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, mark.gross@intel.com, neelam.chandwani@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 6 Mar 2007, Mark Gross wrote:

> > Is do_migrate_pages() currently unsatisfactory for this?
> 
> This looks like it should be good for this application!  How stable is
> this?  The next phase of this work is to export the policy interfaces
> and hook up the page migration.  I'm somewhat new to the mm code.
> 

Since you've already used a NUMA approach to flagging PM-memory, you'd 
probably want to use this interface through mempolicy in your migration.  
There's currently work to do lockless VMA scanning that was posted just 
yesterday to linux-mm and that's a bottleneck in this migration.

Take a look at update_nodemask() in kernel/cpuset.c for how it migrates 
pages from a source set of nodes to a destination set using 
memory_migrate.  The cpuset specifics are explained in 
Documentation/cpusets.txt, but the basics are that you'll want to use 
memory_migrate to start the migration when you remove a node from your 
nodemask (another reason why I suggested the use of a nodemask instead of 
a simple array).

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
