Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id D42B86B0032
	for <linux-mm@kvack.org>; Sat, 10 Jan 2015 13:39:14 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id z12so13164681wgg.13
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 10:39:14 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id v4si26341167wjx.164.2015.01.10.10.39.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 10 Jan 2015 10:39:13 -0800 (PST)
Date: Sat, 10 Jan 2015 19:39:11 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] x86, mpx: Ensure unused arguments of prctl() MPX
 requests are 0
Message-ID: <20150110183911.GB2915@two.firstfloor.org>
References: <54AE5BE8.1050701@gmail.com>
 <87r3v350io.fsf@tassilo.jf.intel.com>
 <CAKgNAki3Fh8N=jyPHxxFpicjyJ=0kA75SJ65QjYzPmWnvy4nsw@mail.gmail.com>
 <54B01F41.10001@intel.com>
 <54B12DD3.5020605@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54B12DD3.5020605@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Qiaowei Ren <qiaowei.ren@intel.com>, lkml <linux-kernel@vger.kernel.org>

On Sat, Jan 10, 2015 at 02:49:07PM +0100, Michael Kerrisk (man-pages) wrote:
> On 01/09/2015 07:34 PM, Dave Hansen wrote:
> > On 01/09/2015 10:25 AM, Michael Kerrisk (man-pages) wrote:
> >> On 9 January 2015 at 18:25, Andi Kleen <andi@firstfloor.org> wrote:
> >>> "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> writes:
> >>>> From: Michael Kerrisk <mtk.manpages@gmail.com>
> >>>>
> >>>> commit fe8c7f5cbf91124987106faa3bdf0c8b955c4cf7 added two new prctl()
> >>>> operations, PR_MPX_ENABLE_MANAGEMENT and PR_MPX_DISABLE_MANAGEMENT.
> >>>> However, no checks were included to ensure that unused arguments
> >>>> are zero, as is done in many existing prctl()s and as should be
> >>>> done for all new prctl()s. This patch adds the required checks.
> >>>
> >>> This will break the existing gcc run time, which doesn't zero these
> >>> arguments.
> >>
> >> I'm a little lost here. Weren't these flags new in the
> >> as-yet-unreleased 3.19? How does gcc run-time depends on them already?
> > 
> > These prctl()s have been around in some form or another for a few months
> > since the patches had not yet been merged in to the kernel.  There is
> > support for them in a set of (yet unmerged) gcc patches, as well as some
> > tests which are only internal to Intel.
> > 
> > This change will, indeed, break those internal tests as well as the gcc
> > patches.  As far as I know, the code is not in production anywhere and
> > can be changed.  The prctl() numbers have changed while the patches were
> > out of tree and it's a somewhat painful process each time it changes.
> > It's not impossible, just painful.
> 
> So, sounds like thinks can be fixed (with mild inconvenience), and they
> should be fixed before 3.19 is actually released.

FWIW I added these checks to prctl first, but in hindsight it was a
mistake.

The glibc prctl() function is stdarg. Often you only have a single
extra argument, so you need to add 4 zeroes. There is no compile
time checking. It is very easy to get wrong and miscount the zeroes, 
happened several times.  The failure may be hard to catch, because
it only happens at runtime.

Also the extra zeroes look ugly in the source.

And it doesn't really buy you anything because it's very cheap
to add new prctl numbers if you want to extend something.

So I would advise against it.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
