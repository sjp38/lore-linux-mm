Date: Wed, 5 Nov 2008 16:42:22 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: mmap: is default non-populating behavior stable?
In-Reply-To: <49107D98.9080201@gmail.com>
Message-ID: <Pine.LNX.4.64.0811051613400.21353@blonde.site>
References: <490F73CD.4010705@gmail.com> <1225752083.7803.1644.camel@twins>
 <490F8005.9020708@redhat.com> <491070B5.2060209@nortel.com>
 <1225814820.7803.1672.camel@twins> <20081104162820.644b1487@lxorguk.ukuu.org.uk>
 <49107D98.9080201@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eugene V. Lyubimkin" <jackyf.devel@gmail.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Peter Zijlstra <peterz@infradead.org>, Chris Friesen <cfriesen@nortel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 4 Nov 2008, Eugene V. Lyubimkin wrote:
> Alan Cox wrote:
> > 
> > I believe our behaviour is correct for mmap/mumap/truncate and it
> > certainly used to be and was tested.

Agreed.

> > 
> > At the point you do anything involving mremap (which is non posix) our
> > behaviour becomes rather bizarre.

Certainly mremap is non-POSIX, but I can't think of any way in which
it would interfere with Eugene's assumptions about population.

(Every year or so we do wonder whether to change an extending mremap
of a MAP_SHARED|MAP_ANONYMOUS object to extend the object itself instead
of just SIGBUSing on the extension: but I've so far remained conservative
about that, and Eugene appears to be thinking of more ordinary files.)

> 
> Thanks to all for answers. I have made the conclusion that doing "open() new
> file, truncate(<big size>), mmap(<the same big size>), write/read some memory
> pages" should not populate other, untouched by write/read pages (until
> MAP_POPULATE given), right?

That is a reasonable description of how the kernel tries and will always
try to handle it, approximately; but I don't think you can rely upon it
absolutely.

For a start, it depends on the filesystem: I believe that vfat, for
example, does not support the concept of sparse files (files with holes
in), so its truncate(<big size>) will allocate the whole of that big
size initially.

I'm not sure what you mean by "populate": in mm, as in MAP_POPULATE,
we're thinking of prefaulting pages into the user address space; but
you're probably thinking of whether the blocks are allocated on disk?

Prefaulting hole pages into the user address space may imply allocating
blocks on disk, or it may not: likely to depend on filesystem again.

>From time to time we toy with prefaulting adjacent pages when a fault
occurs (though IIRC tests have proved disappointing in the past): we'd
like to keep that option open, but it would go against your guidelines
above to some extent.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
