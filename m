Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id EB5B16B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 14:37:53 -0400 (EDT)
Received: by igbhv6 with SMTP id hv6so23921096igb.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:37:53 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id t10si18182053igr.35.2015.10.14.11.37.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 11:37:52 -0700 (PDT)
Received: by iow1 with SMTP id 1so65545641iow.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 11:37:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1510141253570.13238@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org>
	<CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com>
	<20151014165729.GA12799@mtj.duckdns.org>
	<CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
	<alpine.DEB.2.20.1510141253570.13238@east.gentwo.org>
Date: Wed, 14 Oct 2015 11:37:52 -0700
Message-ID: <CA+55aFz+_Zh7O544QL3YCjTr1rfb-Q82wAyHTK8QMr+9X81h2g@mail.gmail.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, Oct 14, 2015 at 10:57 AM, Christoph Lameter <cl@linux.com> wrote:
>
> Well yes the schedule_delayed_work_on() call is from another cpu and the
> schedule_delayed_work() from the same. No confusion there.

So "schedule_delayed_work()" does *not* guarantee that the work will
run on the same CPU.

Yes, yes, it so _happens_ that "add_timer()" preferentially uses the
current CPU etc, so in practice it may have happened to work. But
there's absolutely zero reason to think it should always work that
way.

If you want the scheduled work to happen on a particular CPU, then you
should use "schedule_delayed_work_on()"  It shouldn't matter which CPU
you call it from.

At least that's how I think the rules should be. Very simple, very
clear: if you require a specific CPU, say so. Don't silently depend on
"in practice, lots of times we tend to use the local cpu".

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
