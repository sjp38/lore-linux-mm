Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0B36B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 17:40:06 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n77so271777itn.8
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 14:40:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d140si5699404iof.28.2017.03.28.14.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 14:40:05 -0700 (PDT)
Date: Tue, 28 Mar 2017 14:40:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fault-inject: support systematic fault injection
Message-Id: <20170328144003.b7f7b699f3d22616064e8f7e@linux-foundation.org>
In-Reply-To: <20170328130128.101773-1-dvyukov@google.com>
References: <20170328130128.101773-1-dvyukov@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: akinobu.mita@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 28 Mar 2017 15:01:28 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:

> Add /proc/self/task/<current-tid>/fail-nth file that allows failing
> 0-th, 1-st, 2-nd and so on calls systematically.
> Excerpt from the added documentation:
> 
> ===
> Write to this file of integer N makes N-th call in the current task fail
> (N is 0-based). Read from this file returns a single char 'Y' or 'N'
> that says if the fault setup with a previous write to this file was
> injected or not, and disables the fault if it wasn't yet injected.
> Note that this file enables all types of faults (slab, futex, etc).
> This setting takes precedence over all other generic settings like
> probability, interval, times, etc. But per-capability settings
> (e.g. fail_futex/ignore-private) take precedence over it.
> This feature is intended for systematic testing of faults in a single
> system call. See an example below.
> ===
> 
> Why adding new setting:
> 1. Existing settings are global rather than per-task.
>    So parallel testing is not possible.
> 2. attr->interval is close but it depends on attr->count
>    which is non reset to 0, so interval does not work as expected.
> 3. Trying to model this with existing settings requires manipulations
>    of all of probability, interval, times, space, task-filter and
>    unexposed count and per-task make-it-fail files.
> 4. Existing settings are per-failure-type, and the set of failure
>    types is potentially expanding.
> 5. make-it-fail can't be changed by unprivileged user and aggressive
>    stress testing better be done from an unprivileged user.
>    Similarly, this would require opening the debugfs files to the
>    unprivileged user, as he would need to reopen at least times file
>    (not possible to pre-open before dropping privs).
> 
> The proposed interface solves all of the above (see the example).

Seems reasonable.

> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1897,6 +1897,7 @@ struct task_struct {
>  #endif
>  #ifdef CONFIG_FAULT_INJECTION
>  	int make_it_fail;
> +	int fail_nth;
>  #endif

Nit: fail_nth should really be unsigned.  And make_it_fail could be
made a single bit which shares storage with brk_randomized (for
example).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
