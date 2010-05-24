Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81ECB6B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 16:04:12 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <1b84523f-a7df-4d6a-870f-b684bd012230@default>
Date: Mon, 24 May 2010 13:02:34 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Cleancache [PATCH 2/7] (was Transcendent Memory): core files
References: <20100422132809.GA27302@ca-server1.us.oracle.com
 20100514231815.GY30031@ZenIV.linux.org.uk>
In-Reply-To: <20100514231815.GY30031@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: chris.mason@oracle.com, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> From: Al Viro [mailto:viro@ZenIV.linux.org.uk]
> Subject: Re: Cleancache [PATCH 2/7] (was Transcendent Memory): core files

Hi Al!

Thanks for the feedback!  Sorry for the delayed response.

> ...again, use sane types...

Good point.  Will fix types for next rev (using size_t, ino_t,
and pgoff_t).

> > +=09int (*get_page)(int, unsigned long, unsigned long, struct page *);
>=20
> Ugh.  First of all, presumably you have some structure behind that
> index, don't you?  Might be a better way to do it.

Not quite sure what you mean here.  The index is really
just part of a unique handle for cleancache to identify
the (page of) data.

> What's more, use of ->i_ino is simply wrong.  How stable do you want that
> to be and how much do you want it to outlive struct address_space in ques=
tion?
> From my reading of your code, it doesn't outlive that anyway, so...

Unless I misunderstand your point, no, the inode never outlives
the address space because the specification requires the kernel
to ensure coherency; if the inode were about to outlive the
address space, the cleancache_flush operations must be invoked
(and I think the patch covers all the necessary cases).

> The third one is pgoff_t; again, use sane types, _if_ you actually want
> the argument #3 at all - it can be derived from struct page you are
> passing there as well.

I thought it best to declare the _ops so that the struct page
is opaque to the "backend" (driver).  The kernel-side ("frontend")
defines the handle and ensures coherency, so the backend shouldn't
be allowed to derive or muck with the three-tuple passed by the
kernel. In the existing (Xen tmem) driver, the only operation
performed on the struct page parameter is page_to_pfn().  OTOH,
I could go one step further and pass a pfn_t instead of a
struct page, since it is really only the physical page frame that
the backend needs to know about and (synchronously) read/write from/to.

Thoughts?

Thanks again!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
