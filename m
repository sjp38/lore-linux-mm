Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 606196B025E
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:39:23 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id q11so30256223qtb.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 06:39:23 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l2si2376656qke.304.2016.07.12.06.39.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 06:39:22 -0700 (PDT)
Date: Tue, 12 Jul 2016 15:39:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/2] mm: refuse wrapped vm_brk requests
Message-ID: <20160712133942.GA28837@redhat.com>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org> <1468014494-25291-3-git-send-email-keescook@chromium.org> <20160711122826.GA969@redhat.com> <CAGXu5j+efUrhOTikpuYK0V8Eqv58f5rQBMOYDqiVM-JWrqRbLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+efUrhOTikpuYK0V8Eqv58f5rQBMOYDqiVM-JWrqRbLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/11, Kees Cook wrote:
>
> On Mon, Jul 11, 2016 at 8:28 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > and thus this patch fixes the error code returned by do_brk() in case
> > of overflow, now it returns -ENOMEM rather than zero. Perhaps
> >
> >         if (!len)
> >                 return 0;
> >         len = PAGE_ALIGN(len);
> >         if (!len)
> >                 return -ENOMEM;
> >
> > would be more clear but this is subjective.
>
> I'm fine either way.

Me too, so feel free to ignore,

> > I am wondering if we should shift this overflow check to the caller(s).
> > Say, sys_brk() does find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE)
> > before do_brk(), and in case of overflow find_vma_intersection() can
> > wrongly return NULL.
> >
> > Then do_brk() will be called with len = -oldbrk, this can overflow or
> > not but in any case this doesn't look right too.
> >
> > Or I am totally confused?
>
> I think the callers shouldn't request a negative value, sure, but
> vm_brk should notice and refuse it.

Not sure I understand...

I tried to say that, with or without this change, sys_brk() should check
for overflow too, otherwise it looks buggy.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
