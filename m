Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id AED1A6B0073
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:25:24 -0400 (EDT)
Date: Thu, 2 Aug 2012 13:25:16 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [RFC 1/4] hashtable: introduce a small and naive hashtable
Message-ID: <20120802202516.GA7916@jtriplet-mobl1>
References: <20120801224556.GF15477@google.com>
 <501A4FC1.8040907@gmail.com>
 <20120802103244.GA23318@leaf>
 <501A633B.3010509@gmail.com>
 <87txwl1dsq.fsf@xmission.com>
 <501AAC26.6030703@gmail.com>
 <87fw851c3d.fsf@xmission.com>
 <CA+55aFw_dwO5ZOuaz9eDxgnTZFDGVZKSLUTm5Fn99faALxxJRQ@mail.gmail.com>
 <20120802175904.GB6251@jtriplet-mobl1>
 <CA+55aFwqC9hF++S-VPHJBFRrqfyNvsvqwzP=Vtzkv8qSYVqLxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwqC9hF++S-VPHJBFRrqfyNvsvqwzP=Vtzkv8qSYVqLxA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com

On Thu, Aug 02, 2012 at 11:08:06AM -0700, Linus Torvalds wrote:
> On Thu, Aug 2, 2012 at 10:59 AM, Josh Triplett <josh@joshtriplett.org> wrote:
> >
> > You shouldn't have any extra indirection for the base, if it lives
> > immediately after the size.
> 
> Umm. You *always* have the extra indirection. Because you have that allocation.
> 
> So you have to follow the pointer to get the base/size, because they
> aren't compile/link-time constants.

Sorry, I should clarify what I meant: you'll have a total of one extra
indirection, not two.  You have to follow the pointer to get to both the
size and the buckets.  However, I would *hope* that you'd keep that line
in cache during any repeated activity using that hash table, which ought
to eliminate the cost of the indirection.  Does that line really get
evicted from cache entirely by the time you touch the dcache again?

> The cache misses were noticeable in macro-benchmarks, and in
> micro-benchmarks the smaller L1 hash table means that things fit much
> better in the L2.
>
> It really improved performance. Seriously. Even things like "find /"
> that had a lot of L1 misses ended up faster, because "find" is
> apparently pretty moronic and does some things over and over. For
> stuff that fit in the L1, it qas quite noticeable.
> 
> Of course, one reason for the speedup for the dcache was that I also
> made the L1 only contain the simple cases (ie no "d_compare" thing
> etc), so it speeded up dcache lookups in other ways too. But according
> to the profiles, it really looked like better cache behavior was one
> of the bigger things.

Seems like avoiding some of the longer paths through the dcache code
would also improve your cache behavior.  But in any case, I can easily
believe that the small L1 cache provides a win.

> Trust me: every problem in computer science may be solved by an
> indirection, but those indirections are *expensive*. Pointer chasing
> is just about the most expensive thing you can do on modern CPU's.

By that argument, it might make sense to make the L1 cache a closed hash
table and drop the chaining, to get rid of one more indirection, or
several.

Does your two-level dcache handle eviction?

Mind posting the WIP patches?

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
