From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch][rfc] rewrite ramdisk
Date: Wed, 17 Oct 2007 22:49:13 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710161747.12968.nickpiggin@yahoo.com.au> <m16416f2y8.fsf@ebiederm.dsl.xmission.com>
In-Reply-To: <m16416f2y8.fsf@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710172249.13877.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Wednesday 17 October 2007 20:30, Eric W. Biederman wrote:
> Nick Piggin <nickpiggin@yahoo.com.au> writes:
> > On Tuesday 16 October 2007 18:08, Nick Piggin wrote:
> >> On Tuesday 16 October 2007 14:57, Eric W. Biederman wrote:
> >> > > What magic restrictions on page allocations? Actually we have
> >> > > fewer restrictions on page allocations because we can use
> >> > > highmem!
> >> >
> >> > With the proposed rewrite yes.
> >
> > Here's a quick first hack...
> >
> > Comments?
>
> I have beaten my version of this into working shape, and things
> seem ok.
>
> However I'm beginning to think that the real solution is to remove
> the dependence on buffer heads for caching the disk mapping for
> data pages, and move the metadata buffer heads off of the block
> device page cache pages.  Although I am just a touch concerned
> there may be an issue with using filesystem tools while the
> filesystem is mounted if I move the metadata buffer heads.
>
> If we were to move the metadata buffer heads (assuming I haven't
> missed some weird dependency) then I think there a bunch of
> weird corner cases that would be simplified.

I'd prefer just to go along the lines of what I posted. It's
a pure block device driver which knows absolutely nothing about
vm or vfs.

What are you guys using rd for, and is it really important to
have this supposed buffercache optimisation?


> I guess that is where I look next.
>
> Oh for what it is worth I took a quick look at fsblock and I don't think
> struct fsblock makes much sense as a block mapping translation layer for
> the data path where the current page caches works well.

Except the page cache doesn't store any such translation. fsblock
works very nicely as a buffer_head and nobh-mode replacement there,
but we could probably go one better (for many filesystems) by using
a tree.


> For less 
> then the cost of 1 fsblock I can cache all of the translations for a
> 1K filesystem on a 4K page.

I'm not exactly sure what you mean, unless you're talking about an
extent based data structure. fsblock is fairly slim as far as a
generic solution goes. You could probably save 4 or 8 bytes in it,
but I don't know if it's worth the trouble.


> I haven't looked to see if fsblock makes sense to use as a buffer head
> replacement yet.

Well I don't want to get too far off topic on the subject of fsblock,
and block mappings (because I think the ramdisk driver simply should
have nothing to do with any of that)... but fsblock is exactly a
buffer head replacement (so if it doesn't make sense, then I've
screwed something up badly! ;))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
