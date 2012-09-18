Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 971156B006C
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 04:51:55 -0400 (EDT)
From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: Does swap_set_page_dirty() calling ->set_page_dirty() make sense?
Date: Tue, 18 Sep 2012 10:51:50 +0200
References: <20120917163518.GD9150@quack.suse.cz> <alpine.LSU.2.00.1209171204100.6720@eggly.anvils> <20120918021627.GF9150@quack.suse.cz>
In-Reply-To: <20120918021627.GF9150@quack.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201209181051.50541.ptesarik@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

Dne =C3=9At 18. z=C3=A1=C5=99=C3=AD 2012 04:16:27 Jan Kara napsal(a):
> On Mon 17-09-12 12:15:46, Hugh Dickins wrote:
> > On Mon, 17 Sep 2012, Jan Kara wrote:
> > >   I tripped over a crash in reiserfs which happened due to
> > >   PageSwapCache
> > >=20
> > > page being passed to reiserfs_set_page_dirty(). Now it's not that hard
> > > to make reiserfs_set_page_dirty() check that case but I really wonder:
> > > Does it make sense to call mapping->a_ops->set_page_dirty() for a
> > > PageSwapCache page? The page is going to be written via direct IO so
> > > from the POV of the filesystem there's no need for any dirtiness
> > > tracking. Also there are several ->set_page_dirty() implementations
> > > which will spectacularly crash because they do things like
> > > page->mapping->host, or call
> > > __set_page_dirty_buffers() which expects buffer heads in page->privat=
e.
> > > Or what is the reason for calling filesystem's set_page_dirty()
> > > function?
> >=20
> > This is a question for Mel, really: it used not to call the filesystem.
> >=20
> > But my reading of the 3.6 code says that it still will not call the
> > filesystem, unless the filesystem (only nfs) provides a swap_activate
> > method, which should be the only case in which SWP_FILE gets set.
> > And I rather think Mel does want to use the filesystem set_page_dirty
> > in that case.  Am I misreading?
> >=20
> > Did you see this on a vanilla kernel?  Or is it possible that you have
> > a private patch merged in, with something else sharing the SWP_FILE bit
> > (defined in include/linux/swap.h) by mistake?
>=20
>   Argh, sorry. It is indeed a SLES specific bug. I missed that SWP_FILE b=
it
> gets set only when swap_activate() is provided (SLES code works a bit
> differently in this area but I wasn't really looking into that since I was
> focused elsewhere).
>=20
> So just one minor nit for Mel. SWP_FILE looks like a bit confusing name f=
or
> a flag that gets set only for some swap files ;) At least I didn't pay
> attention to it because I thought it's set for all of them. Maybe call it
> SWP_FILE_CALL_AOPS or something like that?

Same here. In fact, I believed that other filesystems only work by accident=
=20
(because they don't have to access the mapping). I'm not even sure about th=
e=20
semantics of the swap_activate operation. Is this documented somewhere?

Petr Tesarik
SUSE Linux

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
