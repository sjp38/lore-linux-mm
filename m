Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8BE606B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 06:46:01 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id q107so29301219qgd.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:46:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j7si5933253qan.55.2015.02.24.03.45.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Feb 2015 03:46:01 -0800 (PST)
Date: Tue, 24 Feb 2015 12:45:03 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC 0/6] the big khugepaged redesign
Message-ID: <20150224114503.GH5542@redhat.com>
References: <1424696322-21952-1-git-send-email-vbabka@suse.cz>
 <1424731603.6539.51.camel@stgolabs.net>
 <20150223145619.64f3a225b914034a17d4f520@linux-foundation.org>
 <54EC533E.8040805@suse.cz>
 <20150224112412.GG5542@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224112412.GG5542@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Alex Thorlton <athorlton@sgi.com>, David Rientjes <rientjes@google.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>

On Tue, Feb 24, 2015 at 12:24:12PM +0100, Andrea Arcangeli wrote:
> I would advise not to make changes for app that are already the
> biggest users ever of hugetlbfs (like Oracle). Those already are
> optimized by other means. THP target are apps that have several

Before somebody risks to misunderstand perhaps I should clarify
further: what I meant is that if the khugepaged boost helps Oracle or
other heavy users of hugetlbfs, but it _hurts_ everything else as I'd
guess, I'd advise against it. Because if an app can deal with
hugetlbfs it's much simpler to optimize by other means and it's not
the primary target of THP so the priority for THP default behavior
should be biased towards those apps that can't easily fit into
hugetlbfs and numa hard pins static placement models.

Of course it'd be perfectly fine to make THP changes that helps even
the biggest hugetlbfs users out there, as long as these changes don't
hurt all other normal use cases (where THP is always guaranteed to
provide a significant performance boost if enabled). Chances are the
benchmarks are also comparing "hugetlbfs+THP" vs "hugetlbfs" without
THP, and not "nothing" vs "THP".

Clearly I'd like to optimize for all apps including the biggest
hugetlbfs users, and this is why I'd like to optimize redis as well,
considering it's simple enough to do it with just one madvise to
change the behavior of COW faults and it'd be guaranteed not to hurt
any other common usage. If we were to instead change the default
behavior of COW faults we'd need first to collect data for a variety
of apps and personally I doubt such a change would be a good universal
tradeoff, while it's a fine change for a behavioral change through
madvise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
