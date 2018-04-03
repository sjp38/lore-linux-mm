Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1676B0006
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 07:52:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id m6-v6so9476736pln.8
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 04:52:02 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 19si2087737pfi.285.2018.04.03.04.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 04:52:01 -0700 (PDT)
Date: Tue, 3 Apr 2018 07:51:58 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180403075158.0c0a2795@gandalf.local.home>
In-Reply-To: <20180403110612.GM5501@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
	<20180330102038.2378925b@gandalf.local.home>
	<20180403110612.GM5501@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Tue, 3 Apr 2018 13:06:12 +0200
Michal Hocko <mhocko@kernel.org> wrote:

> > I wonder if I should have the ring buffer allocate groups of pages, to
> > avoid this. Or try to allocate with NORETRY, one page at a time, and
> > when that fails, allocate groups of pages with RETRY_MAYFAIL, and that
> > may keep it from causing an OOM?  
> 
> I wonder why it really matters. The interface is root only and we expect
> some sanity from an admin, right? So allocating such a large ring buffer
> that it sends the system to the OOM is a sign that the admin should be
> more careful. Balancing on the OOM edge is always a risk and the result
> will highly depend on the workload running in parallel.

This came up because there's scripts or programs that set the size of
the ring buffer. The complaint was that the application would just set
the size to something bigger than what was available and cause an OOM
killing other applications. The final solution is to simply check the
available memory before allocating the ring buffer:

	/* Check if the available memory is there first */
	i = si_mem_available();
	if (i < nr_pages)
		return -ENOMEM;

And it works well.

-- Steve
