Date: Mon, 25 Jun 2007 07:35:45 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: vm/fs meetup in september?
Message-ID: <20070625063545.GA1964@infradead.org>
References: <20070624042345.GB20033@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070624042345.GB20033@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 24, 2007 at 06:23:45AM +0200, Nick Piggin wrote:
> I'd just like to take the chance also to ask about a VM/FS meetup some
> time around kernel summit (maybe take a big of time during UKUUG or so).

I won't be around until a day or two before KS, so I'd prefer to have it
after KS if possible.

> I don't want to do it in the VM summit, because that kind of alienates
> the filesystem guys. What I want to talk about is anything and everything
> that the VM can do better to help the fs and vice versa.  I'd like to
> stay away from memory management where not too applicable to the fs.

As more of a filesystem person I wouldn't mind it being attached to a VM
conf.  In the worst case we'll just rename it VM/FS conference.  When and
where is it scheduled?

> - the address space operations APIs, and their page based nature. I think
>   it would be nice to generally move toward offset,length based ones as
>   much as possible because it should give more efficiency and flexibility
>   in the filesystem.
> 
> - write_begin API if it is still an issue by that date. Hope not :)
> 
> - truncate races
> 
> - fsblock if it hasn't been shot down by then

Don't forget high order pagecache please.

> - how to make complex API changes without having to fix most things
>   yourself.

More issues:

 - aio once again
 - refactoring the dio code to separate locking down user VM and doing
   the actual page based I/O.  I've seen valid requests from kernel
   initiated direct I/O from a few real world linux users.
 - generic code for delayed allocation and writeout using efficient
   multi-page allocator calls.  I'll hopefully have an example (lifted XFS
   code) by then
 - what to do about reads/writes from kernelspace.  Currently we have
   some places (loop mostly) calling directly into ->prepare_write / 
   ->commit_write which is completely wrong from the layerin perspective
   and a locking nightmare for distributed or generally more complex
   filesystems.  And we have a lot of places using set_fs/set_ds and
   calling into ->write.  The first category could probably be covered
   by using the splice infrastructure, but for the latter we'd want
   something more optimal and less hacky, especially given all the overhead
   related avoiding deadlocks involing the user address space in the
   generic write path.  Maybe it's time for generic_file_kernel_write?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
