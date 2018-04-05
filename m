Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id E6BAE6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 11:40:07 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 140-v6so3207747itg.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:40:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t204sor3742882iod.55.2018.04.05.08.40.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 08:40:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180405171009-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
 <20180405045231-mutt-send-email-mst@kernel.org> <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
 <20180405171009-mutt-send-email-mst@kernel.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 5 Apr 2018 08:40:05 -0700
Message-ID: <CA+55aFz_mCZQPV6ownt+pYnLFf9O+LUK_J6y4t1GUyWL1NJ2Lg@mail.gmail.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

On Thu, Apr 5, 2018 at 7:17 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
> I wonder however whether all the following should be changed then:
>
> static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
>
> ...
>
>                         if (!vma || check_vma_flags(vma, gup_flags))
>                                 return i ? : -EFAULT;
>
> is this a bug in __get_user_pages?

Note the difference between "get_user_pages()", and "get_user_pages_fast()".

It's the *fast* versions that just return the number of pages pinned.

The non-fast ones will return an error code for various cases.

Why?

The non-fast cases actually *have* various error cases. They can block
and get interrupted etc.

The fast cases are basically "just get me the pages, dammit, and if
you can't get some page, stop".

At least that's one excuse for the difference in behavior.

The real excuse is probably just "that's how it worked" - the fast
case just walked the page tables and that was it.

                 Linus
