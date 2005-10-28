From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Date: Fri, 28 Oct 2005 19:10:39 +0200
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <43624F82.6080003@us.ibm.com>
In-Reply-To: <43624F82.6080003@us.ibm.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_PulYDbZRqPVl/Mn"
Message-Id: <200510281910.39646.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Jeff Dike <jdike@addtoit.com>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_PulYDbZRqPVl/Mn
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Friday 28 October 2005 18:19, Badari Pulavarty wrote:
> Jeff Dike wrote:

> I cut-n-pasted shmem_truncate_range() from shmem_truncate() and fixed
> few obvious things. Its very likely that, I missed whole bunch of changes.

> My touch tests so far, doesn't really verify data after freeing. I was
> thinking about writing cases. If I can use UML to do it, please send it
> to me. I would rather test with real world case :)
I would call that a _bad_ idea, at this stage.

It may be good when the patch is already really polished, IMHO, but not for 
verifying what's really wrong.

Also, you can gdb an UML running with the patch, to verify what's going on.

But I wouldn't suggest testing this with nested UMLs - using that means 
looking for trouble.

As an example, I'm attaching a test-program I wrote during my work on 
remap_file_pages - it also has a mechanism for trying memory accesses and 
catching SIGSEGV, and reporting they were / weren't got.

Not as nice as the kernel one, but it's little enough for our purposes.

There's much stuff you likely won't need, but it can be useful both as an 
example and as a starting point.

In your case, I'd write code as:

* fill many pages (enough to cover all indirections level in shmfs) with 
numbers. The first with 1, the second with 2, and so on (I'm avoiding 0 on 
purpose).

* loop over all them {
	truncate one of them

	loop over all pages to verify only that one is zero'ed (mincore() might help
	too, depending on its implementation).

	optionally, refill it (otherwise we can't check that truncating the next page
	doesn't clear this one).
}
(Possibly, truncate sets of pages, and verify only those ones are truncated).

* verify meanwhile that the tmpfs usage with statfs64() decreases.

Other suggestions?
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade

--Boundary-00=_PulYDbZRqPVl/Mn
Content-Type: application/x-bzip2;
  name="fremap-test-complete.c.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename="fremap-test-complete.c.bz2"

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
pVsg4rGMU/+LuSKcKEhBkyJvgA==

--Boundary-00=_PulYDbZRqPVl/Mn--

		
___________________________________ 
Yahoo! Messenger: chiamate gratuite in tutto il mondo 
http://it.messenger.yahoo.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
