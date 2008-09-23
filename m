Date: Tue, 23 Sep 2008 05:10:37 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: PTE access rules & abstraction
Message-ID: <20080923031037.GA11907@wotan.suse.de>
References: <1221846139.8077.25.camel@pasglop> <48D739B2.1050202@goop.org> <1222117551.12085.39.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1222117551.12085.39.camel@pasglop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 23, 2008 at 07:05:51AM +1000, Benjamin Herrenschmidt wrote:
> 
> > I didn't change the function of that code when I made the change, so the
> > bug was pre-existing; I think it has been like that for quite a while
> > (though I haven't done any git archaeology to back that up).  So I don't
> > think there's a new bug here.
> > 
> > What's the consequence of not flushing for you?
> 
> The bug may have been there, as I said, lots of unwritten rules...
> sometimes broken. I'm not necessarily blaming you, but there have been
> lots of changes to the PTE accessors over the last 2 years and not
> always under any control :-)
> 
> In our case, the consequence is that the entry can be re-hashed because
> the fact that it was already hashed and where it was hashed, which is
> encoded in the PTE, gets lost by the clear. That means a potential
> duplicate entry in the hash. A hard to hit race, but possible. Such a
> condition is architecturally illegal and can cause things ranging from
> incorrect translation to machine checks or checkstops (generally, on
> LPAR machines, what will happen is your partition will get killed).
> 
> I know s390 has different issues & constraints. Martin told me during
> Plumbers that mprotect was probably also broken for him.
> 
> > There have been a few optional-extras calls, which are all fine to leave
> > as no-ops.  I don't think we've added or changed any must-have interfaces.
> 
> Again, I'm not necessarily talking about the very latest round of
> changes that you did here... More like a general approach as trying to
> find a better overall interface to PTE access which currently is a total
> mess as far as I'm concerned.
> 
> > It seems to me that the rules are roughly "anything goes while you're
> > holding the pte lock, but it all must be sane by the time you release
> > it".  But a bit more precision would be useful.
> 
> Well, unfortunately it's a lot more complex than that. For example, on
> powerpc, we have to keep the hash table in sync and hash misses don't
> take the PTE lock. They are aking to a non-atomic HW walk of the page
> tables if you prefer.
> 
> So we must be careful about things like never replacing a PTE without
> first flushing the hash table entry for the previous one (if it was
> hashed). We also need to ensure we flush before we unlock, but we do
> that by re-using the new lazy MMU hooks, as to not insert a new PTE
> (which can potentially be hashed).
> 
> s390 has more complex sets of rules.
> 
> > I don't know if there's any such rule regarding set_pte_at().  Certainly
> > if you were overwriting an existing valid entry, you'd have to arrange
> > for a tlb flush.
> 
> Well, for example, the generic copy-on-write case used to do just that,
> ie set_pte_at() over the previous one, then flush. That is not good for
> us and thus our set_pte_at() has special code to check whether there's
> already a present PTE there and does a synchronous flush if there is.
> 
> However, that also changed, and nowadays, afaik, set_pte_at() is never
> called anymore to override a already present PTE. 
> 
> We are doing some work on 32 bits code that will need similar
> constraints and It would be nice if we could rely on the above and make
> it part of the rules.
> 
> > Do you have a reference to Nick's proposals?
> 
> Not off hand, Nick ? How far did you go down that path ?

I got something far enough to compile and boot (iirc on x86 and maybe
ia64). Basically it was designed with fine grained pte locking in
mind which is why I stopped working on it after the pmd locking from
Hugh, but I imagine it could be used in some cases to do more
intelligent things with pte manipulation.

IIRC, basically you would have a pte_modify_start, which gives back a
cookie and the pte value, and pte_modify_end which takes a new pte
value and the cookie.

This would allow the arch to see exactly how the pte was changed, but
I imagine in some cases you would still prefer to do that with
optimised direct functions rather than test and branches. So I don't
know if it would be a magic cure ;)

Part of the problem with the pte API (as well as the cache flush and
tlb flush APIs) is that it often involves the core mm code telling
the arch how it thinks ptes,tlbs,caches should be managed, rather than
I think the better approach would be telling the arch what it wants to
do.

We are getting better slowly I think (eg. you note that set_pte_at is
no longer used as a generic "do anything"), but I won't dispute that
this whole area could use an overhaul; a document for all the rules,
a single person or point of responsibility for those rules...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
