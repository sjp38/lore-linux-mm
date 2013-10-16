Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B053E6B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 16:42:01 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id q10so709508pdj.28
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 13:42:01 -0700 (PDT)
Received: by mail-ob0-f173.google.com with SMTP id vb8so1117051obc.32
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 13:41:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <525EF85A.6050302@intel.com>
References: <1381800678-16515-1-git-send-email-ccross@android.com>
	<1381800678-16515-2-git-send-email-ccross@android.com>
	<20131016003347.GC13007@bbox>
	<CAMbhsRTe9Vwa-zrebuKeJKpy-AhsSeiFD5nKU_-sNd2G2D-+og@mail.gmail.com>
	<525EF85A.6050302@intel.com>
Date: Wed, 16 Oct 2013 13:41:57 -0700
Message-ID: <CAMbhsRQWM0o2wf_gT30gE37nnTKbvPR9RUZDuM_oDxnAxGij6w@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Colin Cross <ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, lkml <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Jan Glauber <jan.glauber@gmail.com>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, Kees Cook <keescook@chromium.org>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, David Rientjes <rientjes@google.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Tang Chen <tangchen@cn.fujitsu.com>, Robin Holt <holt@sgi.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "open list:DOCUMENTATION <linux-doc@vger.kernel.org>, open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Wed, Oct 16, 2013 at 1:34 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 10/16/2013 01:00 PM, Colin Cross wrote:
>>> > I guess this feature would be used with allocators tightly
>>> > so my concern of kernel approach like this that it needs mmap_sem
>>> > write-side lock to split/merge vmas which is really thing
>>> > allocators(ex, tcmalloc, jemalloc) want to avoid for performance win
>>> > that allocators have lots of complicated logic to avoid munmap which
>>> > needs mmap_sem write-side lock but this feature would make it invalid.
>> My expected use case is that the allocator will mmap a new large chunk
>> of anonymous memory, and then immediately name it, resulting in taking
>> the mmap_sem twice in a row.
>
> I guess the prctl (or a new one) _could_ just set a kernel-internal
> variable (per-thread?) that says "point any future anonymous areas at
> this name".  That way, you at least have the _possibility_ of not having
> to do it for _every_ mmap().

That won't work for multiple allocators.  A thread can easily allocate
through Java, then call into native code and allocate through malloc,
and those will need different names.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
