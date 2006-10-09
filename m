Date: Mon, 9 Oct 2006 13:24:04 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [RFC] memory page alloc minor cleanups
Message-Id: <20061009132404.e6f8522d.pj@sgi.com>
In-Reply-To: <452A4A9D.40605@yahoo.com.au>
References: <20061009105451.14408.28481.sendpatchset@jackhammer.engr.sgi.com>
	<452A4A9D.40605@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, akpm@osdl.org, rientjes@google.com, ak@suse.de, mbligh@google.com, rohitseth@google.com, menage@google.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Probably in response to my patch lines:

@@ -1056,21 +1057,13 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 ...
-	if (unlikely(*z == NULL)) {
-		/* Should this ever happen?? */
-		return NULL;
-	}


Nick wrote:
> Would it be better to ensure an empty zonelist is never passed down?

Are you saying we should leave this empty zonelist check where it was,
or we should somehow ensure that we never get to __alloc_pages with an
empty zonelist in the first place?  Not clear ...

What seems clear to me is that this check is in the wrong place, and if
needed, is the wrong check.

The check is not needed right there.  If we have an empty zonelist, then
that just makes the zonelist scanning go all the faster ;).  Harmless,
silly, but rare.

Not until much deeper in the allocation code, when we have to make some
hard choices, like oom or panic or loop forever (hopelessly) looking
for pages off an empty zonelist, do we actually have to worry about
empty zonelists.

So either:
 * the check is not needed, if empty zonelists can't happen, or
 * the check should be moved out of the hot spot it is in now,
   where it has no need of being, to where it is needed, lower down,
   in less frequently executed code.

And if it is needed, the logic of the check seems slightly
oversimplified:

    I'd think it should consider (1) allocations requests that can
    fail in which case we return NULL, separately from (2) allocation
    requests that cannot fail in which case we are on an impossible
    mission, as the caller is insisting that we do not fail to find
    a page on an empty list.

    Perhaps in this second case, we pick the local nodes default full
    sized zonelist and find a page for our demanding caller that way.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
