Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 777F86B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:50:56 -0400 (EDT)
Date: Fri, 12 Jul 2013 11:49:57 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712094957.GS25631@dyad.programming.kicks-ass.net>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
 <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <20130712081717.GN25631@dyad.programming.kicks-ass.net>
 <20130712084406.GB4328@gmail.com>
 <20130712090046.GP25631@dyad.programming.kicks-ass.net>
 <20130712091506.GA5315@gmail.com>
 <20130712092707.GR25631@dyad.programming.kicks-ass.net>
 <20130712094044.GD5315@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712094044.GD5315@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Pekka Enberg <penberg@kernel.org>, Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Fri, Jul 12, 2013 at 11:40:44AM +0200, Ingo Molnar wrote:
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Fri, Jul 12, 2013 at 11:15:06AM +0200, Ingo Molnar wrote:
> > > 
> > > * Peter Zijlstra <peterz@infradead.org> wrote:
> > > 
> > > > We need those files anyway.. The current proposal is that the entire VMA 
> > > > has a single userspace pointer in it. Or rather a 64bit value.
> > > 
> > > Yes but accessible via /proc/<PID>/mem or so?
> > 
> > *shudder*.. yes. But you're again opening two files. The only advantage 
> > of this over userspace writing its own files is that the kernel cleans 
> > things up for you.
> 
> Opening of the files only occurs in the instrumentation case, which is 
> rare. But temporary files would be forced upon the regular usecase when no 
> instrumentation goes on.

Well, Colin didn't describe the intended use, but I can imagine a case where
its not all that rare. System health monitors might frequently want to update
this.

> > However from what I understood android runs apps as individual users, 
> > and I think we can do per user tmpfs mounts. So app dies, user exits, 
> > mount goes *poof*.
> 
> Yes, user-space could be smarter about temporary files.
> 
> Just like big banks could be less risk happy.
> 
> Yet the reality is that if left alone both apps and banks mess up, I don't 
> think libertarianism works for policy: we are better off offering a 
> framework that is simple, robust, self-contained, low risk and hard to 
> mess up?

Fair enough; but I still want Colin to tell me why he can't do this in
userspace. And what all he wants to go do with this information etc.

He's basically not told us much at all.

> So, these 400+ memory ranges are from Firefox's /proc/*/maps file:
> 
<snip>
> 
> It's about 35% out of 1300+ mappings that Firefox uses.
> 
> It is likely that the ---p mappings (about 40 of them) are guard pages.
> 
> How do I tell what the remaining anonymous areas are about?

Well, if you'd ran it within a memory allocator debug framework that would have
kept track of this. Typically memory debuggers can keep allocation time stacks
etc.

If I'm not actively debugging firefox I don't give a damn.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
