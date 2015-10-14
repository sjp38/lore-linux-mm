Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id AB9906B0254
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 15:16:48 -0400 (EDT)
Received: by iow1 with SMTP id 1so66737093iow.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:16:48 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id t2si8550237ioe.182.2015.10.14.12.16.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 12:16:48 -0700 (PDT)
Received: by igbhv6 with SMTP id hv6so24755758igb.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 12:16:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20151014190259.GC12799@mtj.duckdns.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<20151014165729.GA12799@mtj.duckdns.org>
	<CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
	<20151014190259.GC12799@mtj.duckdns.org>
Date: Wed, 14 Oct 2015 12:16:48 -0700
Message-ID: <CA+55aFz27G4gLS9AFs6hHJfULXAqA=tM5KA=YvBH8MaZ+sT-VA@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 12:02 PM, Tejun Heo <tj@kernel.org> wrote:
>
> But wasn't add_timer() always CPU-local at the time?  add_timer()
> allowing cross-cpu migrations came way after that.

add_timer() has actually never been "local CPU only" either.

What add_timer() does is to keep the timer on the old CPU timer wheel
if it was active, and if it wasn't, put it on the current CPU timer
wheel.

So again, by pure *accident*, if you don't end up ever modifying an
already-active timer, then yes, it ended up being local. But even
then, things like suspend/resume can move timers around, afaik, so
even then it has never been a real guarantee.

And I see absolutely no sign that the local cpu case has ever been intentional.

Now, obviously, that said there is obviously at least one case that
seems to have relied on it (ie the mm/vmstat.c case), but I think we
should just fix that.

If it turns out that there really are *lots* of cases where
"schedule_delayed_work()" expects the work to always run on the CPU
that it is scheduled on, then we should probably take your patch just
because it's too painful not to.

But I'd like to avoid that if possible.

                             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
