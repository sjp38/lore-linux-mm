Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6FBAB6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 09:38:32 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so135878282wic.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 06:38:32 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id s2si43739961wik.32.2015.10.22.06.38.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 06:38:30 -0700 (PDT)
Date: Thu, 22 Oct 2015 15:38:24 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 14/23] userfaultfd: wake pending userfaults
Message-ID: <20151022133824.GR17308@twins.programming.kicks-ass.net>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-15-git-send-email-aarcange@redhat.com>
 <20151022121056.GB7520@twins.programming.kicks-ass.net>
 <20151022132015.GF19147@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022132015.GF19147@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, Oct 22, 2015 at 03:20:15PM +0200, Andrea Arcangeli wrote:

> If schedule spontaneously wakes up a task in TASK_KILLABLE state that
> would be a bug in the scheduler in my view. Luckily there doesn't seem
> to be such a bug, or at least we never experienced it.

Well, there will be a wakeup, just not the one you were hoping for.

We have code that does:

	@cond = true;
	get_task_struct(p);
	queue(p)

				/* random wait somewhere */
				for (;;) {
					prepare_to_wait();
					if (@cond)
					  break;

				...

				handle_userfault()
				  ...
				  schedule();
	...

	dequeue(p)
	wake_up_process(p) ---> wakeup without userfault wakeup


These races are (extremely) rare, but they do exist. Therefore one must
never assume schedule() will not spuriously wake because of these
things.

Also, see:

lkml.kernel.org/r/CA+55aFwHkOo+YGWKYROmce1-H_uG3KfEUmCkJUerTj=ojY2H6Q@mail.gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
