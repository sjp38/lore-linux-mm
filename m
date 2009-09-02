Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BD1A26B005A
	for <linux-mm@kvack.org>; Wed,  2 Sep 2009 04:34:56 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/3] Add MAP_HUGETLB for mmaping pseudo-anonymous huge page regions
Date: Wed, 2 Sep 2009 10:34:40 +0200
References: <cover.1251282769.git.ebmunson@us.ibm.com> <20090901130801.GB7995@us.ibm.com> <Pine.LNX.4.64.0909011418490.8674@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909011418490.8674@sister.anvils>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200909021034.40827.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, linux-man@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, randy.dunlap@oracle.com
List-ID: <linux-mm.kvack.org>

On Tuesday 01 September 2009, Hugh Dickins wrote:
> On Tue, 1 Sep 2009, Eric B Munson wrote:
> > On Tue, 01 Sep 2009, Hugh Dickins wrote:
> > > 
> > > That is explained by you #defining MAP_HUGETLB in include/asm-generic/
> > > mman-common.h to a number which is already being used for other MAP_s
> > > on some architectures.  That's a separate bug which needs to be fixed
> > > by distributing the MAP_HUGETLB definition across various asm*/mman.h.
> > 
> > Would it be okay to keep the define in include/asm-generic/mman.h
> > if a value that is known free across all architectures is used?
> > 0x080000 is not used by any arch and, AFAICT would work just as well.
> 
> That's a very sensible suggestion, but departs from how we have
> assigned new numbers up until now: so include/asm-generic/mman-common.h
> isn't actually where we'd expect to find a Linux-specific MAP_ define.
> 
> I'd say, yes, do that for now, so as not to hit this conflict while
> testing in mmotm.  But whether it should stay that way, or later the
> arch/*/include/asm/mman.h's be updated as I'd imagined, I don't know.
> 
> Arnd, Michael, do you have any views on this?

The minimal procedure would be to add it to mman-common.h, plus
the asm/mman.h files for xtensa, mips, parisc and alpha, which all
use a version that is compatible to a Unix variant, but that would
be confusing the next person that needs to add a flag.

I'd use the number 0x40000 for all architectures except alpha,
because that makes the most sense for asm-generic/mman.h. Alpha
is weird anyway here, so we don't need to avoid conflicts with it.

With a few exceptions (sparc, powerpc), I think we should change
all architectures to use asm-generic/mman.h instead of mman-common.h
in the long run. If you touch those anyway, one option would be
to do it in one step.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
