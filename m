Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id B0B6E6B006E
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 13:35:02 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id q108so8199457qgd.0
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:35:02 -0800 (PST)
Received: from resqmta-ch2-08v.sys.comcast.net (resqmta-ch2-08v.sys.comcast.net. [2001:558:fe21:29:69:252:207:40])
        by mx.google.com with ESMTPS id 95si14272971qgb.16.2015.01.26.10.35.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 10:35:01 -0800 (PST)
Date: Mon, 26 Jan 2015 12:35:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
In-Reply-To: <20150126174606.GD22681@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.11.1501261233550.16786@gentwo.org>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org> <20150114165036.GI4706@dhcp22.suse.cz> <54B7F7C4.2070105@codeaurora.org> <20150116154922.GB4650@dhcp22.suse.cz> <54BA7D3A.40100@codeaurora.org> <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
 <54BC879C.90505@codeaurora.org> <20150121143920.GD23700@dhcp22.suse.cz> <alpine.DEB.2.11.1501221010510.3937@gentwo.org> <20150126174606.GD22681@dhcp22.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Mon, 26 Jan 2015, Michal Hocko wrote:

> > Please do not run the vmstat_updates concurrently. They update shared
> > cachelines and therefore can cause bouncing cachelines if run concurrently
> > on multiple cpus.
>
> Would you preffer to call smp_call_function_single on each CPU
> which needs an update? That would make vmstat_shepherd slower but that
> is not a big deal, is it?

Run it from the timer interrupt as usual from a work request? Those are
staggered.

> Anyway I am wondering whether the cache line bouncing between
> vmstat_update instances is a big deal in the real life. Updating shared
> counters whould bounce with many CPUs but this is an operation which is
> not done often. Also all the CPUs would have update the same counters
> all the time and I am not sure this happens that often. Do you have a
> load where this would be measurable?

Concurrent page faults update lots of counters concurrently. But will
those trigger the smp_call_function?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
