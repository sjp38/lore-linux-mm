Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E8EF66B025E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 08:44:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y10so4858943wmd.4
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 05:44:47 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p78si881163wmb.225.2017.10.20.05.44.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 20 Oct 2017 05:44:46 -0700 (PDT)
Date: Fri, 20 Oct 2017 14:43:56 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 01/15] sched: convert sighand_struct.count to
 refcount_t
In-Reply-To: <1508501757-15784-2-git-send-email-elena.reshetova@intel.com>
Message-ID: <alpine.DEB.2.20.1710201430420.4531@nanos>
References: <1508501757-15784-1-git-send-email-elena.reshetova@intel.com> <1508501757-15784-2-git-send-email-elena.reshetova@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: mingo@redhat.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, peterz@infradead.org, gregkh@linuxfoundation.org, viro@zeniv.linux.org.uk, tj@kernel.org, hannes@cmpxchg.org, lizefan@huawei.com, acme@kernel.org, alexander.shishkin@linux.intel.com, eparis@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, luto@kernel.org, keescook@chromium.org, dvhart@infradead.org, ebiederm@xmission.com, linux-mm@kvack.org, axboe@kernel.dk

On Fri, 20 Oct 2017, Elena Reshetova wrote:

> atomic_t variables are currently used to implement reference
> counters with the following properties:
>  - counter is initialized to 1 using atomic_set()
>  - a resource is freed upon counter reaching zero
>  - once counter reaches zero, its further
>    increments aren't allowed
>  - counter schema uses basic atomic operations
>    (set, inc, inc_not_zero, dec_and_test, etc.)
> 
> Such atomic variables should be converted to a newly provided
> refcount_t type and API that prevents accidental counter overflows
> and underflows. This is important since overflows and underflows
> can lead to use-after-free situation and be exploitable.
> 
> The variable sighand_struct.count is used as pure reference counter.

This still does not mention that atomic_t != recfcount_t ordering wise and
why you think that this does not matter in that use case.

And looking deeper:

> @@ -1381,7 +1381,7 @@ static int copy_sighand(unsigned long clone_flags, struct task_struct *tsk)
>  	struct sighand_struct *sig;
>  
>  	if (clone_flags & CLONE_SIGHAND) {
> -		atomic_inc(&current->sighand->count);
> +		refcount_inc(&current->sighand->count);
>  		return 0;

>  void __cleanup_sighand(struct sighand_struct *sighand)
>  {
> -	if (atomic_dec_and_test(&sighand->count)) {
> +	if (refcount_dec_and_test(&sighand->count)) {

How did you make sure that these atomic operations have no other
serialization effect and can be replaced with refcount?

I complained about that before and Peter explained it to you in great
length, but you just resend the same thing again. Where is the correctness
analysis? Seriously, for this kind of stuff it's not sufficient to use a
coccinelle script and copy boiler plate change logs and be done with it.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
