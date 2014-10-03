Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id 58C4C6B006E
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:23:54 -0400 (EDT)
Received: by mail-vc0-f174.google.com with SMTP id hq12so1020610vcb.5
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:23:54 -0700 (PDT)
Received: from mail-vc0-x231.google.com (mail-vc0-x231.google.com [2607:f8b0:400c:c03::231])
        by mx.google.com with ESMTPS id o9si4839301vda.12.2014.10.03.11.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 03 Oct 2014 11:23:53 -0700 (PDT)
Received: by mail-vc0-f177.google.com with SMTP id hq11so1013241vcb.8
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:23:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1412356087-16115-5-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
	<1412356087-16115-5-git-send-email-aarcange@redhat.com>
Date: Fri, 3 Oct 2014 11:23:53 -0700
Message-ID: <CA+55aFyuYRuY9fiJQKL=XJ0-BKhGsZbo1HGkGUOJ6DbbxdA-dQ@mail.gmail.com>
Subject: Re: [PATCH 04/17] mm: gup: make get_user_pages_fast and
 __get_user_pages_fast latency conscious
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: qemu-devel@nongnu.org, KVM list <kvm@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\Dr. David Alan Gilbert\\" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

On Fri, Oct 3, 2014 at 10:07 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> This teaches gup_fast and __gup_fast to re-enable irqs and
> cond_resched() if possible every BATCH_PAGES.

This is disgusting.

Many (most?) __gup_fast() users just want a single page, and the
stupid overhead of the multi-page version is already unnecessary.
This just makes things much worse.

Quite frankly, we should make a single-page version of __gup_fast(),
and convert existign users to use that. After that, the few multi-page
users could have this extra latency control stuff.

And yes, the single-page version of get_user_pages_fast() is actually
latency-critical. shared futexes hit it hard, and yes, I've seen this
in profiles.

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
