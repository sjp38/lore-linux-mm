Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id BF38A6B0071
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 12:43:05 -0400 (EDT)
Received: by widdi4 with SMTP id di4so147696685wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 09:43:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc7si39347937wjc.124.2015.04.28.09.43.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 09:43:04 -0700 (PDT)
Date: Tue, 28 Apr 2015 18:43:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Should mmap MAP_LOCKED fail if mm_poppulate fails?
Message-ID: <20150428164302.GI2659@dhcp22.suse.cz>
References: <20150114095019.GC4706@dhcp22.suse.cz>
 <1430223111-14817-1-git-send-email-mhocko@suse.cz>
 <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxzLXx=cC309h_tEc-Gkn_zH4ipR7PsefVcE-97Uj066g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Cyril Hrubis <chrubis@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Michael Kerrisk <mtk.manpages@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Tue 28-04-15 09:01:59, Linus Torvalds wrote:
[...]
> Your code is also fundamentally buggy in that it tries to do unmap()
> after it has dropped all locks, and things went wrong. So you may nto
> be unmapping some other threads data.

Hmm, no other thread has the address from the current mmap call except
for MAP_FIXED (more on that below).

Well I can imagine userspace doing nasty things like watching
/proc/self/maps and using the address from there or using an address as
an mmap hint and then using it before mmap returns by other threads. But
would those be valid usecases? They sound crazy and buggy to me.

Another nasty case would be MAP_FIXED from a different thread destroying
the mmap I am trying to poppulate but that is not so interesting because
nothing protects from that even now.
Or this being MAP_FIXED|MAP_LOCKED which has already destroyed a part
of somebody's else mapping and the cleanup would lead to an unexpected
SIGSEGV for the other thread. Is this the case you are worried about?

Or am I missing other cases?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
