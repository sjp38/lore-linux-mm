Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id DC9576B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 13:57:33 -0400 (EDT)
Received: by igbif5 with SMTP id if5so26552523igb.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 10:57:33 -0700 (PDT)
Received: from resqmta-ch2-03v.sys.comcast.net (resqmta-ch2-03v.sys.comcast.net. [2001:558:fe21:29:69:252:207:35])
        by mx.google.com with ESMTPS id q1si8237038igh.93.2015.10.14.10.57.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 14 Oct 2015 10:57:33 -0700 (PDT)
Date: Wed, 14 Oct 2015 12:57:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] workqueue fixes for v4.3-rc5
In-Reply-To: <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1510141253570.13238@east.gentwo.org>
References: <20151013214952.GB23106@mtj.duckdns.org> <CA+55aFzV61qsWOObLUPpL-2iU1=8EopEgfse+kRGuUi9kevoOA@mail.gmail.com> <20151014165729.GA12799@mtj.duckdns.org> <CA+55aFzhHF0KMFvebegBnwHqXekfRRd-qczCtJXKpf3XvOCW=A@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lai Jiangshan <jiangshanlai@gmail.com>, Shaohua Li <shli@fb.com>, linux-mm <linux-mm@kvack.org>

On Wed, 14 Oct 2015, Linus Torvalds wrote:

> I don't think it's normally a problem. But mm/vmstat.c clearly *is*
> confused, and uses both "schedule_delayed_work_on()" and
> "schedule_delayed_work()" for the same work.

Well yes the schedule_delayed_work_on() call is from another cpu and the
schedule_delayed_work() from the same. No confusion there.

vmstat_update() is run from the cpu where the diffs have to be updated and
if it needs to reschedule itself it relies on schedule_delayed_work() to
stay on the same cpu.

The vmstat_shepherd needs to start work items on remote cpus and therefore
uses xx_work_on().

And yes this relies on work items being executed on the same cpu unless
the queue is decleared to be UNBOUND which is not the case here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
