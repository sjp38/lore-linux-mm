From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] rd: Use a private inode for backing storage
Date: Sun, 21 Oct 2007 15:24:52 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710211428.55611.nickpiggin@yahoo.com.au> <m1wsthcatk.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m1wsthcatk.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710211524.52595.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Sunday 21 October 2007 15:10, Eric W. Biederman wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> > On Saturday 20 October 2007 08:51, Eric W. Biederman wrote:
> >> Currently the ramdisk tries to keep the block device page cache pages
> >> from being marked clean and dropped from memory.  That fails for
> >> filesystems that use the buffer cache because the buffer cache is not
> >> an ordinary buffer cache user and depends on the generic block device
> >> address space operations being used.
> >>
> >> To fix all of those associated problems this patch allocates a private
> >> inode to store the ramdisk pages in.
> >>
> >> The result is slightly more memory used for metadata, an extra copying
> >> when reading or writing directly to the block device, and changing the
> >> software block size does not loose the contents of the ramdisk.  Most
> >> of all this ensures we don't loose data during normal use of the
> >> ramdisk.
> >>
> >> I deliberately avoid the cleanup that is now possible because this
> >> patch is intended to be a bug fix.
> >
> > This just breaks coherency again like the last patch. That's a
> > really bad idea especially for stable (even if nothing actually
> > was to break, we'd likely never know about it anyway).
>
> Not a chance.

Yes it does. It is exactly breaking the coherency between block
device and filesystem metadata coherency that Andrew cared about.
Whether or not that matters, that is a much bigger conceptual
change than simply using slightly more (reclaimable) memory in
some situations that my patch does.

If you want to try convincing people to break that coherency,
fine, but it has to be done consistently and everywhere rather than
for a special case in rd.c.


> The only way we make it to that inode is through block 
> device I/O so it lives at exactly the same level in the hierarchy as
> a real block device.

No, it doesn't. A real block device driver does have its own
buffer cache as it's backing store. It doesn't know about
readpage or writepage or set_page_dirty or buffers or pagecache.


> My patch is the considered rewrite boiled down 
> to it's essentials and made a trivial patch.

What's the considered rewrite here? The rewrite I posted is the
only one so far that's come up that I would consider [worthy],
while these patches are just more of the same wrongness.


> It fundamentally fixes the problem, and doesn't attempt to reconcile
> the incompatible expectations of the ramdisk code and the buffer cache.

It fixes the bug in question, but not because it makes any
fundamental improvement to the conceptual ickyness of rd.c. I
don't know what you mean about attempting to reconcile the
incompatible [stuff]?


> > Christian's patch should go upstream and into stable. For 2.6.25-6,
> > my rewrite should just replace what's there. Using address spaces
> > to hold the ramdisk pages just confuses the issue even if they
> > *aren't* actually wired up to the vfs at all. Saving 20 lines is
> > not a good reason to use them.
>
> Well is more like saving 100 lines.  Not having to reexamine complicated
> infrastructure code and doing things the same way ramfs is.

Using radix_tree_insert instead of add_to_page_cache is hardly
complicated. If anything it is simpler because it isn't actually
confusing the issues and it is much better fit with real block
device drivers, which is actually the thing that is familiar to
block device driver maintainers.


> I think 
> that combination is a good reason.  Especially since I can do with a
> 16 line patch as I just demonstrated.  It is a solid and simple
> incremental change.

My opinion is that it is a much bigger behavioural change because
it results in incoherent buffer cache / blockdev cache, and it
results in code which is still ugly and conceptually wrong.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
