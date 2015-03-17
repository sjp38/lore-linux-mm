Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C8E106B0032
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 15:24:28 -0400 (EDT)
Received: by wibg7 with SMTP id g7so71667371wib.1
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 12:24:28 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ey12si4777005wid.77.2015.03.17.12.24.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Mar 2015 12:24:27 -0700 (PDT)
Date: Tue, 17 Mar 2015 15:24:13 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID: 1 at
 drivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
Message-ID: <20150317192413.GA7772@phnom.home.cmpxchg.org>
References: <1426227621.6711.238.camel@intel.com>
 <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, LKP ML <lkp@01.org>, linux-mm <linux-mm@kvack.org>

On Tue, Mar 17, 2015 at 10:15:29AM -0700, Linus Torvalds wrote:
> Explicitly adding the emails of other people involved with that commit
> and the original oom thread to make sure people are aware, since this
> didn't get any response.
> 
> Commit cc87317726f8 fixed some behavior, but also seems to have turned
> an oom situation into a complete hang. So presumably we shouldn't loop
> *forever*. Hmm?

It seems we are between a rock and a hard place here, as we reverted
specifically to that endless looping on request of filesystem people.
They said[1] they rely on these allocations never returning NULL, or
they might fail inside a transactions and corrupt on-disk data.

Huang, against which kernels did you first run this test on this exact
setup?  Is there a chance you could try to run a kernel without/before
9879de7373fc?  I want to make sure I'm not missing something, but all
versions preceding this commit should also have the same hang.  There
should only be a tiny window between 9879de7373fc and cc87317726f8 --
v3.19 -- where these allocations are allowed to fail.

[1] https://www.marc.info/?l=linux-mm&m=142450545009301&w=3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
