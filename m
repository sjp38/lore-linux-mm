Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 56CF46B0078
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:46:55 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id mc6so2278445lab.6
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:46:54 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id tg7si29037444lbb.63.2014.07.24.12.46.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Jul 2014 12:46:53 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so2697289lbi.13
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:46:53 -0700 (PDT)
Date: Thu, 24 Jul 2014 23:46:51 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [rfc 1/4] mm: Introduce may_adjust_brk helper
Message-ID: <20140724194651.GE17876@moon>
References: <20140724164657.452106845@openvz.org>
 <20140724165047.437075575@openvz.org>
 <20140724193225.GT26600@ubuntumail>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140724193225.GT26600@ubuntumail>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, keescook@chromium.org, tj@kernel.org, akpm@linux-foundation.org, avagin@openvz.org, ebiederm@xmission.com, hpa@zytor.com, serge.hallyn@canonical.com, xemul@parallels.com, segoon@openwall.com, kamezawa.hiroyu@jp.fujitsu.com, mtk.manpages@gmail.com, jln@google.com

On Thu, Jul 24, 2014 at 07:32:25PM +0000, Serge Hallyn wrote:
> Quoting Cyrill Gorcunov (gorcunov@openvz.org):
> > To eliminate code duplication lets introduce may_adjust_brk
> > helper which we will use in brk() and prctl() syscalls.
> > 
> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> > Cc: Kees Cook <keescook@chromium.org>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Andrew Vagin <avagin@openvz.org>
> > Cc: Eric W. Biederman <ebiederm@xmission.com>
> > Cc: H. Peter Anvin <hpa@zytor.com>
> > Cc: Serge Hallyn <serge.hallyn@canonical.com>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Cc: Vasiliy Kulikov <segoon@openwall.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > Cc: Michael Kerrisk <mtk.manpages@gmail.com>
> > Cc: Julien Tinnes <jln@google.com>
> > ---
> >  include/linux/mm.h |   14 ++++++++++++++
> >  1 file changed, 14 insertions(+)
> > 
> > Index: linux-2.6.git/include/linux/mm.h
> > ===================================================================
> > --- linux-2.6.git.orig/include/linux/mm.h
> > +++ linux-2.6.git/include/linux/mm.h
> > @@ -18,6 +18,7 @@
> >  #include <linux/pfn.h>
> >  #include <linux/bit_spinlock.h>
> >  #include <linux/shrinker.h>
> > +#include <linux/resource.h>
> >  
> >  struct mempolicy;
> >  struct anon_vma;
> > @@ -1780,6 +1781,19 @@ extern struct vm_area_struct *copy_vma(s
> >  	bool *need_rmap_locks);
> >  extern void exit_mmap(struct mm_struct *);
> >  
> > +static inline int may_adjust_brk(unsigned long rlim,
> > +				 unsigned long new_brk,
> > +				 unsigned long start_brk,
> > +				 unsigned long end_data,
> > +				 unsigned long start_data)
> > +{
> > +	if (rlim < RLIMIT_DATA) {
> 
> In the code you're replacing, this was RLIM_INFINITY.  Did you really
> mean for this to be RLIMIT_DATA, aka 2?

Good catch, thanks Serge! Better would be to pass the type of resource
(as Kees suggested) here instead of @rlim itself and sure to compare
with RLIM_INFINITY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
