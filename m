Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 298F56B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 20:25:57 -0400 (EDT)
Date: Tue, 24 Apr 2012 17:25:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
Message-Id: <20120424172554.c9c330dd.akpm@linux-foundation.org>
In-Reply-To: <4F973FB8.6050103@jp.fujitsu.com>
References: <1335171318-4838-1-git-send-email-minchan@kernel.org>
	<4F963742.2030607@jp.fujitsu.com>
	<4F963B8E.9030105@kernel.org>
	<CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com>
	<4F965413.9010305@kernel.org>
	<CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com>
	<20120424143015.99fd8d4a.akpm@linux-foundation.org>
	<4F973BF2.4080406@jp.fujitsu.com>
	<CAHGf_=r09BCxXeuE8dSti4_SrT5yahrQCwJh=NrrA3rsUhhu_w@mail.gmail.com>
	<4F973FB8.6050103@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@gmail.com>, Minchan Kim <minchan@kernel.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Apr 2012 09:05:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> (2012/04/25 8:55), KOSAKI Motohiro wrote:
> 
> > On Tue, Apr 24, 2012 at 7:49 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> (2012/04/25 6:30), Andrew Morton wrote:
> >>
> >>> On Tue, 24 Apr 2012 17:48:29 +1000
> >>> Nick Piggin <npiggin@gmail.com> wrote:
> >>>
> >>>>> Hmm, there are several places to use GFP_NOIO and GFP_NOFS even, GFP_ATOMIC.
> >>>>> I believe it's not trivial now.
> >>>>
> >>>> They're all buggy then. Unfortunately not through any real fault of their own.
> >>>
> >>> There are gruesome problems in block/blk-throttle.c (thread "mempool,
> >>> percpu, blkcg: fix percpu stat allocation and remove stats_lock").  It
> >>> wants to do an alloc_percpu()->vmalloc() from the IO submission path,
> >>> under GFP_NOIO.
> >>>
> >>> Changing vmalloc() to take a gfp_t does make lots of sense, although I
> >>> worry a bit about making vmalloc() easier to use!
> >>>
> >>> I do wonder whether the whole scheme of explicitly passing a gfp_t was
> >>> a mistake and that the allocation context should be part of the task
> >>> context.  ie: pass the allocation mode via *current.
> >>
> >> yes...that's very interesting.
> > 
> > I think GFP_ATOMIC is used non task context too. ;-)
> 
> Hmm, in interrupt context or some ? Can't we detect it ?

There are lots of practical details and I haven't begun to think it
through, mainly because it Isn't Going To Happen!

For example how do we handle spin_lock()?  Does spin_lock() now do

gfp_t spin_lock_2(spinlock_t *lock)
{
	gfp_t old_gfp = set_current_gfp(GFP_ATOMIC);
	spin_lock(lock);
	return old_gfp;
}

void spin_unlock_2(spinlock_t *lock, gfp_t old_gfp)
{
	spin_unlock(lock);
	set_current_gfp(old_gfp);
}

Well that's bad.  Currently we require programmers to keep track of
what context they're running in.  So they think about what they're
doing.  If we made it this easy, we'd see a big proliferation of
GFP_ATOMIC allocations, which is bad.

Requiring the spin_lock() caller to run set_current_gfp() would have
the same effect.



Or do we instead do this:

-	some_function(foo, bar, GFP_NOIO);
+	old_gfp = set_current_gfp(GFP_NOIO);
+	some_function(foo, bar);
+	set_current_gfp(old_gfp);

So the rule is "if the code was using an explicit GFP_foo then convert
it to use set_current_gfp().  If the code was receiving a gfp_t
variable from the caller then delete that arg".

Or something like that.  It's all too hopelessly impractical to bother
discussing - 20 years too late!


otoh, maybe a constrained version of this could be used to address the
vmalloc() problem alone.


otoh2, I didn't *want* blk-throttle.c to use GFP_NOIO for vmalloc(). 
GFP_NOIO is weak, unreliable and lame.  blk-throttle should find a way
of using GFP_KERNEL!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
