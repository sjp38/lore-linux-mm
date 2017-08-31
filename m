Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3D16B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 12:49:55 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id b2so998985iof.5
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 09:49:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor295175itk.68.2017.08.31.09.49.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 Aug 2017 09:49:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <150413449482.5923.1348069619036923853.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150413450616.5923.7069852068237042023.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 31 Aug 2017 09:49:52 -0700
Message-ID: <CA+55aFzo4oV87tVjEzx+cHVxfihm=31+fWtsdWow3AmfsdzJJw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: introduce MAP_VALIDATE, a mechanism for for
 safely defining new mmap flags
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, Andrew Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

This patch strikes me as insane.

On Wed, Aug 30, 2017 at 4:08 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>                 switch (flags & MAP_TYPE) {
> +               case (MAP_SHARED|MAP_VALIDATE):
> +                       /* TODO: new map flags */
> +                       return -EINVAL;
>                 case MAP_SHARED:
>                         if ((prot&PROT_WRITE) && !(file->f_mode&FMODE_WRITE))
>                                 return -EACCES;

So you "add" support for MAP_SHARED|MAP_VALIDATE, but then error out on it.

And you don't add support for MAP_PRIVATE|MAP_VALIDATE at all, so that
errors out too.

Which makes me think that you actually only want MAP:_VALIDATE support
for shared mappings.

Which in turn means that all your blathering about how this cannot
work on HP-UX is just complete garbage, because you might as well just
realize that MAP_TYPE isn't a mask of _bitmasks_, it's a mask of
values.

So just make MAP_VALIDATE be 0x3. Which works for everybody. Make it
mean the same as MAP_SHARED with flag validation. End of story.

None of these stupid games that are complete and utter garbage, and
make people think that the MAP_TYPE bits are somehow a bitmask. They
aren't. The bitmasks are all the *other* bits that aren't in
MAP_TYTPE.

Yes, yes, I see why you *think* you want a bitmap. You think you want
a bitmap because you want to make MAP_VALIDATE be part of MAP_SYNC
etc, so that people can do

    ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED |
MAP_SYNC, fd, 0);

and "know" that MAP_SYNC actually takes.

And I'm saying that whole wish is bogus. You're fundamentally
depending on special semantics, just make it explicit. It's already
not portable, so don't try to make it so.

Rename that MAP_VALIDATE as MAP_SHARED_VALIDATE, make it have a valud
of 0x3, and make people do

   ret = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED_VALIDATE
| MAP_SYNC, fd, 0);

and then the kernel side is easier too (none of that random garbage
playing games with looking at the "MAP_VALIDATE bit", but just another
case statement in that map type thing.

Boom. Done.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
