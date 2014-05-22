Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2F0656B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 06:37:09 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id t10so2458711eei.14
        for <linux-mm@kvack.org>; Thu, 22 May 2014 03:37:08 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.199])
        by mx.google.com with ESMTP id 9si14470249eei.96.2014.05.22.03.37.07
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 03:37:07 -0700 (PDT)
Date: Thu, 22 May 2014 13:36:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Message-ID: <20140522103632.GA23680@node.dhcp.inet.fi>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org>
 <537d5ee4.4914e00a.5672.ffff85d5SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140521193336.5df90456.akpm@linux-foundation.org>
 <CALYGNiMeDtiaA6gfbEYcXbwkuFvTRCLC9KmMOPtopAgGg5b6AA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiMeDtiaA6gfbEYcXbwkuFvTRCLC9KmMOPtopAgGg5b6AA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, Cyrill Gorcunov <gorcunov@openvz.org>

On Thu, May 22, 2014 at 01:50:22PM +0400, Konstantin Khlebnikov wrote:
> On Thu, May 22, 2014 at 6:33 AM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Wed, 21 May 2014 22:19:55 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> >
> >> > A much nicer interface would be for us to (finally!) implement
> >> > fincore(), perhaps with an enhanced per-present-page payload which
> >> > presents the info which you need (although we don't actually know what
> >> > that info is!).
> >>
> >> page/pfn of each page slot and its page cache tag as shown in patch 4/4.
> >>
> >> > This would require open() - it appears to be a requirement that the
> >> > caller not open the file, but no reason was given for this.
> >> >
> >> > Requiring open() would address some of the obvious security concerns,
> >> > but it will still be possible for processes to poke around and get some
> >> > understanding of the behaviour of other processes.  Careful attention
> >> > should be paid to this aspect of any such patchset.
> >>
> >> Sorry if I missed your point, but this interface defines fixed mapping
> >> between file position in /proc/kpagecache and in-file page offset of
> >> the target file. So we do not need to use seq_file mechanism, that's
> >> why open() is not defined and default one is used.
> >> The same thing is true for /proc/{kpagecount,kpageflags}, from which
> >> I copied/pasted some basic code.
> >
> > I think you did miss my point ;) Please do a web search for fincore -
> > it's a syscall similar to mincore(), only it queries pagecache:
> > fincore(int fd, loff_t offset, ...).  In its simplest form it queries
> > just for present/absent, but we could increase the query payload to
> > incorporate additional per-page info.
> >
> > It would take a lot of thought and discussion to nail down the
> > fincore() interface (we've already tried a couple of times).  But
> > unfortunately, fincore() is probably going to be implemented one day
> > and it will (or at least could) make /proc/kpagecache obsolete.
> >
> 
> It seems fincore() also might obsolete /proc/kpageflags and /proc/pid/pagemap.
> because it might be implemented for /dev/mem and /proc/pid/mem as well
> as for normal files.
> 
> Something like this:
> int fincore(int fd, u64 *kpf, u64 *pfn, size_t length, off_t offset)

As always with new syscalls flags are missing ;)

u64 for kpf doesn't sound future proof enough. What about this:

int fincore(int fd, size_t length, off_t offset,
	unsigned long flags, void *records);

Format of records is defined by what user asks in flags. Like:

 - FINCORE_PFN: records are 64-bit each with pfn;
 - FINCORE_PAGE_FLAGS: records are 64-bit each with flags;
 - FINCORE_PFN | FINCORE_PAGE_FLAGS: records are 128-bit each with pfns
   followed by flags (or vice versa);

New flags can extend the format if we would want to expose more info.

Comments?

BTW, does everybody happy with mincore() interface? We report 1 there if
pte is present, but it doesn't really say much about the page for cases
like zero page...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
