Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id BF19D8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 07:31:20 -0500 (EST)
Received: by mail-io0-f182.google.com with SMTP id d63so171351530ioj.2
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 04:31:20 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id c18si11230557igr.73.2016.02.07.04.31.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 07 Feb 2016 04:31:19 -0800 (PST)
Date: Sun, 7 Feb 2016 21:31:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v5 00/12] MADV_FREE support
Message-ID: <20160207123120.GA16116@bbox>
References: <20160205021557.GA11598@bbox>
 <56B5F5D2.70309@gmail.com>
MIME-Version: 1.0
In-Reply-To: <56B5F5D2.70309@gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com, Andy Lutomirski <luto@amacapital.net>

On Sat, Feb 06, 2016 at 02:32:02PM +0100, Michael Kerrisk (man-pages) wrote:
> Hello Minchan,
>=20
> On 02/05/2016 03:15 AM, Minchan Kim wrote:
> > On Thu, Jan 28, 2016 at 08:16:25AM +0100, Michael Kerrisk (man-pages) w=
rote:
> >> Hello Minchan,
> >>
> >> On 11/30/2015 07:39 AM, Minchan Kim wrote:
> >>> In v4, Andrew wanted to settle in old basic MADV=5FFREE and introduces
> >>> new stuffs(ie, lazyfree LRU, swapless support and lazyfreeness) later
> >>> so this version doesn't include them.
> >>>
> >>> I have been tested it on mmotm-2015-11-25-17-08 with additional
> >>> patch[1] from Kirill to prevent BUG=5FON which he didn't send to
> >>> linux-mm yet as formal patch. With it, I couldn't find any
> >>> problem so far.
> >>>
> >>> Note that this version is based on THP refcount redesign so
> >>> I needed some modification on MADV=5FFREE because split=5Fhuge=5Fpmd
> >>> doesn't split a THP page any more and pmd=5Ftrans=5Fhuge(pmd) is not
> >>> enough to guarantee the page is not THP page.
> >>> As well, for MAVD=5FFREE lazy-split, THP split should respect
> >>> pmd's dirtiness rather than marking ptes of all subpages dirty
> >>> unconditionally. Please, review last patch in this patchset.
> >>
> >> Now that MADV=5FFREE has been merged, would you be willing to write
> >> patch to the madvise(2) man page that describes the semantics,=20
> >> noes limitations and restrictions, and (ideally) has some sentences
> >> describing use cases?
> >>
> >=20
> > Hello Michael,
> >=20
> > Could you review this patch?
> >=20
> > Thanks.
> >=20
> >>From 203372f901f574e991215fdff6907608ba53f932 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Fri, 5 Feb 2016 11:09:54 +0900
> > Subject: [PATCH] madvise.2: Add MADV=5FFREE
> >=20
> > Document the MADV=5FFREE flags added to madvise() in Linux 4.5
> >=20
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  man2/madvise.2 | 19 +++++++++++++++++++
> >  1 file changed, 19 insertions(+)
> >=20
> > diff --git a/man2/madvise.2 b/man2/madvise.2
> > index c1df67c..4704304 100644
> > --- a/man2/madvise.2
> > +++ b/man2/madvise.2
> > @@ -143,6 +143,25 @@ flag are special memory areas that are not managed
> >  by the virtual memory subsystem.
> >  Such pages are typically created by device drivers that
> >  map the pages into user space.)
> > +.TP
> > +.B MADV=5FFREE " (since Linux 4.5)"
> > +Application is finished with the given range, so kernel can free
> > +resources associated with it but the freeing could be delayed until
> > +memory pressure happens or canceld by write operation by user.
> > +
> > +After a successful MADV=5FFREE operation, user shouldn't expect kernel
> > +keeps stale data on the page. However, subsequent write of pages
> > +in the range will succeed and then kernel cannot free those dirtied pa=
ges
> > +so user can always see just written data. If there was no subsequent
> > +write, kernel can free those clean pages any time. In such case,
> > +user can see zero-fill-on-demand pages.
> > +
> > +Note that, it works only with private anonymous pages (see
> > +.BR mmap (2)).
> > +On swapless system, freeing pages in given range happens instantly
> > +regardless of memory pressure.
> > +
> > +
> >  .\"
> >  .\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >  .\"
> >=20
>=20
> Thanks for the nice text! I reworked somewhat, trying to fill out a
> few details about how I understand things work, but I may have introduced
> errors, so I would be happy if you would check the following text:

Below looks good to me.
Thanks, Michael

>=20
>        MADV=5FFREE (since Linux 4.5)
>               The  application  no  longer  requires  the pages in the
>               range specified by addr and len.  The  kernel  can  thus
>               free these pages, but the freeing could be delayed until
>               memory pressure occurs.  For each of the pages that  has
>               been  marked to be freed but has not yet been freed, the
>               free operation will be canceled  if  the  caller  writes
>               into  the page.  After a successful MADV=5FFREE operation,
>               any stale data (i.e., dirty, unwritten  pages)  will  be
>               lost  when  the kernel frees the pages.  However, subse=E2=
=80=90
>               quent writes to pages in the range will succeed and then
>               kernel  cannot  free  those  dirtied  pages, so that the
>               caller can always see just written data.  If there is no
>               subsequent  write,  the kernel can free the pages at any
>               time.  Once pages in the  range  have  been  freed,  the
>               caller  will  see  zero-fill-on-demand pages upon subse=E2=
=80=90
>               quent page references.
>=20
>               The MADV=5FFREE operation can be applied only  to  private
>               anonymous  pages  (see  mmap(2)).  On a swapless system,
>               freeing  pages  in  a  given  range  happens  instantly,
>               regardless of memory pressure.
>=20
> Thanks,
>=20
> Michael
>=20
> --=20
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
