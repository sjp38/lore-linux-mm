Date: Mon, 16 Oct 2006 11:31:40 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [TAKE] memory page_alloc zonelist caching speedup
Message-Id: <20061016113140.f5461567.pj@sgi.com>
In-Reply-To: <20061016095805.f7576230.pj@sgi.com>
References: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
	<200610161134.07168.ak@suse.de>
	<20061016032632.486f4235.pj@sgi.com>
	<20061016112535.GA13218@lnx-holt.americas.sgi.com>
	<20061016095805.f7576230.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: holt@sgi.com, ak@suse.de, linux-mm@kvack.org, akpm@osdl.org, nickpiggin@yahoo.com.au, rientjes@google.com, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

And note that in the vast majority of cases, where the requested page
is available on the local node, there is no difference.

Only if we are forced to start scanning other nodes do we examine,
and once per-second zap, our node local cache of whether the other
nodes we scan were recently found to be full.

The classic parts of the zonelist zone arrays are still intact,
read-only, at the front of the struct zonelist.

The compact, node-local, periodically written zonelist cache is added
at the end of the zonelist struct, most likely in its own cache lines,
and lets us avoid node remote access to a larger set of more frequently
updated cache lines on each allocation request.

Only on configs with small, but greater than one, MAX_NUMNODES, is
there any chance of the zonelist cache being on the same cache line
as the class zone array.  As best as I can tell from a quick grep,
that would be avr32, arm/collie, powerpc/cell, and powerpc/pseries,
which have NODES_SHIFT values between 2 and 4, and various L1 cache
line sizes between 16 and 128 bytes.

Perhaps I should add a ____cacheline_aligned qualifier to the
zonelist_cache struct, for these arch's?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
