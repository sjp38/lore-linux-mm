Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 21A75900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 11:40:07 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id i13so632551qae.8
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 08:40:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o67si2763021qga.117.2014.10.28.08.40.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Oct 2014 08:40:05 -0700 (PDT)
Message-ID: <544FB8A8.1090402@redhat.com>
Date: Tue, 28 Oct 2014 11:39:20 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com> <87lho0pf4l.fsf@tassilo.jf.intel.com> <544F9302.4010001@redhat.com>
In-Reply-To: <544F9302.4010001@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>, Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On 10/28/2014 08:58 AM, Rik van Riel wrote:
> On 10/28/2014 08:12 AM, Andi Kleen wrote:
>> Alex Thorlton <athorlton@sgi.com> writes:
>>
>>> Last week, while discussing possible fixes for some unexpected/unwanted behavior
>>> from khugepaged (see: https://lkml.org/lkml/2014/10/8/515) several people
>>> mentioned possibly changing changing khugepaged to work as a task_work function
>>> instead of a kernel thread.  This will give us finer grained control over the
>>> page collapse scans, eliminate some unnecessary scans since tasks that are
>>> relatively inactive will not be scanned often, and eliminate the unwanted
>>> behavior described in the email thread I mentioned.
>>
>> With your change, what would happen in a single threaded case?
>>
>> Previously one core would scan and another would run the workload.
>> With your change both scanning and running would be on the same
>> core.
>>
>> Would seem like a step backwards to me.
>
> It's not just scanning, either.
>
> Memory compaction can spend a lot of time waiting on
> locks. Not consuming CPU or anything, but just waiting.
>
> I am not convinced that moving all that waiting to task
> context is a good idea.

It may be worth investigating how the hugepage code calls
the memory allocation & compaction code.

Doing only async compaction from task_work context should
probably be ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
