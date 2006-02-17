Date: Fri, 17 Feb 2006 10:38:26 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback
 list initialization
In-Reply-To: <200602171907.39236.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0602171030530.916@g5.osdl.org>
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602170841190.916@g5.osdl.org>
 <200602171907.39236.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: akpm@osdl.org, Christoph Lameter <clameter@engr.sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 17 Feb 2006, Andi Kleen wrote:
> 
> That is why I added the !NODE_DATA(...) continue check
> It will just continue until it finds a usable node. 

The thing is, there is nothing to guarantee that it _ever_ finds a usable 
node. Let's say that we have nodes

	3 10

in the node map, then neither the old "i + n % 2" nor your new "i + n % 11" 
will ever actually hit either of the valid nodes at all when you traverse 
the thing. See? 

That's why I'm saying that the "(i + n) % any_random_number" just can't be 
right, and that you absolutely _have_ to use the numbers that 
"for_each_online_node()" gives you directly. Using anything else is always 
going to be buggy.

> > NOTE! I've not tested (and thus not debugged) it. I don't even have NUMA 
> > enabled, so I've not even compiled it. Somebody else please test it, and 
> > send it back to me with a sign-off and a proper explanation, and I'll sign 
> > off on it again and apply it.
> 
> I gave it a quick boot on the simulator with a missing node and it looks 
> good. Will test it a bit more and then resubmit it.

If it compiles (and I didn't just do something stupid like use the wrong 
variable or test the order the wrong way), I think my version is always 
safe. It doesn't play games with the node numbers, and it only really 
edits the "distance function" to have a dependency on the node 
relationship.

So if it works at all, I think it works every time. But I'm biased ;)

And I'll never argue against more testing.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
