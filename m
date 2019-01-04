Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3E2E8E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 03:58:06 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id o205so485478itc.2
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 00:58:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b13sor1394383itc.1.2019.01.04.00.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 Jan 2019 00:58:05 -0800 (PST)
MIME-Version: 1.0
References: <000000000000c06550057e4cac7c@google.com> <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com> <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
In-Reply-To: <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 4 Jan 2019 09:57:54 +0100
Message-ID: <CACT4Y+YazhPjqkTRgAkyTFTDujcUEm32TxCUxSGG2tu5zb1Xtw@mail.gmail.com>
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>

On Fri, Jan 4, 2019 at 9:50 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/3/19 9:42 AM, Dmitry Vyukov wrote:
> > On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
> >>
> >>
> >> On 12/31/18 8:51 AM, syzbot wrote:
> >>> Hello,
> >>>
> >>> syzbot found the following crash on:
> >>>
> >>> HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
> >>> git tree:       kmsan
> >>> console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
> >>> kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
> >>> dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
> >>> compiler:       clang version 8.0.0 (trunk 349734)
> >>>
> >>> Unfortunately, I don't have any reproducer for this crash yet.
> >>>
> >>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> >>> Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
> >>>
> >>> ==================================================================
> >>> BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
> >>> BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
> >>
> >> The report doesn't seem to indicate where the uninit value resides in
> >> the mempolicy object.
> >
> > Yes, it doesn't and it's not trivial to do. The tool reports uses of
> > unint _values_. Values don't necessary reside in memory. It can be a
> > register, that come from another register that was calculated as a sum
> > of two other values, which may come from a function argument, etc.
>
> I see. BTW, the patch I sent will be picked up for testing, or does it
> have to be in mmotm/linux-next first?

It needs to be in upstream tree. Since KMSAN is not upstream, we have
only 1 branch that is based on upstream and is periodically rebased:
https://github.com/google/kmsan
If the bug would have a repro, then we could ask syzbot to test this
patch on top of KMSAN tree. But unfortunately it doesn't.
