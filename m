Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id B4BE46B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 22:04:41 -0500 (EST)
Received: by qgcc31 with SMTP id c31so22284420qgc.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:04:41 -0800 (PST)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id y70si9335103qgd.62.2015.11.19.19.04.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 19:04:41 -0800 (PST)
Received: by qkda6 with SMTP id a6so32662133qkd.3
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 19:04:40 -0800 (PST)
Date: Thu, 19 Nov 2015 22:04:37 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [RFC 7/8] userfaultfd: fault try one more time
Message-ID: <20151120030436.GB3093@gmail.com>
References: <cover.1447964595.git.shli@fb.com>
 <07f86ce80ddfc38fbf8247287e5b6475b1cd436d.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <07f86ce80ddfc38fbf8247287e5b6475b1cd436d.1447964595.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 19, 2015 at 02:33:52PM -0800, Shaohua Li wrote:
> For a swapin memory write fault, fault handler already retry once to
> read the page in. userfaultfd can't do the retry again and fail. Give
> another retry for userfaultfd in such case. gup isn't fixed yet, so will
> return -EBUSY.

This whole patch make me nervous. I do not see the point in it. So on
page fault in first pass you have the RETRY flag set and you can either
return VM_FAULT_RETRY because (1) lock_page_or_retry() in do_swap_page()
or because (2) handle_userfault().

In second case, on retry you already have a valid read only pte so you
go directly to do_wp_page() and this is properly handle by current
handle_userfault() code. So it does not make sense to add complexity
for that case.

You seem to hint that you are doing this for the first case (1) but even
for that one it does not make sense. So if we fail to lock the page it
is because someone else is doing something with that page and most likely
it is related to the userfaultfd already (like another thread took the
fault and is doing all the steps you need). So you just want a regular
retry, ie do_swap_page() return retry and on retry it is likely that
everything is already all good. If not that it takes the slow painful
wait code path.

I genuinely do not see what benefit and reasons there is to this new
special usefaultfd retry flag.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
