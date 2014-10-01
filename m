Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E6E186B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 06:39:52 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id fp1so46504pdb.11
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 03:39:52 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id ew4si334996pdb.247.2014.10.01.03.39.51
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 03:39:51 -0700 (PDT)
Date: Wed, 1 Oct 2014 11:39:30 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH v3 11/13] kmemleak: disable kasan instrumentation for
 kmemleak
Message-ID: <20141001103930.GG20364@e104818-lin.cambridge.arm.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-1-git-send-email-a.ryabinin@samsung.com>
 <1411562649-28231-12-git-send-email-a.ryabinin@samsung.com>
 <CACT4Y+aJ9htaruQ1Nn7+MSGwtNzRb_hfytQo98J1wq5N6oh1BA@mail.gmail.com>
 <CAPAsAGxLxCxOayqcu=PbgFG6J7JEuL8J3+ouz94p_k0v0Hy=wA@mail.gmail.com>
 <CACT4Y+Z4N5hpz_ZXFOCCbv7sbz2kzrF6gYHMbasDFNwpdOK30Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z4N5hpz_ZXFOCCbv7sbz2kzrF6gYHMbasDFNwpdOK30Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Sep 29, 2014 at 03:10:01PM +0100, Dmitry Vyukov wrote:
> On Fri, Sep 26, 2014 at 9:36 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> > 2014-09-26 21:10 GMT+04:00 Dmitry Vyukov <dvyukov@google.com>:
> >> Looks good to me.
> >>
> >> We can disable kasan instrumentation of this file as well.
> >
> > Yes, but why? I don't think we need that.
> 
> Just gut feeling. Such tools usually don't play well together. For
> example, due to asan quarantine lots of leaks will be missed (if we
> pretend that tools work together, end users will use them together and
> miss bugs). I won't be surprised if leak detector touches freed
> objects under some circumstances as well.
> We can do this if/when discover actual compatibility issues, of course.

I think it's worth testing them together first.

One issue, as mentioned in the patch log, is that the size information
that kmemleak gets is the one from the kmem_cache object rather than the
original allocation size, so this would be rounded up.

Kmemleak should not touch freed objects (if an object is freed during a
scan, it is protected by some lock until the scan completes). There is a
bug however which I haven't got to fixing it yet, if kmemleak fails for
some reason (cannot allocate memory) and disables itself, it may access
some freed object (though usually hard to trigger).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
