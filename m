Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7826B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 03:23:12 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 5so155545023ioy.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 00:23:12 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id x3si11529925iof.163.2016.06.17.00.23.10
        for <linux-mm@kvack.org>;
        Fri, 17 Jun 2016 00:23:11 -0700 (PDT)
Date: Fri, 17 Jun 2016 16:25:26 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 6/7] mm/page_owner: use stackdepot to store stacktrace
Message-ID: <20160617072525.GA810@js1304-P5Q-DELUXE>
References: <1464230275-25791-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1464230275-25791-6-git-send-email-iamjoonsoo.kim@lge.com>
 <20160606135604.GJ11895@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160606135604.GJ11895@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, mgorman@techsingularity.net, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 06, 2016 at 03:56:04PM +0200, Michal Hocko wrote:
> On Thu 26-05-16 11:37:54, Joonsoo Kim wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Currently, we store each page's allocation stacktrace on corresponding
> > page_ext structure and it requires a lot of memory. This causes the problem
> > that memory tight system doesn't work well if page_owner is enabled.
> > Moreover, even with this large memory consumption, we cannot get full
> > stacktrace because we allocate memory at boot time and just maintain
> > 8 stacktrace slots to balance memory consumption. We could increase it
> > to more but it would make system unusable or change system behaviour.
> > 
> > To solve the problem, this patch uses stackdepot to store stacktrace.
> > It obviously provides memory saving but there is a drawback that
> > stackdepot could fail.
> > 
> > stackdepot allocates memory at runtime so it could fail if system has
> > not enough memory. But, most of allocation stack are generated at very
> > early time and there are much memory at this time. So, failure would not
> > happen easily. And, one failure means that we miss just one page's
> > allocation stacktrace so it would not be a big problem. In this patch,
> > when memory allocation failure happens, we store special stracktrace
> > handle to the page that is failed to save stacktrace. With it, user
> > can guess memory usage properly even if failure happens.
> > 
> > Memory saving looks as following. (4GB memory system with page_owner)
> 
> I still have troubles to understand your numbers
> 
> > static allocation:
> > 92274688 bytes -> 25165824 bytes
> 
> I assume that the first numbers refers to the static allocation for the
> given amount of memory while the second one is the dynamic after the
> boot, right?

No, first number refers to the static allocation before the patch and
second one is for after the patch.

> 
> > dynamic allocation after kernel build:
> > 0 bytes -> 327680 bytes
> 
> And this is the additional dynamic allocation after the kernel build.

This is the additional dynamic allocation after booting + the kernel
build. (before the patch -> after the patch)

> > total:
> > 92274688 bytes -> 25493504 bytes
> > 
> > 72% reduction in total.
> > 
> > Note that implementation looks complex than someone would imagine because
> > there is recursion issue. stackdepot uses page allocator and page_owner
> > is called at page allocation. Using stackdepot in page_owner could re-call
> > page allcator and then page_owner. That is a recursion. To detect and
> > avoid it, whenever we obtain stacktrace, recursion is checked and
> > page_owner is set to dummy information if found. Dummy information means
> > that this page is allocated for page_owner feature itself
> > (such as stackdepot) and it's understandable behavior for user.
> > 
> > v2:
> > o calculate memory saving with including dynamic allocation
> > after kernel build
> > o change maximum stacktrace entry size due to possible stack overflow
> > 
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Other than the small remark below I haven't spotted anything wrong and
> I like the approach.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

> > ---
> >  include/linux/page_ext.h |   4 +-
> >  lib/Kconfig.debug        |   1 +
> >  mm/page_owner.c          | 138 ++++++++++++++++++++++++++++++++++++++++-------
> >  3 files changed, 122 insertions(+), 21 deletions(-)
> > 
> [...]
> > @@ -7,11 +7,18 @@
> >  #include <linux/page_owner.h>
> >  #include <linux/jump_label.h>
> >  #include <linux/migrate.h>
> > +#include <linux/stackdepot.h>
> > +
> >  #include "internal.h"
> >  
> 
> This is still 128B of the stack which is a lot in the allocation paths
> so can we add something like
> 
> /*
>  * TODO: teach PAGE_OWNER_STACK_DEPTH (__dump_page_owner and save_stack)
>  * to use off stack temporal storage
>  */
> > +#define PAGE_OWNER_STACK_DEPTH (16)

Will add.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
