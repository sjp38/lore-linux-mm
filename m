Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1606B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:00:23 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id j5so4145081qaq.19
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 14:00:22 -0800 (PST)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTP id r5si13348530qat.64.2013.12.10.14.00.19
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 14:00:20 -0800 (PST)
Date: Tue, 10 Dec 2013 22:00:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] [RFC] mm: slab: separate slab_page from 'struct page'
In-Reply-To: <52A78B55.8050500@sr71.net>
Message-ID: <00000142de866123-cf1406b5-b7a3-4688-b46f-80e338a622a1-000000@email.amazonses.com>
References: <20131210204641.3CB515AE@viggo.jf.intel.com> <00000142de5634af-f92870a7-efe2-45cd-b50d-a6fbdf3b353c-000000@email.amazonses.com> <52A78B55.8050500@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On Tue, 10 Dec 2013, Dave Hansen wrote:

> >
> > The single page struct definitions makes it easy to see how a certain
> > field is being used in various subsystems. If you add a field then you
> > can see other use cases in other subsystems. If you happen to call
> > them then you know that there is trouble afoot.
>
> First of all, I'd really argue with the assertion that the way it is now
> make it easy to figure anything out.  Maybe we can take a vote. :)

Its certainly easier than it was before where we had page struct defs
spluttered in various subsystems.

> We _need_ to share fields when the structure is handed between different
> subsystems and it needs to be consistent in both places.  For slab page
> at least, the only data that actually gets used consistently is
> page->flags.  It seems silly to bend over backwards just to share a
> single bitfield.

If you get corruption in one field then you need to figure out which other
subsystem could have accessed that field. Its not a single bitfield. There
are numerous relationships between the fields in struct page.

> > How do you ensure that the sizes and the locations of the fields in
> > multiple page structs stay consistent?
>
> Check out the BUILD_BUG_ON().  That shows one example of how we do it
> for a field location.  We could do the same for sizeof() the two.

A bazillion of those? And this is simpler than what we ahve?

> > As far as I can tell we are trying to put everything into one page struct
> > to keep track of the uses of various fields and to allow a reference for
> > newcomes to the kernel.
>
> If the goal is to make a structure which is approachable to newcomers to
> the kernel, then I think we've utterly failed.

I do not see your approach making things easier. Having this stuff in one
place is helpful. I kept on discovering special use cases in various
kernel subsystems that caused breakage because of this and that
special use cases for fields. I think we were only able to optimize
slabs use of struct page because we finally had a better handle on what
uses which field for what purpose.

Looks to me that you want to go back to the old mess because we now have a
more complete accounting of how the fields are used. It may be a horror
but maybe you can help by simplifying things where possible and find as of
yet undocumented use cases for various page struct fields?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
