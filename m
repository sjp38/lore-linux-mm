Date: Wed, 4 Aug 2004 16:27:25 -0500
From: Brent Casavant <bcasavan@sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Subject: Re: tmpfs round-robin NUMA allocation
In-Reply-To: <20040803012908.6211ace3.ak@suse.de>
Message-ID: <Pine.SGI.4.58.0408041601190.62058@kzerza.americas.sgi.com>
References: <Pine.SGI.4.58.0408021656300.58514@kzerza.americas.sgi.com>
 <20040803012908.6211ace3.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 3 Aug 2004, Andi Kleen wrote:

> On Mon, 2 Aug 2004 17:52:52 -0500
> Brent Casavant <bcasavan@sgi.com> wrote:
>
> > The second, and more elegant, way of addressing the problem is to
> > create a new MPOL_ROUNDROBIN policy, which would be identical to
> > MPOL_INTERLEAVE, except it would use either a counter or rotor to
> > choose the node from which to allocate.  This would probably be
> > just a bit more code than the previous idea, but would also provide
> > a more general facility that could be useful elsewhere.

[snip]

> I don't like the using a global variable for this. The problem
> is that it is quite evenly distributed at the beginning, as soon
> as pages get dropped you can end up with worst case scenarios again.
>
> I would prefer to use an "exact", but more global approach. How about
> something  like (inodenumber + pgoff) % numnodes ?
> anonymous memory can use the process pid instead of inode number.

Perhaps I'm missing something here.  How would using a value like
(inodenumber + pgoff) % numnodes help alleviate the problem of
memory becoming unbalanced as pages are dropped?  The pages are
dropped when the file is deleted.  For any given way of selecting
the node from which the allocation is made, there's probably a
pathelogic case where the memory can become unbalanced as files
are deleted.

I'm not really shooting for perfectly even page distribution -- just
something close enough that we don't end up with signficant lumpiness.
What I'm trying to avoid is this situation from a freshly booted system:

--- cut here ---
 Nid  MemTotal   MemFree   MemUsed      (in kB)
   0   1940880   1416992    523888
   1   1955840   1851904    103936
   2   1955840   1875840     80000
   8   1955840   1925408     30432
   9   1955840   1397824    558016
  10   1955840   1660096    295744
  11   1955840   1924480     31360
  12   1955824   1925696     30128
. . .
 190   1955840   1930816     25024
 191   1955840   1930816     25024
 192   1955840   1930880     24960
 193   1955824   1406624    549200
 194   1955840   1929824     26016
 248   1955840   1930496     25344
 249   1955840   1930816     25024
 250   1955840   1799776    156064
 251   1955824   1930752     2507
. . .
--- cut here ---

Granted, in this particular example there are factors other than tmpfs
contributing to the problem (i.e. certain kernel hash tables), but I'm
tackling one problem at a time.

I can think of even better methods than round-robin to ensure a very
even distribution (e.g. a policy which allocates from the least used
node), but these all seem like a bit of overkill.

Thanks,
Brent

-- 
Brent Casavant             bcasavan@sgi.com        Forget bright-eyed and
Operating System Engineer  http://www.sgi.com/     bushy-tailed; I'm red-
Silicon Graphics, Inc.     44.8562N 93.1355W 860F  eyed and bushy-haired.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
