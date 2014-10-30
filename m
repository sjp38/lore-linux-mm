Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAE890008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 14:25:02 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id at20so2122013iec.31
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 11:25:02 -0700 (PDT)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id j9si12379301igu.52.2014.10.30.11.25.01
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 11:25:01 -0700 (PDT)
Date: Thu, 30 Oct 2014 13:25:42 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141030182542.GB2984@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <87lho0pf4l.fsf@tassilo.jf.intel.com>
 <20141029215839.GO2979@sgi.com>
 <20141030083544.GX12538@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141030083544.GX12538@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Thu, Oct 30, 2014 at 09:35:44AM +0100, Andi Kleen wrote:
> We already have too many VM tunables. Better would be to switch
> automatically somehow.
> 
> I guess you could use some kind of work stealing scheduler, but these
> are fairly complicated. Maybe some simpler heuristics can be found.

That would be a better option in general, but (admittedly not having
thought about it much), I can't think of a good way to determine when to
make that switch.  The main problem being that we're not really seeing a
negative performance impact from khugepaged, but some undesired
behavior, which always exists.

Perhaps we could make a decision based on the number of remote
allocations made by khugepaged?  If we see a lot of allocations to
distant nodes, then maybe we tell khugepaged to stop running scans for a
particular process/mm and let the job handle things itself, either using
the task_work style scan that I've proposed, or just banning khugepaged,
period.  Again, I don't think this is a very good way to make the
decision, but something to think about.

> BTW my thinking has been usually to actually use more khugepageds to 
> scan large address spaces faster.

I hadn't thought of it, but I suppose that is an option as well.  Unless
I've completely missed something in the code, I don't think there's a
way to do this now, right?  Either way, I suppose it wouldn't be too hard
to do, but this still leaves the window wide open for allocations to be
made far away from where the process really needs them.  Maybe if we had
a way to spin up a new khugepaged on the fly, so that users can pin it
where they want it, that would work?  Just brainstorming here...

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
