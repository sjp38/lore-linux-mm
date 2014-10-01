Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1DDD96B006E
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 11:52:04 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so434342pde.34
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:52:03 -0700 (PDT)
Received: from mail-pa0-x24a.google.com (mail-pa0-x24a.google.com [2607:f8b0:400e:c03::24a])
        by mx.google.com with ESMTPS id b5si1142797pdb.199.2014.10.01.08.52.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 08:52:02 -0700 (PDT)
Received: by mail-pa0-f74.google.com with SMTP id kq14so15246pab.1
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:52:01 -0700 (PDT)
Date: Wed, 1 Oct 2014 08:51:59 -0700
From: Peter Feiner <pfeiner@google.com>
Subject: Re: [PATCH 2/4] mm: gup: add get_user_pages_locked and
 get_user_pages_unlocked
Message-ID: <20141001155159.GA7019@google.com>
References: <1412153797-6667-1-git-send-email-aarcange@redhat.com>
 <1412153797-6667-3-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1412153797-6667-3-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andres Lagar-Cavilla <andreslc@google.com>, Gleb Natapov <gleb@kernel.org>, Radim Krcmar <rkrcmar@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Jianyu Zhan <nasa4836@gmail.com>, Paul Cassella <cassella@cray.com>, Hugh Dickins <hughd@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>

On Wed, Oct 01, 2014 at 10:56:35AM +0200, Andrea Arcangeli wrote:
> +static inline long __get_user_pages_locked(struct task_struct *tsk,
> +					   struct mm_struct *mm,
> +					   unsigned long start,
> +					   unsigned long nr_pages,
> +					   int write, int force,
> +					   struct page **pages,
> +					   struct vm_area_struct **vmas,
> +					   int *locked,
> +					   bool notify_drop)
> +{
> +	int flags = FOLL_TOUCH;
> +	long ret, pages_done;
> +	bool lock_dropped;
> +
> +	if (locked) {
> +		/* if VM_FAULT_RETRY can be returned, vmas become invalid */
> +		BUG_ON(vmas);
> +		/* check caller initialized locked */
> +		BUG_ON(*locked != 1);
> +	}
> +
> +	if (pages)
> +		flags |= FOLL_GET;
> +	if (write)
> +		flags |= FOLL_WRITE;
> +	if (force)
> +		flags |= FOLL_FORCE;
> +
> +	pages_done = 0;
> +	lock_dropped = false;
> +	for (;;) {
> +		ret = __get_user_pages(tsk, mm, start, nr_pages, flags, pages,
> +				       vmas, locked);
> +		if (!locked)
> +			/* VM_FAULT_RETRY couldn't trigger, bypass */
> +			return ret;
> +
> +		/* VM_FAULT_RETRY cannot return errors */
> +		if (!*locked) {
> +			BUG_ON(ret < 0);
> +			BUG_ON(nr_pages == 1 && ret);

If I understand correctly, this second BUG_ON is asserting that when
__get_user_pages is asked for a single page and it is successfully gets the
page, then it shouldn't have dropped the mmap_sem. If that's the case, then
you could generalize this assertion to

			BUG_ON(nr_pages == ret);

Otherwise, looks good!

Peter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
