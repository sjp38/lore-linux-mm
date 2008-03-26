Received: by fg-out-1718.google.com with SMTP id e12so2882805fga.4
        for <linux-mm@kvack.org>; Wed, 26 Mar 2008 08:54:50 -0700 (PDT)
Message-ID: <29495f1d0803260854j46d37eedrc0927af226b3b8c8@mail.gmail.com>
Date: Wed, 26 Mar 2008 08:54:49 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: larger default page sizes...
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9E2CA@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <18408.29107.709577.374424@cargo.ozlabs.ibm.com>
	 <20080324.211532.33163290.davem@davemloft.net>
	 <18408.59112.945786.488350@cargo.ozlabs.ibm.com>
	 <20080325.163240.102401706.davem@davemloft.net>
	 <1FE6DD409037234FAB833C420AA843ECE9E2CA@orsmsx424.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Miller <davem@davemloft.net>, paulus@samba.org, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, torvalds@linux-foundation.org, agl@us.ibm.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On 3/25/08, Luck, Tony <tony.luck@intel.com> wrote:
> > > How do I get gcc to use hugepages, for instance?
>  >
>  > Implementing transparent automatic usage of hugepages has been
>  > discussed many times, it's definitely doable and other OSs have
>  > implemented this for years.
>  >
>  > This is what I was implying.
>
>
> "large" pages, or "super" pages perhaps ... but Linux "huge" pages
>  seem pretty hard to adapt for generic use by applications.  They
>  are generally a somewhere between a bit too big (2MB on X86) to
>  way too big (64MB, 256MB, 1GB or 4GB on ia64) for general use.
>
>  Right now they also suffer from making the sysadmin pick at
>  boot time how much memory to allocate as huge pages (while it
>  is possible to break huge pages into normal pages, going in
>  the reverse direction requires a memory defragmenter that
>  doesn't exist).

That's not entirely true. We have a dynamic pool now, thanks to Adam
Litke [added to Cc], which can be treated as a high watermark for the
hugetlb pool (and the static pool value serves as a low watermark).
Unless by hugepages you mean something other than what I think (but
referring to a 2M size on x86 imples you are not). And with the
antifragmentation improvements, hugepage pool changes at run-time are
more likely to succeed [added Mel to Cc].

>  Making an application use huge pages as heap may be simple
>  (just link with a different library to provide with a different
>  version of malloc()) ... code, stack, mmap'd files are all
>  a lot harder to do transparently.

I feel like I should promote libhugetlbfs here. We're trying to make
things easier for applications to use. You can back the heap by
hugepages via LD_PRELOAD. But even that isn't always simple (what
happens when something is already allocated on the heap?, which we've
seen happen even in our constructor in the library, for instance).
We're working on hugepage stack support. Text/BSS/Data segment
remapping exists now, too, but does require relinking to be more
successful. We have a mode that allows libhugetlbfs to try to fit the
segments into hugepages, or even just those parts that might fit --
but we have limitations on power and IA64, for instance, where
hugepages are restricted in their placement (either depending on the
process' existing mappings or generally). libhugetlbfs has, at least,
been tested a bit on IA64 to validate the heap backing (IIRC) and the
various kernel tests. We also have basic sparc support -- however, I
don't have any boxes handy to test on (working on getting them added
to our testing grid and then will revisit them), and then one box I
used before gave me semi-spurious soft-lockups (old bug, unclear if it
is software or just buggy hardware).

In any case, my point is people are trying to work on this from
various angles. Both making hugepages more available at run-time (in a
dynamic fashion, based upon need) and making them easier to use for
applications. Is it easy? Not necessarily. Is it guaranteed to work? I
like to think we make a best effort. But as others have pointed out,
it doesn't seem like we're going to get mainline transparent hugepage
support anytime soon.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
