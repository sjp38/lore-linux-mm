Message-ID: <48D739B2.1050202@goop.org>
Date: Sun, 21 Sep 2008 23:22:42 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: PTE access rules & abstraction
References: <1221846139.8077.25.camel@pasglop>
In-Reply-To: <1221846139.8077.25.camel@pasglop>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: benh@kernel.crashing.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> Just yesterday, I was browsing through the users of set_pte_at() to
> check something, and stumbled on a (new ?) bug that will introduce
> subtle problems on at least powerpc and s390.
>
> No big deal, I'll send a fix, but I'm becoming concerned with how
> fragile our page table & PTE access has become.
>
> (The bug btw is that we ptep_get_and_clear followed by a set_pte_at, at
> least on those architectures, you -must- flush before you put something
> new after you have cleared a PTE, I'll have to fixup our implementation
> of the new pte_modify_start/commit).
>   

When I added the ptep_modify_* interface, it occurred to me that
assuming that ptep_get_and_clear would always prevent async pte updates
was a bit optimistic, or at least presumptuous.  And certainly not
flushing the tlb seems like something that just happens to work on x86
(in fact I'm not quite sure how it does work on x86).

I didn't change the function of that code when I made the change, so the
bug was pre-existing; I think it has been like that for quite a while
(though I haven't done any git archaeology to back that up).  So I don't
think there's a new bug here.

What's the consequence of not flushing for you?

> With the need of the various virtual machines on x86, we've seen new
> page table accessors being created like there is no tomorrow, changes in
> the PTEs are accessed that may or may not be things we can rely on being
> stable in arch code, etc...
>   

There have been a few optional-extras calls, which are all fine to leave
as no-ops.  I don't think we've added or changed any must-have interfaces.

> Unfortunately, the arch code often has a very intimate relationship to
> how page tables are handled. The rules for locking, what can and cannot
> be done within a single PTE lock section, what can or cannot be done on
> a PTE, for example after it's been cleared, etc... vary in subtle ways
> and the way the things are today, the situation is very messy and
> fragile.
>   

It seems to me that the rules are roughly "anything goes while you're
holding the pte lock, but it all must be sane by the time you release
it".  But a bit more precision would be useful.

> Maybe it's time to have one head in "charge" of the page table access to
> try to keep some sanity, maybe it's time to write down some rules (for
> example, can we rely now and forever that set_pte_at() will -never- be
> called to write on top of an already valid PTE ?, etc...).
>   

I don't know if there's any such rule regarding set_pte_at().  Certainly
if you were overwriting an existing valid entry, you'd have to arrange
for a tlb flush.

> But maybe it's time to try to move the abstraction up a bit, maybe along
> the lines of what Nick proposed a while ago, some kind of transactional
> model. That would give a lot more freedom to architectures to have their
> own PTE access rules and optimisations. 

Do you have a reference to Nick's proposals?

A higher level interface might give us virtualization people more scope
to play with things.  But given that the current interface mostly works
for everyone, a high level interface would tend to result in a lot of
duplicated code unless you pretty strictly stipluate something like
"implement the highest level interface you need *and no higher*; use
common library code for everything else".

I think documenting the real rules for the current interface would be a
more immediately fruitful path to start with.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
