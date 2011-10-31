Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 34C756B002D
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 16:59:00 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <60592afd-97aa-4eaf-b86b-f6695d31c7f1@default>
Date: Mon, 31 Oct 2011 13:58:39 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <75efb251-7a5e-4aca-91e2-f85627090363@default>
 <20111027215243.GA31644@infradead.org> <1319785956.3235.7.camel@lappy>
 <CAOzbF4fnD=CGR-nizZoBxmFSuAjFC3uAHf3wDj5RLneJvJhrOQ@mail.gmail.comCAOJsxLGOTw7rtFnqeHvzFxifA0QgPVDHZzrEo=-uB2Gkrvp=JQ@mail.gmail.com>
 <552d2067-474d-4aef-a9a4-89e5fd8ef84f@default
 20111031181651.GF3466@redhat.com>
In-Reply-To: <20111031181651.GF3466@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, Cyclonus J <cyclonusj@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Christoph Hellwig <hch@infradead.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>

> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)

Hi Andrea --

Thanks for your input. It's good to have some real technical
discussion about the core of tmem.  I hope you will
take the time to read and consider my reply,
and comment on any disagreements.

OK, let's go over your concerns about the "flawed API."

> 1) 4k page limit (no way to handle hugepages)

FALSE.  The API/ABI was designed from the beginning to handle
different pagesizes.  It can even dynamically handle more than
one page size, though a different "pool" must be created on
the kernel side for each different pagesize.  (At the risk
of derision, remember I used to code for IA64 so I am
very familiar with different pagesizes.)

It is true that the current tmem _backends_ (Xen and
zcache) reject pagesizes other than 4K, but if there are
"frontends" that have a different pagesize, the API/ABI
supports it.

For hugepages, I agree copying 2M seems odd.  But talking
about hugepages in the swap subsystem, I think we are
talking about a very remote future.  (Remember cleancache
is _already_ merged so I'm limiting this to swap.)  Perhaps
in that far future, Intel will have an optimized "copy2M"
instruction that can circumvent cache pollution?

> 2) synchronous

TRUE.  (Well, mostly.... RAMster is exploiting some asynchrony
but that's all still experimental.)

Remember the whole point of tmem/cleancache/frontswap is in
environments where memory is scarce and CPU is plentiful,
which is increasingly common (especially in virtualization).
We all cut our teeth on kernel work in an environment where
saving every CPU cycle was important, but in these new
memory-constrained many-core environments, the majority of
CPU cycles are idle.  So does it really matter if the CPU is
idle because it is waiting on the disk vs being used for
synchronous copying/compression/dedup?  See the published
Xen benchmarks:  CPU utilization goes up, but throughput
goes up too.  Why?  Because physical memory is being used
more efficiently.

Also IMHO the reason the frontswap hooks and the cleancache
hooks can be so simple and elegant and can support many
different users is because the API/ABI is synchronous.
If you change that, I think you will introduce all sorts
of special cases and races and bugs on both sides of the
ABI/API.  And (IMHO) the end result is that most CPUs
are still mostly sitting idle waiting for work to do.

> 3) not zerocopy, requires one bounce buffer for every get and one
>    bounce buffer again for every put (like highmem I/O with 32bit pci)

Hmmm... not sure I understand this one.  It IS copy-based
so is not zerocopy; the page of data is actually moving out
of memory controlled/directly-addressable by the kernel into
memory that is not controlled/directly-addressable by the kernel.
But neither the Xen implementation nor the zcache implementation
uses any bounce buffers, even when compressing or dedup'ing.

So unless I misunderstand, this one is FALSE.

> 4) can't handle batched requests

TRUE.  Tell me again why a vmexit/vmenter per 4K page is
"impossible"?  Again you are assuming (1) the CPU had some
real work to do instead and (2) that vmexit/vmenter is horribly
slow.  Even if vmexit/vmenter is thousands of cycles, it is still
orders of magnitude faster than a disk access.  And vmexit/vmenter
is about the same order of magnitude as page copy, and much
faster than compression/decompression, both of which still
result in a nice win.

You are also assuming that frontswap puts/gets are highly
frequent.  By definition they are not, because they are
replacing single-page disk reads/writes due to swapping.

That said, the API/ABI is very extensible, so if it were
proven that batching was sufficiently valuable, it could
be added later... but I don't see it as a showstopper.
Really do you?

> worse than HIGHMEM 32bit... Obviously you must be mlocking all Oracle
> db memory so you won't hit that bounce buffering ever with
> Oracle. Also note, historically there's nobody that hated bounce
> buffers more than Oracle (at least I remember the highmem issues with
> pci32 cards :). Also Oracle was the biggest user of hugetlbfs.

I already noted that there's no bounce buffers, but Oracle is
not pursuing this because of the Oracle _database_ (though
it does work on single node databases).  While "Oracle" is
often used to equate to its eponymous database, tmem works
on lots of workloads and Oracle (even pre-Sun-merger) sells
tons of non-DB software.  In fact I personally take some heat
for putting more emphasis on getting tmem into Linux than in
using it to proprietarily improve other Oracle products.

> If I'm wrong please correct me, I hadn't lots of time to check
> code. But we already raised these points before without much answer.

OK, so you're wrong on two of the points and I've corrected
you.  On two of the points, synchrony and non-batchability,
you make claims that (1) these are bad and (2) that there
is a better way to achieve the same results with asynchrony
and batchability.

I do agree you've raised the points before, but I am pretty
sure I've always given the same answers, so you shouldn't
say that you haven't gotten "much answer" but that you disagree
with the answer you got.

I've got working code, it's going in real distros and products and
has growing usage by (non-Oracle) kernel developers as well as
real users clamoring for it or already using it.  You claim
that by making it asynchronous it would be better, while I claim
that it would make it impossibly complicated.  (We'd essentially
be rewriting, or creating a parallel, blkio subsystem.)  You claim
that a batch interface is necessary, while I claim that if it is
proven that it is needed, it could be added later.

We've been talking about this since July 2009, right?
If you can do it better, where's your code?  I have the
highest degree of respect for your abilities and I have no
doubt that you could do something similar for KVM over a
long weekend... but can you also make it work for Xen, for
in-kernel compression, and for cross-kernel clustering
(not to mention for other "users" in my queue)?  The foundation
tmem code in the core kernel (frontswap and cleancache)
is elegant in its simplicity and _it works_.

REALLY no disrespect intended and I'm sorry if I am flaming,
so let me calm down by quoting Linus from the LWN KS2011
article:

  "[Linus] stated that, simply, code that actually is used is
   code that is actually worth something... code aimed at
   solving the same problem is just a vague idea that is
   worthless by comparison...  Even if it truly is crap,
   we've had crap in the kernel before.  The code does not
   get better out of tree."

So, please, all the other parts necessary for tmem are
already in-tree, why all the resistance about frontswap?

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
