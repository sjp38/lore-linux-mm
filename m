Date: Sun, 17 Sep 2006 19:20:10 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060917192010.cc360ece.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
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
	<20060917152723.5bb69b82.pj@sgi.com>
	<Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David wrote:
> >     Given two node numbers, are they really just two fake nodes
> >     on the same hardware node, or are they really on two distinct
> >     hardware nodes?
> > 
> 
> The cpumap for all fake nodes are always 00000000 except for node0 which 
> reports the true hardware configuration.

Thanks.

I doubt that this is a unique signature identifying fake numa systems.

I've seen other systems that had memory-only nodes, which I suspect
would show up with all 000000 cpumaps on those nodes.

Perhaps we should add a hook to allow testing if we are running on
fake numa system:
    
    For example, we could add a macro to a header that, in the case
    CONFIG_NUMA_EMU was enabled, evaluated to 1 if numa emulation
    was enabled.  Currently, the true state of numa emulation only
    seems to be known to code within:

      arch/x86_64/mm/numa.c

    and currently only available for x86_64 arch's and only available
    if CONFIG_NUMA_EMU is enabled.

    With the usual conditional macro header magic, we could make a
    test for NUMA emulation available in generic kernel code.


Andrew,

    Do you have any plans to build a hybrid system with both real and
    emulated NUMA present?  That could complicate things.

    My current notion is to have a simple modal switch:
    
     - Fake numa systems would never try to go-back-to-the-earlier-zone.
    
     - Real NUMA systems not use this zone caching at all, always
       scanning the zonelist from the front.

    Such trivial modal behaviour wouldn't work on a hybrid system with
    both real and emulated NUMA.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
