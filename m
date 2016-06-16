Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4A96B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 15:39:28 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id c127so155414850vkb.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 12:39:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c101si5638074qkh.26.2016.06.16.12.39.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 12:39:27 -0700 (PDT)
Date: Thu, 16 Jun 2016 14:39:23 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 04/13] mm: Track NR_KERNEL_STACK in pages instead of
 number of stacks
Message-ID: <20160616193923.hyma4vcmr7lvklcx@treble>
References: <cover.1466036668.git.luto@kernel.org>
 <24279d4009c821de64109055665429fad2a7bff7.1466036668.git.luto@kernel.org>
 <20160616153339.xvlsnhksqmkeusn4@treble>
 <CALCETrXRONH1K1zAWAFN--Lsza+5bkgtmcMrgAY_nvT-e21C3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALCETrXRONH1K1zAWAFN--Lsza+5bkgtmcMrgAY_nvT-e21C3w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Brian Gerst <brgerst@gmail.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jun 16, 2016 at 10:39:43AM -0700, Andy Lutomirski wrote:
> On Thu, Jun 16, 2016 at 8:33 AM, Josh Poimboeuf <jpoimboe@redhat.com> wrote:
> > On Wed, Jun 15, 2016 at 05:28:26PM -0700, Andy Lutomirski wrote:
> >> Currently, NR_KERNEL_STACK tracks the number of kernel stacks in a
> >> zone.  This only makes sense if each kernel stack exists entirely in
> >> one zone, and allowing vmapped stacks could break this assumption.
> >>
> >> It turns out that the code for tracking kernel stack allocations in
> >> units of pages is slightly simpler, so just switch to counting
> >> pages.
> >>
> >> Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
> >> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >> Cc: Michal Hocko <mhocko@kernel.org>
> >> Cc: linux-mm@kvack.org
> >> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> >> ---
> >>  fs/proc/meminfo.c | 2 +-
> >>  kernel/fork.c     | 3 ++-
> >>  mm/page_alloc.c   | 3 +--
> >>  3 files changed, 4 insertions(+), 4 deletions(-)
> >
> > You missed another usage of NR_KERNEL_STACK in drivers/base/node.c.
> 
> Thanks.
> 
> The real reason I cc'd you was so you could look at
> rewind_stack_do_exit and the sneaky trick I did in no_context in the
> last patch, though.  :)  Both survive objtool, but I figured I'd check
> with objtool's author as well.  If there was a taint bit I could set
> saying "kernel is hosed -- don't try to apply live patches any more",
> I'd have extra confidence.

I think it all looks fine from an objtool and a live patching
standpoint.  Other than my previous comment about setting the stack
pointer correctly before calling do_exit(), I didn't see anything else
which would mess up the stack of a sleeping task, which is all I really
care about.

-- 
Josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
