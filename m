Date: Sun, 12 Sep 2004 21:46:41 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: Fw: [Bugme-new] [Bug 3375] New: NUMA memory allocation issue:
 set_memorypolicy to MPOL_BIND do not work.
Message-Id: <20040912214641.50c0be89.pj@sgi.com>
In-Reply-To: <20040911020816.4ac226cd.akpm@osdl.org>
References: <20040911020816.4ac226cd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, jean-marie.verdun@hp.com, ak@muc.de
List-ID: <linux-mm.kvack.org>

I suspect, Jean-Marie, that if you change the line:

        unsigned long value=1;

to be instead:

        unsigned long value=9;

that it will work.  This 'value' in your code is what the man page for
set_mempolicy calls 'maxnode'.  It should be one more than the number of
bits in the nodemask being passed to set_mempolicy.  It looks to me like
your kernel for x86_64 has MAX_NUMNODES equal to 8 (it is equal to (1 <<
NODES_SHIFT), and NODES_SHIFT seems to be 3 on the x86_64 arch).  So you
should pass in a nodemask of 8 bits, and set this maxnode argument (your
variable named 'value') to one more than that, or 9.

More recent versions of Linus' bk tree might want 'value=8', not
'value=9', since there seems to be some confusion with a patch that
changes this maxnode parameter from being one more than the number of
bits, to being exactly equal to the number of bits.  I predict that this
will change soon, back to expecting one more than the number of bits.
My prediction could be wrong - I am not the one to make the decision.

So long as you aren't trying to actually use all 8 nodes, and so long as
you actually pass a mask that is a full word, zero'd out except for the
nodes you are trying to use, then passing either 8 or 9 should work
fine, on any kernel.

There seems to be a bug here that for some cases, such as the one you
report, set_mempolicy can build a set of zonelists that is empty, and
then be unable to allocate any memory.  I don't see the problem offhand,
so I will leave that detail up to Andi, who is the real master of this
code.  Your passing a maxnode of 1 (value=1) was an incorrect call, but
it should have failed the set_mempolicy(2) call with EINVAL, rather than
failing the exec call with ENOMEM.

(Aside to Andi - when my cpuset patch is added, it masks this ENOMEM on
exec bug, causing instead such invalid set_mempolicy calls to error out
with EINVAL.)

And, yes, Jean-Marie.  The set_mempolicy(2) man page is not yet sufficient
in its explanation of what to pass for this maxnode parameter.

Oh - you were passing "value2=1" as the 'policy' parameter to set_mempolicy.
This will get MPOL_PREFERRED, I believe.  When testing your code, I changed
that to 'value2=2' in order to get MPOL_BIND, which as you report is the
policy required to demonstrate the "Cannot allocate memory" error.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
