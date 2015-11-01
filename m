Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2951782F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 18:46:01 -0500 (EST)
Received: by qgbb65 with SMTP id b65so104084710qgb.2
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 15:46:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i137si15873117qhc.51.2015.11.01.15.46.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 15:46:00 -0800 (PST)
Date: Mon, 2 Nov 2015 00:45:58 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 6/6] ksm: unstable_tree_search_insert error checking
 cleanup
Message-ID: <20151101234558.GT5390@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
 <1444925065-4841-7-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1510251601230.1923@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510251601230.1923@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sun, Oct 25, 2015 at 04:18:05PM -0700, Hugh Dickins wrote:
> On Thu, 15 Oct 2015, Andrea Arcangeli wrote:
> 
> > get_mergeable_page() can only return NULL (in case of errors) or the
> > pinned mergeable page. It can't return an error different than
> > NULL. This makes it more readable and less confusion in addition to
> > optimizing the check.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> I share your sentiment, prefer to avoid an unnecessary IS_ERR_OR_NULL.
> And you may be right that it's unnecessary; but that's far from clear
> to me, and you haven't changed the IS_ERR_OR_NULL after follow_page()
> in get_mergeable_page() where it originates, so I wonder if you just
> got confused on this.
> 
> Even if you have established that there's currently no way that
> follow_page(vma, addr, FOLL_GET) could return an -errno on a vma
> validated by find_mergeable_vma(), I think we'd still be better off
> to allow for some future -errno there; but I'd be happy for you to
> keep the change below, but also adjust get_mergeable_page() to
> convert an -errno immediately to NULL after follow_page().
> 
> So, I think this is gently Nacked in its present form,
> but a replacement eagerly Acked.

The "out:" label is followed by page = NULL, so if follow_page returns
an error, get_mergeable_page still cannot return an error.

If this wasn't the case, get_mergeable_page would return an
uninitialized pointer if find_mergeable_vma would return NULL.

I guess the IS_ERR_OR_NULL that I removed, was the direct result of
overlooking the location of the "out:".

If there was a return after the "out:" the readability would have been
improved, but I haven't touched the code around the "out:". That's the
way it was before. Now I'll add a return in this same patch after the
"out:" before resubmitting without 1/6.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
