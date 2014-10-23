Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 504F16B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 15:40:51 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id r5so1154831qcx.40
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:40:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n9si4493056qak.117.2014.10.23.12.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 12:40:50 -0700 (PDT)
Date: Thu, 23 Oct 2014 21:37:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/4] Add pgcollapse controls to task_struct
Message-ID: <20141023193706.GB6751@redhat.com>
References: <1414089963-73165-1-git-send-email-athorlton@sgi.com> <1414089963-73165-3-git-send-email-athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1414089963-73165-3-git-send-email-athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On 10/23, Alex Thorlton wrote:
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1661,6 +1661,18 @@ struct task_struct {
>  	unsigned int	sequential_io;
>  	unsigned int	sequential_io_avg;
>  #endif
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +	struct callback_head pgcollapse_work;
> +	/* default scan 8*512 pte (or vmas) every 30 second */
> +	unsigned int pgcollapse_pages_to_scan;
> +	unsigned int pgcollapse_pages_collapsed;
> +	unsigned int pgcollapse_full_scans;
> +	unsigned int pgcollapse_scan_sleep_millisecs;
> +	/* during fragmentation poll the hugepage allocator once every minute */
> +	unsigned int pgcollapse_alloc_sleep_millisecs;
> +	unsigned long pgcollapse_last_scan;
> +	unsigned long pgcollapse_scan_address;
> +#endif

Shouldn't this all live in mm_struct?

Except pgcollapse_work can't, exit_mm() called before exit_mm(). Probably
it can be allocated.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
