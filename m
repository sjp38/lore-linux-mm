Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1D4B76B01F1
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 10:50:57 -0400 (EDT)
Subject: Re: No one seems to be using AOP_WRITEPAGE_ACTIVATE?
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
From: Theodore Tso <tytso@MIT.EDU>
In-Reply-To: <20100426094837.2E5E.A69D9226@jp.fujitsu.com>
Date: Mon, 26 Apr 2010 10:50:45 -0400
Content-Transfer-Encoding: quoted-printable
Message-Id: <7B2E5B6F-3C25-4EF5-AC2F-AE62E9C643C2@mit.edu>
References: <E1O5rld-0001AX-Lk@closure.thunk.org> <20100426094837.2E5E.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>


On Apr 26, 2010, at 6:18 AM, KOSAK
> AOP_WRITEPAGE_ACTIVATE was introduced for ramdisk and tmpfs thing
> (and later rd choosed to use another way).
> Then, It assume writepage refusing aren't happen on majority pages.
> IOW, the VM assume other many pages can writeout although the page =
can't.
> Then, the VM only make page activation if AOP_WRITEPAGE_ACTIVATE is =
returned.
> but now ext4 and btrfs refuse all writepage(). (right?)

No, not exactly.   Btrfs refuses the writepage() in the direct reclaim =
cases (i.e., if PF_MEMALLOC is set), but will do writepage() in the case =
of zone scanning.  I don't want to speak for Chris, but I assume it's =
due to stack depth concerns --- if it was just due to worrying about fs =
recursion issues, i assume all of the btrfs allocations could be done =
GFP_NOFS.

Ext4 is slightly different; it refuses writepages() if the inode blocks =
for the page haven't yet been allocated.  (Regardless of whether it's =
happening for direct reclaim or zone scanning.)  However, if the on-disk =
block has been assigned (i.e., this isn't a delalloc case), ext4 will =
honor the writepage().   (i.e., if this is an mmap of an already =
existing file, or if the space has been pre-allocated using =
fallocate()).    The reason for ext4's concern is lock ordering, =
although I'm investigating whether I can fix this.   If we call =
set_page_writeback() to set PG_writeback (plus set the various bits of =
magic fs accounting), and then drop the page_lock, does that protect us =
from random changes happening to the page (i.e., from vmtruncate, etc.)?

>=20
> IOW, I don't think such documentation suppose delayed allocation issue =
;)
>=20
> The point is, Our dirty page accounting only account per-system-memory
> dirty ratio and per-task dirty pages. but It doesn't account =
per-numa-node
> nor per-zone dirty ratio. and then, to refuse write page and fake numa
> abusing can make confusing our vm easily. if _all_ pages in our VM LRU
> list (it's per-zone), page activation doesn't help. It also lead to =
OOM.
>=20
> And I'm sorry. I have to say now all vm developers fake numa is not
> production level quority yet. afaik, nobody have seriously tested our
> vm code on such environment. (linux/arch/x86/Kconfig says "This is =
only=20
> useful for debugging".)

So I'm sorry I mentioned the fake numa bit, since I think this is a bit =
of a red herring.   That code is in production here, and we've made all =
sorts of changes so ti can be used for more than just debugging.  So =
please ignore it, it's our local hack, and if it breaks that's our =
problem.    More importantly, just two weeks ago I talked to soeone in =
the financial sector, who was testing out ext4 on an upstream kernel, =
and not using our hacks that force 128MB zones, and he ran into the =
ext4/OOM problem while using an upstream kernel.  It involved Oracle =
pinning down 3G worth of pages, and him trying to do a huge streaming =
backup (which of course wasn't using fallocate or direct I/O) under =
ext4, and he had the same issue --- an OOM, that I'm pretty sure was =
caused by the fact that ext4_writepage() was refusing the writepage() =
and most of the pages weren't nailed down by Oracle were delalloc.    =
The same test scenario using ext3 worked just fine, of course.

Under normal cases it's not a problem since statistically there should =
be enough other pages in the system compared to the number of pages that =
are subject to delalloc, such that pages can usually get pushed out =
until the writeback code can get around to writing out the pages.   But =
in cases where the zones have been made artificially small, or you have =
a big program like Oracle pinning down a large number of pages, then of =
course we have problems.=20

I'm trying to fix things from the file system side, which means trying =
to understand magic flags like AOP_WRITEPAGE_ACTIVATE, which is =
described in Documentation/filesystems/Locking as something which MUST =
be used if writepage() is going refuse a page.  And then I discovered no =
one is actually using it.   So that's why I was asking with respect =
whether the Locking documentation file was out of date, or whether all =
of the file systems are doing it wrong.

On a related example of how file system code isnt' necessarily following =
what is required/recommended by the Locking documentation, ext2 and ext3 =
are both NOT using set_page_writeback()/end_page_writeback(), but are =
rather keeping the page locked until after they call =
block_write_full_page(), because of concerns of truncate coming in and =
screwing things up.   But now looking at Locking, it appears that =
set_page_writeback() is as good as page_lock() for preventing the =
truncate code from coming in and screwing everything up?   It's not =
clear to me exactly what locking guarantees are provided against =
truncate by set_page_writeback().   And suppose we are writing out a =
whole cluster of pages, say 4MB worth of pages; do we need to call =
set_page_writeback() on every single page in the cluster before we do =
the I/O to make sure things don't change out from under us?  (I'm pretty =
sure at least some of the other filesystems that are submitting huge =
numbers of pages using bio instead of 4k at a time like ext2/3/4 aren't =
calling set_page_writeback() on all of the pages first.)

Part of the problem is that the writeback Locking semantics aren't well =
documented, and where they are documented, it's not clear they are up to =
date --- and all of the file systems that are doing delayed allocation =
writeback are doing things slightly differently, or in some cases very =
differently.    (And even without delalloc, as I've pointed out ext2/3 =
don't use set_page_writeback() --- if this is a MUST USE as implied by =
the Locking file, why did whoever added this requirement didn't go in =
and modify common filesystems like ext2 and ext3 to use the =
set_page_writeback/end_page_writeback calls?)

I'm happy to change things in ext4; in fact I'm pretty sure ext4 =
probably isn't completely right here.   But it's not clear what "right" =
actually is, and when I look to see what protects writepage() racing =
with vmtruncate(), it's enough to give me a headache.  :-(   =20

Hence my question about wouldn't it be simpler if we simply added more =
high-level locking to prevent truncate from racing against =
writepage/writeback. =20

-- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
