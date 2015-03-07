Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 633336B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 14:12:51 -0500 (EST)
Received: by iery20 with SMTP id y20so486746ier.0
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 11:12:51 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id c23si6738825iod.46.2015.03.07.11.12.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Mar 2015 11:12:50 -0800 (PST)
Received: by igbhl2 with SMTP id hl2so11015165igb.0
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 11:12:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150307163657.GA9702@gmail.com>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
	<1425741651-29152-5-git-send-email-mgorman@suse.de>
	<20150307163657.GA9702@gmail.com>
Date: Sat, 7 Mar 2015 11:12:50 -0800
Message-ID: <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, Mar 7, 2015 at 8:36 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> And the patch Dave bisected to is a relatively simple patch.
> Why not simply revert it to see whether that cures much of the
> problem?

So the problem with that is that "pmd_set_numa()" and friends simply
no longer exist. So we can't just revert that one patch, it's the
whole series, and the whole point of the series.

What confuses me is that the only real change that I can see in that
patch is the change to "change_huge_pmd()". Everything else is pretty
much a 100% equivalent transformation, afaik. Of course, I may be
wrong about that, and missing something silly.

And the changes to "change_huge_pmd()" were basically re-done
differently by subsequent patches anyway.

The *only* change I see remaining is that change_huge_pmd() now does

   entry = pmdp_get_and_clear_notify(mm, addr, pmd);
   entry = pmd_modify(entry, newprot);
   set_pmd_at(mm, addr, pmd, entry);

for all changes. It used to do that "pmdp_set_numa()" for the
prot_numa case, which did just

   pmd_t pmd = *pmdp;
   pmd = pmd_mknuma(pmd);
   set_pmd_at(mm, addr, pmdp, pmd);

instead.

I don't like the old pmdp_set_numa() because it can drop dirty bits,
so I think the old code was actively buggy.

But I do *not* see why the new code would cause more migrations to happen.

There's probably something really stupid I'm missing.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
