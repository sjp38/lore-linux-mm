Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE1B6B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 23:04:59 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id b3-v6so1035745plr.23
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 20:04:59 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s186si1852725pgc.691.2018.02.07.20.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 20:04:57 -0800 (PST)
Date: Wed, 7 Feb 2018 20:04:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Message-ID: <20180208040455.GC14918@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 08, 2018 at 03:56:26AM +0100, Jann Horn wrote:
> How much memory would you need to trigger this? You need one
> vm_area_struct per increment, and those are 200 bytes? So at least
> 800GiB of memory for the vm_area_structs, and maybe more for other
> data structures?

That's a good point that I hadn't considered.  Systems with that quantity
of memory are becoming available though.

> On systems with RAM on the order of terabytes, it's probably a good
> idea to turn on refcount hardening to make issues like that
> non-exploitable for now.

_mapcount is a bad candidate to be turned into a refcount_t.  It's
completely legitimate to go to 0 and then back to 1.  Also, we care
about being able to efficiently notice when it goes from 2 to 1 and
then from 1 to 0 (and we currently do that by biasing the count by -1).
I suppose it wouldn't be too hard to notice when we go from 0x7fff'ffff
to 0x8000'0000 and saturate the counter there.

> > That seems pretty bad.  So here's a patch which adds documentation to the
> > two sysctls that a sysadmin could use to shoot themselves in the foot,
> > and adds a warning if they change either of them to a dangerous value.
> 
> I have negative feelings about this patch, mostly because AFAICS:
> 
>  - It documents an issue instead of fixing it.

I prefer to think of it as warning the sysadmin they're doing something
dangerous, rather than preventing them from doing it ...

>  - It likely only addresses a small part of the actual problem.

By this, you mean that there's a more general class of problem, and I make
no attempt to address it?

> > +       if ((INT_MAX / max_map_count) > pid_max)
> > +               pr_warn("pid_max is dangerously large\n");
> 
> This in reordered is "if (pid_max * max_map_count < INT_MAX)
> pr_warn(...);", no? That doesn't make sense to me. Same thing again
> further down.

I should get more sleep before writing patches.

> > -               if (unlikely(mm->map_count >= sysctl_max_map_count)) {
> > +               if (unlikely(mm->map_count >= max_map_count)) {
> 
> Why the renaming?

Because you can't have a function and an integer with the same name,
and the usual pattern we follow is that sysctl_foo_bar() is the function
to handle the variable foo_bar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
