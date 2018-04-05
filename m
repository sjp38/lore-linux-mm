Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFFA6B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:17:34 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id p21so17051908qke.20
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:17:34 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s3si7511290qte.4.2018.04.05.07.17.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 07:17:33 -0700 (PDT)
Date: Thu, 5 Apr 2018 17:17:30 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Message-ID: <20180405171009-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
 <20180405045231-mutt-send-email-mst@kernel.org>
 <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

On Wed, Apr 04, 2018 at 07:40:36PM -0700, Linus Torvalds wrote:
> On Wed, Apr 4, 2018 at 6:53 PM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > Any feedback on this? As this fixes a bug in vhost, I'll merge
> > through the vhost tree unless someone objects.
> 
> NAK.
> 
> __get_user_pages_fast() returns the number of pages it gets.
> 
> It has never returned an error code, and all the other versions of it
> (architecture-specific) don't either.

Thanks Linus. I can change the docs and all the callers.


I wonder however whether all the following should be changed then:

static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,

...

                        if (!vma || check_vma_flags(vma, gup_flags))
                                return i ? : -EFAULT;

is this a bug in __get_user_pages?


Another example:

                                ret = get_gate_page(mm, start & PAGE_MASK,
                                                gup_flags, &vma,
                                                pages ? &pages[i] : NULL);
                                if (ret)
                                        return i ? : ret;

and ret is -EFAULT on error.


Another example:
                        switch (ret) {
                        case 0:
                                goto retry;
                        case -EFAULT:
                        case -ENOMEM:
                        case -EHWPOISON:
                                return i ? i : ret;
                        case -EBUSY:
                                return i;
                        case -ENOENT:
                                goto next_page;
                        }

it looks like this will return -EFAULT/-ENOMEM/-EHWPOISON
if i is 0.


> If you ask for one page, and get zero pages, then that's an -EFAULT.
> Note that that's an EFAULT regardless of whether that zero page
> happened due to kernel addresses or just lack of mapping in user
> space.
> 
> The documentation is simply wrong if it says anything else. Fix the
> docs, and fix the users.
> 
> The correct use has always been to check the number of pages returned.
> 
> Just looking around, returning an error number looks like it could
> seriously confuse some things.
>
> You have things like the kvm code that
> does the *right* thing:
> 
>         unsigned long ... npinned ...
> 
>         npinned = get_user_pages_fast(uaddr, npages, write ?
> FOLL_WRITE : 0, pages);
>         if (npinned != npages) {
>      ...
> 
> err:
>         if (npinned > 0)
>                 release_pages(pages, npinned);
> 
> and the above code clearly depends on the actual behavior, not on the
> documentation.

This seems to work fine with my patch since it only changes the
case where npinned == 0.

> Any changes in this area would need some *extreme* care, exactly
> because of code like the above that clearly depends on the existing
> semantics.
> 
> In fact, the documentation really seems to be just buggy. The actual
> get_user_pages() function itself is expressly being careful *not* to
> return an error code, it even has a comment to the effect ("Have to be
> a bit careful with return values").
> 
> So the "If no pages were pinned, returns -errno" comment is just bogus.
> 
>                   Linus

I'd like to change the doc then, but it seems that I'll have to change
the implementation in that case too.

-- 
MST
