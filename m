Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4ED796B0038
	for <linux-mm@kvack.org>; Wed, 20 Aug 2014 11:11:51 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so7102132wiw.12
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:11:50 -0700 (PDT)
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
        by mx.google.com with ESMTPS id uk5si36916489wjc.61.2014.08.20.08.11.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 Aug 2014 08:11:50 -0700 (PDT)
Received: by mail-we0-f174.google.com with SMTP id x48so8078073wes.19
        for <linux-mm@kvack.org>; Wed, 20 Aug 2014 08:11:49 -0700 (PDT)
Date: Wed, 20 Aug 2014 16:11:43 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [PATCH 0/6] RCU get_user_pages_fast and __get_user_pages_fast
Message-ID: <20140820151142.GA26217@linaro.org>
References: <1403710824-24340-1-git-send-email-steve.capper@linaro.org>
 <CALdTtns6+MRb=Z7i0ncq_c2u7QZWo1mUxD824bvNF==q-_+BiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALdTtns6+MRb=Z7i0ncq_c2u7QZWo1mUxD824bvNF==q-_+BiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dann Frazier <dann.frazier@canonical.com>
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, anders.roxell@linaro.org, peterz@infradead.org, gary.robertson@linaro.org, Will Deacon <will.deacon@arm.com>, akpm@linux-foundation.org, Christoffer Dall <christoffer.dall@linaro.org>

On Wed, Aug 20, 2014 at 08:56:09AM -0600, Dann Frazier wrote:
> On Wed, Jun 25, 2014 at 9:40 AM, Steve Capper <steve.capper@linaro.org> wrote:
> > Hello,
> > This series implements general forms of get_user_pages_fast and
> > __get_user_pages_fast and activates them for arm and arm64.
> >
> > These are required for Transparent HugePages to function correctly, as
> > a futex on a THP tail will otherwise result in an infinite loop (due to
> > the core implementation of __get_user_pages_fast always returning 0).
> >
> > This series may also be beneficial for direct-IO heavy workloads and
> > certain KVM workloads.
> >
> > The main changes since RFC V5 are:
> >  * Rebased against 3.16-rc1.
> >  * pmd_present no longer tested for by gup_huge_pmd and gup_huge_pud,
> >    because the entry must be present for these leaf functions to be
> >    called.
> >  * Rather than assume puds can be re-cast as pmds, a separate
> >    function pud_write is instead used by the core gup.
> >  * ARM activation logic changed, now it will only activate
> >    RCU_TABLE_FREE and RCU_GUP when running with LPAE.
> >
> > The main changes since RFC V4 are:
> >  * corrected the arm64 logic so it now correctly rcu-frees page
> >    table backing pages.
> >  * rcu free logic relaxed for pre-ARMv7 ARM as we need an IPI to
> >    invalidate TLBs anyway.
> >  * rebased to 3.15-rc3 (some minor changes were needed to allow it to merge).
> >  * dropped Catalin's mmu_gather patch as that's been merged already.
> >
> > This series has been tested with LTP and some custom futex tests that
> > exacerbate the futex on THP tail case. Also debug counters were
> > temporarily employed to ensure that the RCU_TABLE_FREE logic was
> > behaving as expected.
> >
> > I would really appreciate any testers or comments (especially on the
> > validity or otherwise of the core fast_gup implementation).
> 
> I have a test case that can reliably hit the THP issue on arm64, which
> hits it on both 3.16 and 3.17-rc1. I do a "juju bootstrap local" w/
> THP disabled at boot. Then I reboot with THP enabled. At this point
> you'll see jujud spin at 200% CPU. gccgo binaries seem to have a nack
> for hitting it.
> 
> I validated that your patches resolve this issue on 3.16, so:
> 
> Tested-by: dann frazier <dann.frazier@canonical.com>

Thanks Dann!

> 
> I haven't done the same for 3.17-rc1 because they no longer apply
> cleanly, but I'm happy to test future submissions w/ hopefully a
> shorter feedback loop (please add me to the CC). btw, should we
> consider something like this until your patches go in?

I am about to post the following series, I will CC you:
git://git.linaro.org/people/steve.capper/linux.git fast_gup/3.17-rc1
(I've just been giving it a workout on 3.17-rc1).

I would much prefer for the RCU fast_gup to go into 3.18 rather than
BROKEN for THP. I am not sure what to do about earlier versions.

Cheers,
-- 
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
