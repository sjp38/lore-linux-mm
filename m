Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D36606B0010
	for <linux-mm@kvack.org>; Fri,  4 May 2018 09:14:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q7-v6so6731857pgt.11
        for <linux-mm@kvack.org>; Fri, 04 May 2018 06:14:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j61-v6si15782087plb.317.2018.05.04.06.14.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 06:14:44 -0700 (PDT)
Date: Fri, 4 May 2018 06:14:41 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180504131441.GA24691@bombadil.infradead.org>
References: <20180214182618.14627-1-willy@infradead.org>
 <20180214182618.14627-3-willy@infradead.org>
 <CA+55aFzLgES5qTAt2szDKcRtoUP5X--UPCoYX-38ea67cRFHxQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzLgES5qTAt2szDKcRtoUP5X--UPCoYX-38ea67cRFHxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm <linux-mm@kvack.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Fri, May 04, 2018 at 07:42:52AM +0000, Linus Torvalds wrote:
> On Wed, Feb 14, 2018 at 8:27 AM Matthew Wilcox <willy@infradead.org> wrote:
> > +static inline __must_check
> > +void *kvmalloc_ab_c(size_t n, size_t size, size_t c, gfp_t gfp)
> > +{
> > +       if (size != 0 && n > (SIZE_MAX - c) / size)
> > +               return NULL;
> > +
> > +       return kvmalloc(n * size + c, gfp);
> 
> Ok, so some more bikeshedding:

I'm putting up the bikeshed against your house ... the colour is your
choice!

>   - I really don't want to encourage people to use kvmalloc().
> 
> In fact, the conversion I saw was buggy. You can *not* convert a GFP_ATOMIC
> user of kmalloc() to use kvmalloc.

Not sure which conversion you're referring to; not one of mine, I hope?

>   - that divide is really really expensive on many architectures.

'c' and 'size' are _supposed_ to be constant and get evaluated at
compile-time.  ie you should get something like this on x86:

   0:   48 b8 fe ff ff ff ff    movabs $0x1ffffffffffffffe,%rax
   7:   ff ff 1f 
   a:   48 39 c7                cmp    %rax,%rdi
   d:   76 09                   jbe    18 <a+0x18>
   f:   48 c1 e7 03             shl    $0x3,%rdi
  13:   e9 00 00 00 00          jmpq   18 <a+0x18>
                        14: R_X86_64_PLT32      malloc-0x4
  18:   31 c0                   xor    %eax,%eax
  1a:   c3                      retq   

Now, if someone's an idiot, then you'll get the divide done at runtime,
and that'll be expensive.

> Normal kernel allocations are *limited*. It's simply not ok to allocate
> megabytes (or gigabytes) of mmory in general. We have serious limits, and
> we *should* have serious limits. If people worry about the multiply
> overflowing because a user is controlling the size valus, then dammit, such
> a user should not be able to do a huge gigabyte vmalloc() that exhausts
> memory and then spends time clearing it all!

I agree.

> So the whole notion that "overflows are dangerous, let's get rid of them"
> somehow fixes a bug is BULLSHIT. You literally introduced a *new* bug by
> removing the normal kmalloc() size limit because you thought that pverflows
> are the only problem.

Rather, I replaced one bug with another.  The removed bug was one
where we allocated 24 bytes and then indexed into the next slab object.
The added bug was that someone can now persuade the driver to allocate
gigabytes of memory.  It's a less severe bug, but I take your point.
We do have _some_ limits in vmalloc -- we fail if you're trying to
allocate more memory than is in the machine, and we fail if there's
insufficient contiguous space in the virtual address space.  But, yes,
this does allow people to allocate more memory than kmalloc would allow.

> So stop doing things like this. We should not do a stupid divide, because
> we damn well know that it is NOT VALID to allocate arrays that have
> hundreds of fthousands of elements,  or where the size of one element is
> very big.
> 
> So get rid of the stupid divide, and make the limits be much stricter. Like
> saying "the array element size had better be smaller than one page"
> (because honestly, bigger elements are not valid in the kernel), and "the
> size of the array cannot be more than "pick-some-number-out-of-your-ass".
> 
> So just make the divide go the hell away, a and check the size for validity.
> 
> Something like
> 
>       if (size > PAGE_SIZE)
>            return NULL;
>       if (elem > 65535)
>            return NULL;
>       if (offset > PAGE_SIZE)
>            return NULL;
>       return kzalloc(size*elem+offset);
> 
> and now you (a) guarantee it can't overflow and (b) don't make people use
> crazy vmalloc() allocations when they damn well shouldn't.

I find your faith in the size of structs in the kernel touching ;-)

struct cmp_data {
        /* size: 290904, cachelines: 4546, members: 11 */
struct dec_data {
        /* size: 274520, cachelines: 4290, members: 10 */
struct cpu_entry_area {
        /* size: 180224, cachelines: 2816, members: 7 */
struct saved_cmdlines_buffer {
        /* size: 131104, cachelines: 2049, members: 5 */
struct debug_store_buffers {
        /* size: 131072, cachelines: 2048, members: 2 */
struct bunzip_data {
        /* size: 42648, cachelines: 667, members: 23 */
struct inflate_workspace {
        /* size: 42312, cachelines: 662, members: 2 */
struct xz_dec_lzma2 {
        /* size: 28496, cachelines: 446, members: 5 */
struct lzma_dec {
        /* size: 28304, cachelines: 443, members: 21 */
struct rcu_state {
        /* size: 17344, cachelines: 271, members: 34 */
struct pglist_data {
        /* size: 18304, cachelines: 286, members: 34 */
struct tss_struct {
        /* size: 12288, cachelines: 192, members: 2 */
struct bts_ctx {
        /* size: 12288, cachelines: 192, members: 3 */

Those are just the ones above 10kB.  Sure, I can see some of them are
boot time use only, or we allocate one per node, or whatever.  But people
do create arrays of these things.  The biggest object we have in the
slab_cache today is 23488 bytes (kvm_vcpu) -- at least on my laptop.  Maybe
there's some insane driver out there that's creating larger things.

> And yeah, if  somebody has a page size bigger than 64k, then the above can
> still overflow. I'm sorry, that architecture s broken shit.
> 
> Are there  cases where vmalloc() is ok? Yes. But they should be rare, and
> they should have a good reason for them. And honestly, even then the above
> limits really really sound quite reasonable. There is no excuse for
> million-entry arrays in the kernel. You are doing something seriously wrong
> if you do those.

Normally, yes.  But then you get people like Google who want to have
a million file descriptors open in a single process.  So I'm leery of
putting hard limits on, like the ones you suggest above, because I'm not
going to be the one who Google come to when they want to exceed the limit.
If you want to draw that line in the sand, then I'm happy to respin the
patch in that direction.

We really have two reasons for using vmalloc -- one is "fragmentation
currently makes it impossible to allocate enough contiguous memory
to satisfy your needs" and the other is "this request is for too much
memory to satisfy through the buddy allocator".  kvmalloc is normally
(not always; see file descriptor example above) for the first kind of
problem, but I wonder if kvmalloc() shouldn't have the same limit as
kmalloc (2048 pages), then add a kvmalloc_large() which will not impose
that limit check.
