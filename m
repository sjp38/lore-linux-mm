Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1A9F76B01F2
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 09:03:26 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3RD3JrD031423
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Apr 2010 22:03:19 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D21F45DE51
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 22:03:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FA5A45DE4F
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 22:03:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 578CD1DB8038
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 22:03:19 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 08819E08001
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 22:03:19 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: No one seems to be using AOP_WRITEPAGE_ACTIVATE?
In-Reply-To: <7B2E5B6F-3C25-4EF5-AC2F-AE62E9C643C2@mit.edu>
References: <20100426094837.2E5E.A69D9226@jp.fujitsu.com> <7B2E5B6F-3C25-4EF5-AC2F-AE62E9C643C2@mit.edu>
Message-Id: <20100427214722.80DC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 27 Apr 2010 22:03:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@MIT.EDU>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

>=20
> On Apr 26, 2010, at 6:18 AM, KOSAK
> > AOP_WRITEPAGE_ACTIVATE was introduced for ramdisk and tmpfs thing
> > (and later rd choosed to use another way).
> > Then, It assume writepage refusing aren't happen on majority pages.
> > IOW, the VM assume other many pages can writeout although the page can'=
t.
> > Then, the VM only make page activation if AOP_WRITEPAGE_ACTIVATE is ret=
urned.
> > but now ext4 and btrfs refuse all writepage(). (right?)
>=20
> No, not exactly.   Btrfs refuses the writepage() in the direct reclaim ca=
ses (i.e., if PF_MEMALLOC is set), but will do writepage() in the case of z=
one scanning.  I don't want to speak for Chris, but I assume it's due to st=
ack depth concerns --- if it was just due to worrying about fs recursion is=
sues, i assume all of the btrfs allocations could be done GFP_NOFS.
>=20
> Ext4 is slightly different; it refuses writepages() if the inode blocks f=
or the page haven't yet been allocated.  (Regardless of whether it's happen=
ing for direct reclaim or zone scanning.)  However, if the on-disk block ha=
s been assigned (i.e., this isn't a delalloc case), ext4 will honor the wri=
tepage().   (i.e., if this is an mmap of an already existing file, or if th=
e space has been pre-allocated using fallocate()).    The reason for ext4's=
 concern is lock ordering, although I'm investigating whether I can fix thi=
s.   If we call set_page_writeback() to set PG_writeback (plus set the vari=
ous bits of magic fs accounting), and then drop the page_lock, does that pr=
otect us from random changes happening to the page (i.e., from vmtruncate, =
etc.)?
>=20
> >=20
> > IOW, I don't think such documentation suppose delayed allocation issue =
;)
> >=20
> > The point is, Our dirty page accounting only account per-system-memory
> > dirty ratio and per-task dirty pages. but It doesn't account per-numa-n=
ode
> > nor per-zone dirty ratio. and then, to refuse write page and fake numa
> > abusing can make confusing our vm easily. if _all_ pages in our VM LRU
> > list (it's per-zone), page activation doesn't help. It also lead to OOM.
> >=20
> > And I'm sorry. I have to say now all vm developers fake numa is not
> > production level quority yet. afaik, nobody have seriously tested our
> > vm code on such environment. (linux/arch/x86/Kconfig says "This is only=
=20
> > useful for debugging".)
>=20
> So I'm sorry I mentioned the fake numa bit, since I think this is a bit o=
f a red herring.   That code is in production here, and we've made all sort=
s of changes so ti can be used for more than just debugging.  So please ign=
ore it, it's our local hack, and if it breaks that's our problem.    More i=
mportantly, just two weeks ago I talked to soeone in the financial sector, =
who was testing out ext4 on an upstream kernel, and not using our hacks tha=
t force 128MB zones, and he ran into the ext4/OOM problem while using an up=
stream kernel.  It involved Oracle pinning down 3G worth of pages, and him =
trying to do a huge streaming backup (which of course wasn't using fallocat=
e or direct I/O) under ext4, and he had the same issue --- an OOM, that I'm=
 pretty sure was caused by the fact that ext4_writepage() was refusing the =
writepage() and most of the pages weren't nailed down by Oracle were delall=
oc.    The same test scenario using ext3 worked just fine, of course.
>=20
> Under normal cases it's not a problem since statistically there should be=
 enough other pages in the system compared to the number of pages that are =
subject to delalloc, such that pages can usually get pushed out until the w=
riteback code can get around to writing out the pages.   But in cases where=
 the zones have been made artificially small, or you have a big program lik=
e Oracle pinning down a large number of pages, then of course we have probl=
ems.=20
>=20
> I'm trying to fix things from the file system side, which means trying to=
 understand magic flags like AOP_WRITEPAGE_ACTIVATE, which is described in =
Documentation/filesystems/Locking as something which MUST be used if writep=
age() is going refuse a page.  And then I discovered no one is actually usi=
ng it.   So that's why I was asking with respect whether the Locking docume=
ntation file was out of date, or whether all of the file systems are doing =
it wrong.
>=20
> On a related example of how file system code isnt' necessarily following =
what is required/recommended by the Locking documentation, ext2 and ext3 ar=
e both NOT using set_page_writeback()/end_page_writeback(), but are rather =
keeping the page locked until after they call block_write_full_page(), beca=
use of concerns of truncate coming in and screwing things up.   But now loo=
king at Locking, it appears that set_page_writeback() is as good as page_lo=
ck() for preventing the truncate code from coming in and screwing everythin=
g up?   It's not clear to me exactly what locking guarantees are provided a=
gainst truncate by set_page_writeback().   And suppose we are writing out a=
 whole cluster of pages, say 4MB worth of pages; do we need to call set_pag=
e_writeback() on every single page in the cluster before we do the I/O to m=
ake sure things don't change out from under us?  (I'm pretty sure at least =
some of the other filesystems that are submitting huge numbers of pages usi=
ng bio instead of 4k at a time like ext2/3/4 aren't calling set_page_writeb=
ack() on all of the pages first.)
>=20
> Part of the problem is that the writeback Locking semantics aren't well d=
ocumented, and where they are documented, it's not clear they are up to dat=
e --- and all of the file systems that are doing delayed allocation writeba=
ck are doing things slightly differently, or in some cases very differently.=
    (And even without delalloc, as I've pointed out ext2/3 don't use set_pa=
ge_writeback() --- if this is a MUST USE as implied by the Locking file, wh=
y did whoever added this requirement didn't go in and modify common filesys=
tems like ext2 and ext3 to use the set_page_writeback/end_page_writeback ca=
lls?)
>=20
> I'm happy to change things in ext4; in fact I'm pretty sure ext4 probably=
 isn't completely right here.   But it's not clear what "right" actually is=
, and when I look to see what protects writepage() racing with vmtruncate()=
, it's enough to give me a headache.  :-(   =20

Umm.. sorry, I'm not good person to answer your question.=20
probably Nick has best knowledge in this area.

afaics, vmtruncate call graph is here.

vmtruncate
 -> truncate_pagecache
    -> truncate_inode_pages
       -> truncate_inode_pages_range
            lock_page(page);
            wait_on_page_writeback(page);
            truncate_inode_page(mapping, page);
             -> truncate_complete_page
                -> remove_from_page_cache
             ....
            unlock_page(page);

Then, PG_lock and/or PG_writeback protect against remove_from_page_cache().

But..
Now I'm afraid it can't solve ext4 delalloc issue. I'm pretty sure =20
you have done above easy grepping. I guess you are suffering from more
difficult issue. I hope to ask you, why ext4 couing logic of number of
delalloc pages can't take page lock?

and, today's my grep result is,=20

ext2_writepage
  block_write_full_page
    block_write_full_page_endio
      __block_write_full_page
        set_page_writeback

end_buffer_async_write
  end_page_writeback


ext3 seems to have similar logic of ext2. Am I missing something?




>=20
> Hence my question about wouldn't it be simpler if we simply added more hi=
gh-level locking to prevent truncate from racing against writepage/writebac=
k. =20
>=20
> -- Ted
>=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
