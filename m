Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id F255B900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 09:02:00 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id a108so400578qge.25
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 06:02:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i7si2203428qan.31.2014.10.28.06.01.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 06:01:59 -0700 (PDT)
Message-ID: <544F9302.4010001@redhat.com>
Date: Tue, 28 Oct 2014 08:58:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com> <87lho0pf4l.fsf@tassilo.jf.intel.com>
In-Reply-To: <87lho0pf4l.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On 10/28/2014 08:12 AM, Andi Kleen wrote:
> Alex Thorlton <athorlton@sgi.com> writes:
> 
>> Last week, while discussing possible fixes for some unexpected/unwanted behavior
>> from khugepaged (see: https://lkml.org/lkml/2014/10/8/515) several people
>> mentioned possibly changing changing khugepaged to work as a task_work function
>> instead of a kernel thread.  This will give us finer grained control over the
>> page collapse scans, eliminate some unnecessary scans since tasks that are
>> relatively inactive will not be scanned often, and eliminate the unwanted
>> behavior described in the email thread I mentioned.
> 
> With your change, what would happen in a single threaded case?
> 
> Previously one core would scan and another would run the workload.
> With your change both scanning and running would be on the same
> core.
> 
> Would seem like a step backwards to me.

It's not just scanning, either.

Memory compaction can spend a lot of time waiting on
locks. Not consuming CPU or anything, but just waiting.

I am not convinced that moving all that waiting to task
context is a good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
