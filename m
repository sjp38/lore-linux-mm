Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8286B006C
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:49:06 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so79474745igb.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:49:06 -0700 (PDT)
Received: from mail-ie0-x22a.google.com (mail-ie0-x22a.google.com. [2607:f8b0:4001:c03::22a])
        by mx.google.com with ESMTPS id u91si505607ioi.85.2015.05.14.10.49.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:49:06 -0700 (PDT)
Received: by iecmd7 with SMTP id md7so67074614iec.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:49:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1431624680-20153-11-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
	<1431624680-20153-11-git-send-email-aarcange@redhat.com>
Date: Thu, 14 May 2015 10:49:06 -0700
Message-ID: <CA+55aFwCODeiXUPDR7-Y-=2xE2abmVuCnmVV=ezFqhO+JkaW=A@mail.gmail.com>
Subject: Re: [PATCH 10/23] userfaultfd: add new syscall to provide memory externalization
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, May 14, 2015 at 10:31 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> +static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
> +                                          struct userfaultfd_wake_range *range)
> +{
> +       if (waitqueue_active(&ctx->fault_wqh))
> +               __wake_userfault(ctx, range);
> +}

Pretty much every single time people use this "if
(waitqueue_active())" model, it tends to be a bug, because it means
that there is zero serialization with people who are just about to go
to sleep. It's fundamentally racy against all the "wait_event()" loops
that carefully do memory barriers between testing conditions and going
to sleep, because the memory barriers now don't exist on the waking
side.

So I'm making a new rule: if you use waitqueue_active(), I want an
explanation for why it's not racy with the waiter. A big comment about
the memory ordering, or about higher-level locks that are held by the
caller, or something.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
