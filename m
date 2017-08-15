Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB206B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 18:56:16 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id s199so7910727vke.10
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:56:16 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id j20si5582187uab.340.2017.08.15.15.56.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Aug 2017 15:56:15 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id j189so7165487vka.0
        for <linux-mm@kvack.org>; Tue, 15 Aug 2017 15:56:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170815224728.GA1373@linux-80c1.suse>
References: <84c7f26182b7f4723c0fe3b34ba912a9de92b8b7.1502758114.git.tim.c.chen@linux.intel.com>
 <CA+55aFznC1wqBSfYr8=92LGqz5-F6fHMzdXoqM4aOYx8sT1Dhg@mail.gmail.com>
 <20170815022743.GB28715@tassilo.jf.intel.com> <CA+55aFyHVV=eTtAocUrNLymQOCj55qkF58+N+Tjr2YS9TrqFow@mail.gmail.com>
 <20170815031524.GC28715@tassilo.jf.intel.com> <CA+55aFw1A1C8qUeKPUzACrsqn97UDxTP3M2SRs80aEztfU=Qbg@mail.gmail.com>
 <20170815224728.GA1373@linux-80c1.suse>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 15 Aug 2017 15:56:14 -0700
Message-ID: <CA+55aFyMkd8EaozxvAZo9i3ArKh7m6HLjsUB34xnDBzXz4gowg@mail.gmail.com>
Subject: Re: [PATCH 1/2] sched/wait: Break up long wake list walk
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Kan Liang <kan.liang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Aug 15, 2017 at 3:47 PM, Davidlohr Bueso <dave@stgolabs.net> wrote:
>
> Or you can always use wake_qs; which exists _exactly_ for the issues you
> are running into

Except they really don't actually work for this case, exactly because
they also simplify away "minor" details like exclusive vs
non-exclusive etc.

The page wait-queue very much has a mix of "wake all" and "wake one" semantics.

But I guess we could have two queues per page hash - one that is
wake-once, and one that is wake-all.

Which might solve the technical problem.

And if somebody then rewrote the swait code to not use the
unbelievably broken and misleading naming, it might even be
acceptable.

But as is, that swait code is broken shit, and absolutely does *not*
need new users.  We got rid of one user, and the KVM people already
admitted that one of the remaining users is broken and doesn't
actually want swait at all and should use "wake_up_process()" instead
since there is no actual queuing going on.

In the meantime, stop peddling crap.  That thing really is broken.

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
