Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8246B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 12:52:21 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t12so116213323pgo.7
        for <linux-mm@kvack.org>; Wed, 24 May 2017 09:52:21 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 31si24594329plk.66.2017.05.24.09.52.20
        for <linux-mm@kvack.org>;
        Wed, 24 May 2017 09:52:20 -0700 (PDT)
Date: Wed, 24 May 2017 17:52:14 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm: kmemleak: Treat vm_struct as alternative reference
 to vmalloc'ed objects
Message-ID: <20170524165214.GF19448@e104818-lin.cambridge.arm.com>
References: <1495474514-24425-1-git-send-email-catalin.marinas@arm.com>
 <CALCETrVaFPjQrVAiOad6GhFvK=AQphF0Kx5zDsCcAt4bPfQbnw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVaFPjQrVAiOad6GhFvK=AQphF0Kx5zDsCcAt4bPfQbnw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>

On Mon, May 22, 2017 at 11:19:08AM -0700, Andy Lutomirski wrote:
> On Mon, May 22, 2017 at 10:35 AM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > Kmemleak requires that vmalloc'ed objects have a minimum reference count
> > of 2: one in the corresponding vm_struct object and the other owned by
> > the vmalloc() caller. There are cases, however, where the original
> > vmalloc() returned pointer is lost and, instead, a pointer to vm_struct
> > is stored (see free_thread_stack()). Kmemleak currently reports such
> > objects as leaks.
> >
> > This patch adds support for treating any surplus references to an object
> > as additional references to a specified object. It introduces the
> > kmemleak_vmalloc() API function which takes a vm_struct pointer and sets
> > its surplus reference passing to the actual vmalloc() returned pointer.
> > The __vmalloc_node_range() calling site has been modified accordingly.
> >
> > An unrelated minor change is included in this patch to change the type
> > of kmemleak_object.flags to unsigned int (previously unsigned long).
> >
> > Reported-by: "Luis R. Rodriguez" <mcgrof@kernel.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Andy Lutomirski <luto@amacapital.net>
> > Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> > ---
> >
> > As per [1], I added support to use pointers to vm_struct as an
> > alternative way to avoid false positives when the original vmalloc()
> > pointer has been lost. This is slightly harder to reason about but it
> > seems to work for this use-case. I'm not aware of other cases (than
> > free_thread_stack()) where the original vmalloc() pointer is removed in
> > favour of a vm_struct one.
> >
> > An alternative implementation (simpler to understand), if preferred, is
> > to annotate alloc_thread_stack_node() and free_thread_stack() with
> > kmemleak_unignore()/kmemleak_ignore() calls and proper comments.
> >
> 
> I personally prefer the option in this patch.  It keeps the special
> case in kmemleak and the allocation code rather than putting it in the
> consumer code.
> 
> Also, I want to add an API at some point that vmallocs some memory and
> returns the vm_struct directly.  That won't work with explicit
> annotations in the caller because kmemleak might think it's leaked
> before the caller can execute the annotations.

While kmemleak delays the reporting of newly allocated objects to avoid
such race, we need to keep annotations to a minimum anyway (only for
special cases, definitely not for each caller of an allocation API). The
proposed kmemleak_vmalloc() API in this patch would cover your case
without any additional annotation.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
