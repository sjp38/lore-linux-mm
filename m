Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id D387A6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:48:37 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id ho1so3860687wib.4
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:48:37 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id h2si8174553wjz.86.2015.01.16.04.48.37
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 04:48:37 -0800 (PST)
Date: Fri, 16 Jan 2015 14:47:55 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/5] mm: gup: add get_user_pages_locked and
 get_user_pages_unlocked
Message-ID: <20150116124755.GC29085@node.dhcp.inet.fi>
References: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
 <1421167074-9789-2-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421167074-9789-2-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

On Tue, Jan 13, 2015 at 05:37:50PM +0100, Andrea Arcangeli wrote:
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

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
