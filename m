Date: Sun, 17 Sep 2006 15:27:23 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917152723.5bb69b82.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
	<Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
	<20060917041707.28171868.pj@sgi.com>
	<Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
	<20060917060358.ac16babf.pj@sgi.com>
	<Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David,

Could you run the following on your fake numa booted box, and
report the results:

	find /sys/devices -name distance | xargs head

Following Andrew's suggestion, I'm toying with the idea that since
one fake numa node is as good as another, there is no reason to worry
about retrying skipped over nodes or re-validating the cached zones
on such systems

Roughly, my plan is:

    If the node on which we most recently found memory is 'just as
    good as' the first node in the zonelist, then go ahead and cache
    that node and continue to use it as long as we can.  We're in
    the fake NUMA case, and one node is as good as another.

    If that node is 'further away' than the first node in the zonelist,
    don't cache it.  We're in the real NUMA case, and we're happy to
    carry on just as we have in the past, always scanning from the
    beginning of the zonelist.

However this requires some way to determine whether two fake nodes
are really on the same hardware node.

Hmmm ... there's a good chance that the kernel 'node_distance()'
routine, as shown in the above /sys/devices distance table, is not
the way to determine this.  Perhaps that table must reflect the
fake reality, not the underlying hardware reality.

Though, if node_distance() doesn't tell us this, there's a chance
this will cause problems elsewhere and we will end up wanting to
fix node_distance() in the fake NUMA case to note that all nodes
are actually local, which is value 10, I believe.  The code in
arch/x86_64/mm/srat.c:slit_valid() may conflict with this, and the
concerns its comment raises about a SLIT table with all 10's may also
point to conflicts with this.

You've been looking at this fake NUMA code recently, David.

Perhaps you can recommend some other way from within the
mm/page_alloc.c code to efficiently (just a couple cache lines)
answer the question:

    Given two node numbers, are they really just two fake nodes
    on the same hardware node, or are they really on two distinct
    hardware nodes?

Granted, I'm not -entirely- following Andrew's lead here.  He's been
hoping that this most-recently-used-node cache would benefit both
fake and real NUMA systems, while I've thinking we don't really have
a problem on the real NUMA systems, and it is better not to mess with
the memory allocation pattern there (if it ain't broke, don't fix ...)

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
