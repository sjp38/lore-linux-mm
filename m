Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 64A7D6B005A
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 12:11:53 -0400 (EDT)
Date: Mon, 22 Oct 2012 18:11:51 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB v6
Message-ID: <20121022161151.GS16230@one.firstfloor.org>
References: <1350665289-7288-1-git-send-email-andi@firstfloor.org> <CAHO5Pa0W-WGBaPvzdRJxYPdrg-K9guChswo3KJheK4BaRzsRwQ@mail.gmail.com> <20121022132733.GQ16230@one.firstfloor.org> <20121022133534.GR16230@one.firstfloor.org> <CAKgNAkgQ6JZdwOsCAQ4Ak_gVXtav=TzgzW2tbk5jMUwxtMqOAg@mail.gmail.com> <20121022153633.GK2095@tassilo.jf.intel.com> <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgNAki=AL+KdYDdYnE8ZhjK-tUf5cZ163BWPe6GRM0rpi-z7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Andi Kleen <ak@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hillf Danton <dhillf@gmail.com>

On Mon, Oct 22, 2012 at 05:53:45PM +0200, Michael Kerrisk (man-pages) wrote:
> I'm not sure whether anything is using the high 8 bits of prot, bun
> passing I note that there seems to be no check that the unused bits
> are zeroed so there's a small chance  existing apps are passing random
> garbage there. (Of course, mmap() is hardly the only API to have that
> fault, and it hasn't stopped us from reusing bits in those APIs,
> though sometimes we've gotten bitten by apps that did pass in random
> garbage).

Ok.

> 
> >> But there seems an obvious solution here: given your value in those
> >> bits (call it 'n'), the why not apply a multiplier. I mean, certainly
> >> you never want a value <= 12 for n, and I suspect that the reasonable
> >> minimum could be much larger (e.g., 2^16). Call that minimum M. Then
> >> you could interpret the value in your bits as meaning a page size of
> >>
> >>     (2^n) * M
> >
> > I considered that, but it would seem ugly and does not add that
> > many bits.
> >
> >>
> >> > So this will use up all remaining flag bits now.
> >>
> >> On the other hand, that seems really bad. It looks like that kills the
> >> ability to further extend the mmap() API with new flags in the future.
> >> It doesn't sound like we should be doing that.
> >
> > You can always add flags to PROT or add a mmap3(). Has been done before.
> > Or just don't do any new MAP_SECURITY_HOLEs
> 
> There seems to be a reasonable argument here for an mmap3() with a
> 64-bit flags argument...

It's just a pain to deploy.

I think I would rather do the offset then. That could still handle
PowerPC

14 + 31 = 44 = 16GB           (minimum size 16K)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
