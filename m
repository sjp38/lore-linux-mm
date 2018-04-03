Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id AB9E56B0007
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 08:23:52 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f19-v6so9551138plr.23
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 05:23:52 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d1si1903921pgu.357.2018.04.03.05.23.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 05:23:51 -0700 (PDT)
Date: Tue, 3 Apr 2018 08:23:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403082348.28cd3c1c@gandalf.local.home>
In-Reply-To: <20180403121614.GV5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180403110612.GM5501@dhcp22.suse.cz>
	<20180403075158.0c0a2795@gandalf.local.home>
	<20180403121614.GV5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 3 Apr 2018 14:16:14 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> > This came up because there's scripts or programs that set the size of
> > the ring buffer. The complaint was that the application would just set
> > the size to something bigger than what was available and cause an OOM
> > killing other applications. The final solution is to simply check the
> > available memory before allocating the ring buffer:
> > 
> > 	/* Check if the available memory is there first */
> > 	i = si_mem_available();
> > 	if (i < nr_pages)
> > 		return -ENOMEM;
> > 
> > And it works well.  
> 
> Except that it doesn't work. si_mem_available is not really suitable for
> any allocation estimations. Its only purpose is to provide a very rough
> estimation for userspace. Any other use is basically abuse. The
> situation can change really quickly. Really it is really hard to be
> clever here with the volatility the memory allocations can cause.

OK, then what do you suggest? Because currently, it appears to work. A
rough estimate may be good enough.

If we use NORETRY, then we have those that complain that we do not try
hard enough to reclaim memory. If we use RETRY_MAYFAIL we have this
issue of taking up all memory before we get what we want.

Perhaps I should try to allocate a large group of pages with
RETRY_MAYFAIL, and if that fails go back to NORETRY, with the thinking
that the large allocation may reclaim some memory that would allow the
NORETRY to succeed with smaller allocations (one page at a time)?

-- Steve
