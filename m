Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56E946B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 13:00:35 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id w127so27107123vkh.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 10:00:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o13si2836369qko.135.2016.07.13.10.00.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 10:00:34 -0700 (PDT)
Date: Wed, 13 Jul 2016 19:00:49 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/2] mm: refuse wrapped vm_brk requests
Message-ID: <20160713170048.GA24553@redhat.com>
References: <1468014494-25291-1-git-send-email-keescook@chromium.org> <1468014494-25291-3-git-send-email-keescook@chromium.org> <20160711122826.GA969@redhat.com> <CAGXu5j+efUrhOTikpuYK0V8Eqv58f5rQBMOYDqiVM-JWrqRbLA@mail.gmail.com> <20160712133942.GA28837@redhat.com> <CAGXu5j+oZ49K0omm-7yMsR_kFYD-DQcYG8f+urS+TumzFYXR_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5j+oZ49K0omm-7yMsR_kFYD-DQcYG8f+urS+TumzFYXR_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 07/12, Kees Cook wrote:
>
> On Tue, Jul 12, 2016 at 9:39 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > I tried to say that, with or without this change, sys_brk() should check
> > for overflow too, otherwise it looks buggy.
>
> Hmm, it's not clear to me the right way to fix sys_brk(), but it looks
> like my change to do_brk() would catch the problem?

How?

Once again, afaics nothing bad can happen, sys_brk() will silently fail,
just the code looks wrong anyway.

Suppose that newbrk == 0 due to overflow, then both

	if (find_vma_intersection(mm, oldbrk, newbrk+PAGE_SIZE))
		goto out;

and
	if (do_brk(oldbrk, newbrk-oldbrk) < 0)
		goto out;

look buggy.

find_vma_intersection(start_addr, end_addr) expects that start_addr < end_addr.
Again, we do not really care if it returns NULL or not, and newbrk == 0 just
means it will certainly return NULL if there is something above oldbrk. Just
looks buggy/confusing.

do_brk(0 - oldbrk) will fail and this is what we want. But not because
your change will catch the problem, PAGE_ALIGNE(-oldbrk) won't necessarily
overflow. However, -oldbrk > TASK_SIZE so get_unmapped_area() should fail.

Nevermind, this is almost off-topic, so let me repeat just in case that
both patches look good to me.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
