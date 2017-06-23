Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 345A66B02FD
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 10:18:52 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z1so13162082wrz.10
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 07:18:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si4245722wmo.123.2017.06.23.07.18.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 07:18:50 -0700 (PDT)
Date: Fri, 23 Jun 2017 16:18:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] exec: Account for argv/envp pointers
Message-ID: <20170623141837.GD5308@dhcp22.suse.cz>
References: <20170622001720.GA32173@beast>
 <20170623135924.GC5314@dhcp22.suse.cz>
 <CAGXu5jJB-DKWLVPKL5-BiCF5Rmn3M_Q5yTPxtn8HW-2VekBaXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJB-DKWLVPKL5-BiCF5Rmn3M_Q5yTPxtn8HW-2VekBaXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Qualys Security Advisory <qsa@qualys.com>, Linux-MM <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Fri 23-06-17 07:05:37, Kees Cook wrote:
> On Fri, Jun 23, 2017 at 6:59 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> >> --- a/fs/exec.c
> >> +++ b/fs/exec.c
> >> @@ -220,8 +220,18 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
> >>
> >>       if (write) {
> >>               unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
> >> +             unsigned long ptr_size;
> >>               struct rlimit *rlim;
> >>
> >> +             /*
> >> +              * Since the stack will hold pointers to the strings, we
> >> +              * must account for them as well.
> >> +              */
> >> +             ptr_size = (bprm->argc + bprm->envc) * sizeof(void *);
> >> +             if (ptr_size > ULONG_MAX - size)
> >> +                     goto fail;
> >> +             size += ptr_size;
> >> +
> >>               acct_arg_size(bprm, size / PAGE_SIZE);
> >
> > Doesn't this over account? I mean this gets called for partial arguments
> > as they fit into a page so a single argument can get into this function
> > multiple times AFAIU. I also do not understand why would you want to
> > account bprm->argc + bprm->envc pointers for each argument.
> 
> Based on what I could understand in acct_arg_size(), this is called
> repeatedly with with the "current" size (it handles the difference
> between prior calls, see calls like acct_arg_size(bprm, 0)).
> 
> The size calculation is the entire vma while each arg page is built,
> so each time we get here it's calculating how far it is currently
> (rather than each call being just the newly added size from the arg
> page). As a result, we need to always add the entire size of the
> pointers, so that on the last call to get_arg_page() we'll actually
> have the entire correct size.

Ohh, I forgot about this tricky part. The code just looks confusing
becauser we are mixing 2 things together here. This deserves a comment I
guess.

Other than that feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
