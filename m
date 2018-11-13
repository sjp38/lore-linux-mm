Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id C06436B000C
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:57:31 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id k76so567518oih.13
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:57:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u123-v6sor8825913oie.105.2018.11.13.03.57.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 03:57:30 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru>
In-Reply-To: <20181112231344.7161-1-timofey.titovets@synesis.ru>
From: Jann Horn <jannh@google.com>
Date: Tue, 13 Nov 2018 12:57:03 +0100
Message-ID: <CAG48ez0VRmRQckOjQhOeaf6bLYkfi45ksdnzuCKPwBYTM+As1g@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: timofey.titovets@synesis.ru
Cc: kernel list <linux-kernel@vger.kernel.org>, nefelim4ag@gmail.com, Matthew Wilcox <willy@infradead.org>, Linux-MM <linux-mm@kvack.org>, linux-doc@vger.kernel.org

On Tue, Nov 13, 2018 at 12:40 PM Timofey Titovets
<timofey.titovets@synesis.ru> wrote:
> ksm by default working only on memory that added by
> madvise().
>
> And only way get that work on other applications:
>   * Use LD_PRELOAD and libraries
>   * Patch kernel
>
> Lets use kernel task list and add logic to import VMAs from tasks.
>
> That behaviour controlled by new attributes:
>   * mode:
>     I try mimic hugepages attribute, so mode have two states:
>       * madvise      - old default behaviour
>       * always [new] - allow ksm to get tasks vma and
>                        try working on that.

Please don't. And if you really have to for some reason, put some big
warnings on this, advising people that it's a security risk.

KSM is one of the favorite punching bags of side-channel and hardware
security researchers:

As a gigantic, problematic side channel:
http://staff.aist.go.jp/k.suzaki/EuroSec2011-suzaki.pdf
https://www.usenix.org/system/files/conference/woot15/woot15-paper-barresi.pdf
https://access.redhat.com/blogs/766093/posts/1976303
https://gruss.cc/files/dedup.pdf

In particular https://gruss.cc/files/dedup.pdf ("Practical Memory
Deduplication Attacks in Sandboxed JavaScript") shows that KSM makes
it possible to use malicious JavaScript to determine whether a given
page of memory exists elsewhere on your system.

And also as a way to target rowhammer-based faults:
https://www.usenix.org/system/files/conference/usenixsecurity16/sec16_paper_razavi.pdf
https://thisissecurity.stormshield.com/2017/10/19/attacking-co-hosted-vm-hacker-hammer-two-memory-modules/
