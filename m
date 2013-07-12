Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 3D80D6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 06:10:40 -0400 (EDT)
Date: Fri, 12 Jul 2013 12:09:33 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712100933.GU25631@dyad.programming.kicks-ass.net>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
 <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <CAOJsxLHEGBdFtnmhDv2AekUhXB00To5JBjsw0t8eFzJPr8eLZQ@mail.gmail.com>
 <20130712085504.GO25631@dyad.programming.kicks-ass.net>
 <51DFC6AE.3020504@kernel.org>
 <20130712092647.GB5315@gmail.com>
 <CAOJsxLGBAKCxbxfxF4NTJh5yDZDOOw_ws_ht2rA7-WvBtw-8Ag@mail.gmail.com>
 <20130712094517.GE5315@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712094517.GE5315@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Jul 12, 2013 at 11:45:17AM +0200, Ingo Molnar wrote:
> One thing where we could help JITs is to offer a direct channel to any 
> perf profiling process: a prctl(SYS_TRACE) which would send a free-form 
> string to any profiling task interested in it.
> 
> This would be a glorified anonymous write() in essence, without using a 
> temporary file.
> 
> The advantage would be that the string could be captured as-is and copied 
> to the ring-buffer of the profiling task - instead of having to recover it 
> later on.
> 
> This is a model that I'd generally advocate: a single channel [per 
> CPU-ified] for instrumentation/tracing.

'free format text string' is long and cumbersome and requires parsing.

And size is the primary component in speed.

But yes, we could allow injection of something like 

struct PERF_RECORD_SYMBOL {
	struct perf_event_header	header;
	u32				pid, tid;
	u64				addr;
	u64				len;
	char				symbol[];
};

I still like the idea of actually writing valid ELF DSOs in that that would
also get us the TEXT and allow assembly inspection etc. It might also allow a
JIT to re-map those DSOs and decrease warm-up time -- provided the actual
program didn't change meanwhile.

How to do injection is another thing though; I don't much like prctl(). Then
again, offering a special file like /sys/bus/event_source/sink isn't
particularly pretty either.

Then there is the issue of attaching to an already running JIT; we'd need means
to 'catch' up. The DSOs trivially allow this; the injection not so much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
