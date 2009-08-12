Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 29AC66B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 16:23:50 -0400 (EDT)
Date: Wed, 12 Aug 2009 21:23:39 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: vma_merge issue
In-Reply-To: <a1b36c3a0908121204q1b59df1fk86afec9d05ec16dc@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0908122038360.18426@sister.anvils>
References: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>
 <Pine.LNX.4.64.0908121841550.14314@sister.anvils>
 <a1b36c3a0908121204q1b59df1fk86afec9d05ec16dc@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-14141038-1250108619=:18426"
Sender: owner-linux-mm@kvack.org
To: Bill Speirs <bill.speirs@gmail.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-14141038-1250108619=:18426
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 12 Aug 2009, Bill Speirs wrote:
> On Wed, Aug 12, 2009 at 2:26 PM, Hugh Dickins<hugh.dickins@tiscali.co.uk>=
 wrote:
> > On Mon, 10 Aug 2009, Bill Speirs wrote:
> >>
> >> Can anyone shed some light on this? While it isn't an issue for 3
> >> pages, I'm mmaping 200K+ pages and changing the perms on random pages
> >> throughout and then back but I quickly run into the max_map_count when
> >> I don't actually need that many mappings.
> >
> > But that's easily dealt with: just make your mmap PROT_READ|PROT_WRITE,
> > which will account for the whole extent; then mprotect it all PROT_NONE=
,
> > which will take you to your previous starting position; then proceed as
> > before - the vmas should get merged as they are reset back to PROT_NONE=
=2E
> > That works, doesn't it?
>=20
> Unfortunately, that doesn't work. When I mmap pages as PROT_WRITE it
> is checked against the CommitLimit and returns with ENOMEM as I'm
> mmaping a lot of pages. However, I don't actually want to be charged
> for that memory, as I won't be using all of it. This is why I mmap as
> PROT_NONE as I'm not charged for it.

I'm sorry, I hadn't realized you're working in an overcommit_memory 2
environment.  And it's not single user, so you don't have the freedom
to adjust /proc/sys/vm/overcommit_ratio to suit your needs?

> Then when I set a page to
> PROT_WRITE I get charged (which is expected and OK), but then going
> back to PROT_NONE I don't get "uncharged". This makes sense as I could
> simply PROT_WRITE that page again and I should be charged.

Even if you never wrote to it again, PROT_READ would have to show you
the same content as was in there before, so you definitely still need
to be charged for it.

> However, I
> have no way (that I know of) to tell the kernel "I'm done with this
> page, don't charge me for it, and set it's protection to PROT_NONE."
> I've tried madvise with MADV_DONTNEED but that doesn't seem to remove
> the VM_ACCOUNT flag.

MADV_DONTNEED: brilliant idea, what a shame it doesn't work for you.
I'd been on the point of volunteering a bugfix to it to do what you
want, it would make sense; but there's a big but... we have sold
MADV_DONTNEED as an madvise that only needs non-exclusive access
to the mmap_sem, which means it can be used concurrently with faulting,
which has made it much more useful to glibc (I believe).  If we were
to fiddle with vmas and accounting and merging in there, it would go
back to needing exclusive mmap_sem, which would hurt important users.

There could be a MADV_BILL_SPEIRS_WONTNEED, but even if we could
agree on a more impartial name for it, it might be hard to justify,
and tiresome to write the man page explaining when to use this and
when to use that.  Could be done, but...

Oh, I've somehow missed your next paragraph...

>=20
> I have seen an mm patch that introduces MADV_FREE, which I believe
> removes the VM_ACCOUNT flag and decrements the commit charge. Does it
> make sense to have this type of functionality? Can I get this same
> type of functionality (start without being charged for a page, use it,
> then un-use it and remove the charge for it?) currently?

The name MADV_FREE is vaguely familiar, let's see, Rik, 2007.
Looking at that patch, no, it didn't remove the commit charge:
it kept quite close to MADV_DONTNEED in that respect.  I think
Nick's non-exclusive mmap_sem mod to MADV_DONTNEED solved the
particular problem which MADV_FREE was proposed for, in a much
simpler way, so MADV_FREE didn't get any further.

What could you do?  Some variously unsatisfactory solutions,
all of which you've probably rejected already:

Raise max_map_count via /proc/sys/vm/max_map_count
(but probably you don't have access to do so)

Don't mmap the arena in the first place, or mmap it and then munmap
all but start and end, use MAP_FIXED within the arena for your pages,
and pray that no library might be mmap'ing in there while you're
running (and maybe the architecture's address choices will help you).

Don't use anonymous memory, have a 1GB sparse file to back this,
and mmap it MAP_SHARED, then you won't get charged for RAM+swap.

All of them copouts, but the last maybe the best.

>=20
> > (I must offer a big thank you: replying to your mail just after writing
> > a mail about the ZERO_PAGE, brings me to realize - if I'm not mistaken =
-
> > that we broke the accounting of initially non-writable anonymous areas
> > when we stopped using the ZERO_PAGE there, but marked readfaulted pages
> > as dirty. =C2=A0Looks like another argument to bring them back.)
>=20
> I'm not 100% sure what you're talking about with respect to ZERO_PAGE,
> but I'm happy to help :-)

I was rather talking to myself and a few others there, but the important
thing is, that I have helped to make you happy :-)

(It is spooky that the mail about ZERO_PAGE that I refer to,
also involved comments about MADV_DONTNEED and alternatives.)

Hugh
--8323584-14141038-1250108619=:18426--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
