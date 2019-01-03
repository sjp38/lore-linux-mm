Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D13698E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 03:42:57 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id v8so37902901ioh.11
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 00:42:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s21sor7225037iol.146.2019.01.03.00.42.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 00:42:56 -0800 (PST)
MIME-Version: 1.0
References: <000000000000c06550057e4cac7c@google.com> <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
In-Reply-To: <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 3 Jan 2019 09:42:45 +0100
Message-ID: <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>

On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
>
> On 12/31/18 8:51 AM, syzbot wrote:
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
> > git tree:       kmsan
> > console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
> > dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
> > compiler:       clang version 8.0.0 (trunk 349734)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
> >
> > IMPORTANT: if you fix the bug, please add the following tag to the commit:
> > Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> >
> > ==================================================================
> > BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
> > BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
>
> The report doesn't seem to indicate where the uninit value resides in
> the mempolicy object.

Yes, it doesn't and it's not trivial to do. The tool reports uses of
unint _values_. Values don't necessary reside in memory. It can be a
register, that come from another register that was calculated as a sum
of two other values, which may come from a function argument, etc.

> I'll have to guess. mm/mempolicy.c:353 contains:
>
>         if (!mpol_store_user_nodemask(pol) &&
>             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
>
> "mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
> see being uninitialized after leaving mpol_new(). So I'll guess it's
> actually about accessing pol->w.cpuset_mems_allowed on line 354.
>
> For w.cpuset_mems_allowed to be not initialized and the nodes_equal()
> reachable for a mempolicy where mpol_set_nodemask() is called in
> do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
> with empty set of nodes, i.e. MPOL_LOCAL equivalent. Let's see if the
> patch below helps. This code is a maze to me. Note the uninit access
> should be benign, rebinding this kind of policy is always a no-op.
>
> ----8<----
> From ff0ca29da6bc2572d7b267daa77ced6083e3f02d Mon Sep 17 00:00:00 2001
> From: Vlastimil Babka <vbabka@suse.cz>
> Date: Thu, 3 Jan 2019 09:31:59 +0100
> Subject: [PATCH] mm, mempolicy: fix uninit memory access
>
> ---
>  mm/mempolicy.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index d4496d9d34f5..a0b7487b9112 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
>  {
>         if (!pol)
>                 return;
> -       if (!mpol_store_user_nodemask(pol) &&
> +       if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
>             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
>                 return;
>
> --
> 2.19.2
>
> --
> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/a71997c3-e8ae-a787-d5ce-3db05768b27c%40suse.cz.
> For more options, visit https://groups.google.com/d/optout.
