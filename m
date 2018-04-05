Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 493BD6B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 14:28:28 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id 20so17551809qkd.2
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 11:28:28 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d10si4943824qtb.345.2018.04.05.11.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 11:28:27 -0700 (PDT)
Date: Thu, 5 Apr 2018 21:28:25 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] gup: return -EFAULT on access_ok failure
Message-ID: <20180405211945-mutt-send-email-mst@kernel.org>
References: <1522431382-4232-1-git-send-email-mst@redhat.com>
 <20180405045231-mutt-send-email-mst@kernel.org>
 <CA+55aFwpe92MzEX2qRHO-MQsa1CP-iz6AmanFqXCV6_EaNKyMg@mail.gmail.com>
 <20180405171009-mutt-send-email-mst@kernel.org>
 <CA+55aFz_mCZQPV6ownt+pYnLFf9O+LUK_J6y4t1GUyWL1NJ2Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz_mCZQPV6ownt+pYnLFf9O+LUK_J6y4t1GUyWL1NJ2Lg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, syzbot+6304bf97ef436580fede@syzkaller.appspotmail.com, linux-mm <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Thorsten Leemhuis <regressions@leemhuis.info>

On Thu, Apr 05, 2018 at 08:40:05AM -0700, Linus Torvalds wrote:
> On Thu, Apr 5, 2018 at 7:17 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > I wonder however whether all the following should be changed then:
> >
> > static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
> >
> > ...
> >
> >                         if (!vma || check_vma_flags(vma, gup_flags))
> >                                 return i ? : -EFAULT;
> >
> > is this a bug in __get_user_pages?
> 
> Note the difference between "get_user_pages()", and "get_user_pages_fast()".
> 
> It's the *fast* versions that just return the number of pages pinned.
> 
> The non-fast ones will return an error code for various cases.
> 
> Why?
> 
> The non-fast cases actually *have* various error cases. They can block
> and get interrupted etc.
> 
> The fast cases are basically "just get me the pages, dammit, and if
> you can't get some page, stop".
> 
> At least that's one excuse for the difference in behavior.
> 
> The real excuse is probably just "that's how it worked" - the fast
> case just walked the page tables and that was it.
> 
>                  Linus

I see, thanks for the clarification Linus.

to repeat what you are saying IIUC __get_user_pages_fast returns 0 if it can't
pin any pages and that is by design.  Returning 0 on error isn't usual I think
so I guess this behaviour should we well documented.

That part of my patch was wrong and should be replaced with a doc
update.

What about get_user_pages_fast though? That's the other part of the
patch. Right now get_user_pages_fast does:

                ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
                                write ? FOLL_WRITE : 0);

                /* Have to be a bit careful with return values */
                if (nr > 0) {
                        if (ret < 0)
                                ret = nr;
                        else
                                ret += nr;
                }

so an error on the 1st page gets propagated to the caller,
and that get_user_pages_unlocked eventually calls __get_user_pages
so it does return an error sometimes.

Would it be correct to apply the second part of the patch then
(pasted below for reference) or should get_user_pages_fast
and all its callers be changed to return 0 on error instead?

@@ -1806,9 +1809,12 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 	len = (unsigned long) nr_pages << PAGE_SHIFT;
 	end = start + len;
 
+	if (nr_pages <= 0)
+		return 0;
+
 	if (unlikely(!access_ok(write ? VERIFY_WRITE : VERIFY_READ,
 					(void __user *)start, len)))
-		return 0;
+		return -EFAULT;
 
 	if (gup_fast_permitted(start, nr_pages, write)) {
 		local_irq_disable();

-- 
MST
