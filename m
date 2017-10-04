Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A55256B0033
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 19:18:30 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id q203so9579503wmb.0
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 16:18:30 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p35si504274edp.83.2017.10.04.16.18.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 16:18:29 -0700 (PDT)
Date: Wed, 4 Oct 2017 19:18:21 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
Message-ID: <20171004231821.GA3610@cmpxchg.org>
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org>
 <20171004185906.GB2136@cmpxchg.org>
 <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Oct 04, 2017 at 03:32:45PM -0700, Andrew Morton wrote:
> On Wed, 4 Oct 2017 14:59:06 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > This reverts commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb and
> > commit 171012f561274784160f666f8398af8b42216e1f.
> > 
> > 5d17a73a2ebe ("vmalloc: back off when the current task is killed")
> > made all vmalloc allocations from a signal-killed task fail. We have
> > seen crashes in the tty driver from this, where a killed task exiting
> > tries to switch back to N_TTY, fails n_tty_open because of the vmalloc
> > failing, and later crashes when dereferencing tty->disc_data.
> > 
> > Arguably, relying on a vmalloc() call to succeed in order to properly
> > exit a task is not the most robust way of doing things. There will be
> > a follow-up patch to the tty code to fall back to the N_NULL ldisc.
> > 
> > But the justification to make that vmalloc() call fail like this isn't
> > convincing, either. The patch mentions an OOM victim exhausting the
> > memory reserves and thus deadlocking the machine. But the OOM killer
> > is only one, improbable source of fatal signals. It doesn't make sense
> > to fail allocations preemptively with plenty of memory in most cases.
> > 
> > The patch doesn't mention real-life instances where vmalloc sites
> > would exhaust memory, which makes it sound more like a theoretical
> > issue to begin with. But just in case, the OOM access to memory
> > reserves has been restricted on the allocator side in cd04ae1e2dc8
> > ("mm, oom: do not rely on TIF_MEMDIE for memory reserves access"),
> > which should take care of any theoretical concerns on that front.
> > 
> > Revert this patch, and the follow-up that suppresses the allocation
> > warnings when we fail the allocations due to a signal.
> 
> You don't think they should be backported into -stables?

Good point. For this one, it makes sense to CC stable, for 4.11 and
up. The second patch is more of a fortification against potential
future issues, and probably shouldn't go into stable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
