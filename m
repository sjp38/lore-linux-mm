Date: Mon, 9 Oct 2006 21:51:25 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page_alloc zonelist caching speedup
Message-Id: <20061009215125.619655b2.pj@sgi.com>
In-Reply-To: <20061009150259.d5b87469.pj@sgi.com>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<20061009105457.14408.859.sendpatchset@jackhammer.engr.sgi.com>
	<20061009111203.5dba9cbe.akpm@osdl.org>
	<20061009150259.d5b87469.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

pj wrote:
> I guess this means we add a counter to the zonelist_cache struct.
> Increment it each time we try to allocate a page from that zonelist.
> Trigger a zap (cache expiration) if the counter hits 1000, and clear
> the counter when we do the zap.

No, dang it.  Not count allocs.  Count frees.

My zonelist caching adapts immediately to another node being filled
up due to allocs, by turning on another bit in the fullzones bitmask.

But it doesn't adapt immediately to memory coming free.

    An application could say free up a big chunk of memory on its
    local node - perhaps by dropping the last reference to an anonymous
    memory region.

    It would then reasonably expect that new allocations would come
    from the local node - right then - not starting some later time
    up to one second in the future.

I think I'd need a per-node counter of frees, incremented on each free,
and checked by the zonelist caching to see if it should consider that
node no longer full.

-However- that forces a per-node reference in the zonelist caching
code as part of the scan for a free page.  That is exactly what we
were trying to avoid!

No.  Not count frees either.  Don't count anything.

I do not see how to count anything related to allocs or frees and
then use that counter to throttle the zonelist caching, without
re-introducing the lousy cache line footprint that I just got done
shrinking.

That's why I like time based throttles.  They are cheap.  Dirt cheap.
Infinitely scalable.  And stupid as a pet rock ;).


P.S.  I don't think that the above application, expecting instant reuse
of node local memory, even though it had just been pushing allocations
off-node, is a real problem.  Anyone care to claim otherwise?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
