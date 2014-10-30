Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id C3BF590008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:15:15 -0400 (EDT)
Received: by mail-la0-f47.google.com with SMTP id gd6so3144033lab.34
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 05:15:14 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.194])
        by mx.google.com with ESMTP id cj6si11735214lad.78.2014.10.30.05.15.11
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 05:15:12 -0700 (PDT)
Date: Thu, 30 Oct 2014 14:14:25 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/5] mm: gup: add get_user_pages_locked and
 get_user_pages_unlocked
Message-ID: <20141030121425.GA31134@node.dhcp.inet.fi>
References: <1414600520-7664-1-git-send-email-aarcange@redhat.com>
 <1414600520-7664-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414600520-7664-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Wed, Oct 29, 2014 at 05:35:16PM +0100, Andrea Arcangeli wrote:
> We can leverage the VM_FAULT_RETRY functionality in the page fault
> paths better by using either get_user_pages_locked or
> get_user_pages_unlocked.
> 
> The former allow conversion of get_user_pages invocations that will
> have to pass a "&locked" parameter to know if the mmap_sem was dropped
> during the call. Example from:
> 
>     down_read(&mm->mmap_sem);
>     do_something()
>     get_user_pages(tsk, mm, ..., pages, NULL);
>     up_read(&mm->mmap_sem);
> 
> to:
> 
>     int locked = 1;
>     down_read(&mm->mmap_sem);
>     do_something()
>     get_user_pages_locked(tsk, mm, ..., pages, &locked);
>     if (locked)
>         up_read(&mm->mmap_sem);
> 
> The latter is suitable only as a drop in replacement of the form:
> 
>     down_read(&mm->mmap_sem);
>     get_user_pages(tsk, mm, ..., pages, NULL);
>     up_read(&mm->mmap_sem);
> 
> into:
> 
>     get_user_pages_unlocked(tsk, mm, ..., pages);
> 
> Where tsk, mm, the intermediate "..." paramters and "pages" can be any
> value as before. Just the last parameter of get_user_pages (vmas) must
> be NULL for get_user_pages_locked|unlocked to be usable (the latter
> original form wouldn't have been safe anyway if vmas wasn't null, for
> the former we just make it explicit by dropping the parameter).
> 
> If vmas is not NULL these two methods cannot be used.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>
> Reviewed-by: Peter Feiner <pfeiner@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
