Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id D81986B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 13:48:14 -0400 (EDT)
Received: by mail-wi0-f176.google.com with SMTP id n15so9661140wiw.9
        for <linux-mm@kvack.org>; Thu, 22 May 2014 10:48:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ey7si4558274wib.77.2014.05.22.10.48.12
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 10:48:13 -0700 (PDT)
Message-ID: <537e385d.8764b40a.0a1f.ffffabccSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Date: Thu, 22 May 2014 13:47:48 -0400
In-Reply-To: <20140522103632.GA23680@node.dhcp.inet.fi>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org> <537d5ee4.4914e00a.5672.ffff85d5SMTPIN_ADDED_BROKEN@mx.google.com> <20140521193336.5df90456.akpm@linux-foundation.org> <CALYGNiMeDtiaA6gfbEYcXbwkuFvTRCLC9KmMOPtopAgGg5b6AA@mail.gmail.com> <20140522103632.GA23680@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, gorcunov@openvz.org

On Thu, May 22, 2014 at 01:36:32PM +0300, Kirill A. Shutemov wrote:
> On Thu, May 22, 2014 at 01:50:22PM +0400, Konstantin Khlebnikov wrote:
> > On Thu, May 22, 2014 at 6:33 AM, Andrew Morton
> > <akpm@linux-foundation.org> wrote:
> > > On Wed, 21 May 2014 22:19:55 -0400 Naoya Horiguchi <n-horiguchi@ah.=
jp.nec.com> wrote:
> > >
> > >> > A much nicer interface would be for us to (finally!) implement
> > >> > fincore(), perhaps with an enhanced per-present-page payload whi=
ch
> > >> > presents the info which you need (although we don't actually kno=
w what
> > >> > that info is!).
> > >>
> > >> page/pfn of each page slot and its page cache tag as shown in patc=
h 4/4.
> > >>
> > >> > This would require open() - it appears to be a requirement that =
the
> > >> > caller not open the file, but no reason was given for this.
> > >> >
> > >> > Requiring open() would address some of the obvious security conc=
erns,
> > >> > but it will still be possible for processes to poke around and g=
et some
> > >> > understanding of the behaviour of other processes.  Careful atte=
ntion
> > >> > should be paid to this aspect of any such patchset.
> > >>
> > >> Sorry if I missed your point, but this interface defines fixed map=
ping
> > >> between file position in /proc/kpagecache and in-file page offset =
of
> > >> the target file. So we do not need to use seq_file mechanism, that=
's
> > >> why open() is not defined and default one is used.
> > >> The same thing is true for /proc/{kpagecount,kpageflags}, from whi=
ch
> > >> I copied/pasted some basic code.
> > >
> > > I think you did miss my point ;) Please do a web search for fincore=
 -
> > > it's a syscall similar to mincore(), only it queries pagecache:
> > > fincore(int fd, loff_t offset, ...).  In its simplest form it queri=
es
> > > just for present/absent, but we could increase the query payload to=

> > > incorporate additional per-page info.
> > >
> > > It would take a lot of thought and discussion to nail down the
> > > fincore() interface (we've already tried a couple of times).  But
> > > unfortunately, fincore() is probably going to be implemented one da=
y
> > > and it will (or at least could) make /proc/kpagecache obsolete.
> > >
> > =

> > It seems fincore() also might obsolete /proc/kpageflags and /proc/pid=
/pagemap.
> > because it might be implemented for /dev/mem and /proc/pid/mem as wel=
l
> > as for normal files.
> =

> > Something like this:
> > int fincore(int fd, u64 *kpf, u64 *pfn, size_t length, off_t offset)
> =

> As always with new syscalls flags are missing ;)
> =

> u64 for kpf doesn't sound future proof enough. What about this:
> =

> int fincore(int fd, size_t length, off_t offset,
> 	unsigned long flags, void *records);
> =

> Format of records is defined by what user asks in flags. Like:
> =

>  - FINCORE_PFN: records are 64-bit each with pfn;
>  - FINCORE_PAGE_FLAGS: records are 64-bit each with flags;

I hope that the flags we get from this mode contains pagecache tag info
as well as KPF_*.

>  - FINCORE_PFN | FINCORE_PAGE_FLAGS: records are 128-bit each with pfns=

>    followed by flags (or vice versa);
> =

> New flags can extend the format if we would want to expose more info.
> =

> Comments?

Maybe mincore()-like bitmap mode (FINCORE_BMAP) is also helpful who wants=

minimum memory footprint?

Anyway I like this extensible interface you're suggesting.

> BTW, does everybody happy with mincore() interface? We report 1 there i=
f
> pte is present, but it doesn't really say much about the page for cases=

> like zero page...

According to manpage of mincore(2), =

  mincore()  returns a vector that indicates whether pages of the calling=
 process's vir=E2=80=90
  tual memory are resident in core (RAM), and so will not  cause  a  disk=
  access  (page
  fault) if referenced.  ...

so we can assume that the callers want to predict whether they will have
page faults. But it depends on whether the access is read or write.
So I think current mincore() is not enough to do this prediction precisel=
y
for privately shared pages (including zero page and ksm page).
Maybe we need a new syscall to solving this problem.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
