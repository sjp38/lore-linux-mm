Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7AC116B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 11:22:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id u63so26350229wmu.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 08:22:27 -0800 (PST)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id t2si12733911wmt.152.2017.02.07.08.22.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 08:22:26 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E82E698D81
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:22:25 +0000 (UTC)
Date: Tue, 7 Feb 2017 16:22:24 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207162224.elnrlgibjegswsgn@techsingularity.net>
References: <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170207153459.GV5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Feb 07, 2017 at 04:34:59PM +0100, Michal Hocko wrote:
> > But we do not care about the whole cpu hotplug code. The only part we
> > really do care about is the race inside drain_pages_zone and that will
> > run in an atomic context on the specific CPU.
> > 
> > You are absolutely right that using the mutex is safe as well but the
> > hotplug path is already littered with locks and adding one more to the
> > picture doesn't sound great to me. So I would really like to not use a
> > lock if that is possible and safe (with a big fat comment of course).
> 
> And with the full changelog. I hope I haven't missed anything this time.
> ---
> From 8c6af3116520251cc4ec2213f0a4ed2544bb4365 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 7 Feb 2017 16:08:35 +0100
> Subject: [PATCH] mm, page_alloc: do not depend on cpu hotplug locks inside the
>  allocator
> 
> <SNIP>
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Not that I can think of. It's almost identical to the diff I posted with
the exception of the mutex in the cpu hotplug teardown path. I agree that
in the current implementation that it should be unnecessary even if I
thought it would be more robust against any other hotplug churn.

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
