Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5B97390008B
	for <linux-mm@kvack.org>; Wed, 29 Oct 2014 17:58:02 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id h3so2188505igd.8
        for <linux-mm@kvack.org>; Wed, 29 Oct 2014 14:58:02 -0700 (PDT)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id y12si8357148iod.9.2014.10.29.14.58.01
        for <linux-mm@kvack.org>;
        Wed, 29 Oct 2014 14:58:01 -0700 (PDT)
Date: Wed, 29 Oct 2014 16:58:39 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141029215839.GO2979@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <87lho0pf4l.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lho0pf4l.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Tue, Oct 28, 2014 at 05:12:26AM -0700, Andi Kleen wrote:
> Alex Thorlton <athorlton@sgi.com> writes:
> 
> > Last week, while discussing possible fixes for some unexpected/unwanted behavior
> > from khugepaged (see: https://lkml.org/lkml/2014/10/8/515) several people
> > mentioned possibly changing changing khugepaged to work as a task_work function
> > instead of a kernel thread.  This will give us finer grained control over the
> > page collapse scans, eliminate some unnecessary scans since tasks that are
> > relatively inactive will not be scanned often, and eliminate the unwanted
> > behavior described in the email thread I mentioned.
> 
> With your change, what would happen in a single threaded case?
> 
> Previously one core would scan and another would run the workload.
> With your change both scanning and running would be on the same
> core.
> 
> Would seem like a step backwards to me.

I suppose from the single-threaded point of view, it could be.  Maybe we
could look at this a bit differently.  What if we allow processes to
choose their collapse mechanism on fork?  That way, the system could
default to using the standard khugepaged mechanism, but we could request
that processes handle collapses themselves if we want.  Overall, I don't
think that would add too much overhead to what I've already proposed
here, and it gives us more flexibility.

Thoughts?

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
