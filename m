Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DD22E6B0044
	for <linux-mm@kvack.org>; Mon, 24 Dec 2012 20:28:56 -0500 (EST)
Date: Tue, 25 Dec 2012 02:28:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: PageHead macro broken?
Message-ID: <20121225012837.GD10261@redhat.com>
References: <CAEDV+gLg838ua2Bgu0sTRjSAWYGPwELtH=ncoKPP-5t7_gxUYw@mail.gmail.com>
 <CA+55aFxb63WMysJ-HQbam_JH05Bqp=XhrzokrSM-yvoaAzPASg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxb63WMysJ-HQbam_JH05Bqp=XhrzokrSM-yvoaAzPASg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoffer Dall <cdall@cs.columbia.edu>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <Will.Deacon@arm.com>, Steve Capper <Steve.Capper@arm.com>, "kvmarm@lists.cs.columbia.edu" <kvmarm@lists.cs.columbia.edu>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>

Hi everyone,

On Mon, Dec 24, 2012 at 11:21:02AM -0800, Linus Torvalds wrote:
> On Mon, Dec 24, 2012 at 10:53 AM, Christoffer Dall
> <cdall@cs.columbia.edu> wrote:
> >
> > I think I may have found an issue with the PageHead macro, which
> > returns true for tail compound pages when CONFIG_PAGEFLAGS_EXTENDED is
> > not defined.
> 
> Hmm. Your patch *looks* obviously correct, in that it actually makes
> the code match the comment just above it. And making PageHead() test
> just the "compound" flag (and thus a tail-page would trigger it too)
> sounds wrong. But I join you in the "let's check the expected
> semantics with the people who use it" chorus.

Yes, it's wrong if PageHead returns true on a tail page. PageHead and
PageTail are mutually exclusive flags. Only PageCompound returns true
for both PageHead and PageTail.

> The fact that it fixes a problem on KVM/ARM is obviously another good sign.
> 
> At the same time, I wonder why it hasn't shown up as a problem on
> x86-32. On x86-64 PAGEFLAGS_EXTENDED is always true, but afaik, it
> should be possible to trigger this on 32-bit architectures if you just
> have SPARSEMEM && !SPARSEMEM_VMEMMAP.

Most of the PageHead checks are consistently run on real head pages,
so they're unlikely to run on tail pages. When !PageHead is used in
the bugchecks, the bug would lead to a false negative in the worst
case. This may be why this didn't show up on x86 32bit?

But AFIK no binary x86 kernel was shipped with THP compiled in, so
it's also hard to quantify the different configs for the x86 32bit
self-built kernel images out there.

> And SPARSEMEM on x86-32 is enabled with NUMA or EXPERIMENTAL set. And
> afaik, x86-32 never has SPARSEMEM_VMEMMAP. So this should not be a
> very uncommon setup.
> 
> Added Andrea and Kirill to the Cc, since most of the *uses* of
> PageHead() in the generic VM code are attributed to either of them
> according to "git blame". Left the rest of the email quoted for the
> new participants.. Also, you seem to have used Christoph's old SGI
> email address that I don't think is in use any more.
> 
> Andrea? Kirill? Christoph?

The fix looks good to me, thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
