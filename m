Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id E863E6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 06:01:36 -0400 (EDT)
Received: by mail-ee0-f41.google.com with SMTP id d17so6067675eek.14
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 03:01:35 -0700 (PDT)
Date: Fri, 12 Jul 2013 12:01:30 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712100130.GA12813@gmail.com>
References: <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <20130712081717.GN25631@dyad.programming.kicks-ass.net>
 <20130712084406.GB4328@gmail.com>
 <20130712090046.GP25631@dyad.programming.kicks-ass.net>
 <20130712091506.GA5315@gmail.com>
 <20130712092707.GR25631@dyad.programming.kicks-ass.net>
 <20130712094044.GD5315@gmail.com>
 <20130712094957.GS25631@dyad.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130712094957.GS25631@dyad.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Fri, Jul 12, 2013 at 11:40:44AM +0200, Ingo Molnar wrote:
> > * Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Fri, Jul 12, 2013 at 11:15:06AM +0200, Ingo Molnar wrote:
> > > > 
> > > > * Peter Zijlstra <peterz@infradead.org> wrote:
> > > > 
> > > > > We need those files anyway.. The current proposal is that the entire VMA 
> > > > > has a single userspace pointer in it. Or rather a 64bit value.
> > > > 
> > > > Yes but accessible via /proc/<PID>/mem or so?
> > > 
> > > *shudder*.. yes. But you're again opening two files. The only advantage 
> > > of this over userspace writing its own files is that the kernel cleans 
> > > things up for you.
> > 
> > Opening of the files only occurs in the instrumentation case, which is 
> > rare. But temporary files would be forced upon the regular usecase 
> > when no instrumentation goes on.
> 
> Well, Colin didn't describe the intended use, but I can imagine a case 
> where its not all that rare. System health monitors might frequently 
> want to update this.

That's true.

So maybe it would be better to offer a tracepoint that allows apps to emit 
such information - to any system monitor around to listen.

If it's made a vsyscall that does not enter the kernel if the process is 
not being monitored would make it very low overhead.

> > So, these 400+ memory ranges are from Firefox's /proc/*/maps file:
> > 
> <snip>
> > 
> > It's about 35% out of 1300+ mappings that Firefox uses.
> > 
> > It is likely that the ---p mappings (about 40 of them) are guard pages.
> > 
> > How do I tell what the remaining anonymous areas are about?
> 
> Well, if you'd ran it within a memory allocator debug framework that 
> would have kept track of this. Typically memory debuggers can keep 
> allocation time stacks etc.
> 
> If I'm not actively debugging firefox I don't give a damn.

Yet people are nosy and find it rather useful to have such 
'heap/stack/vdso/vsyscall' annotations:

 0237c000-0239d000 rw-p 00000000 00:00 0                                  [heap]
 ...
 7fff622af000-7fff622d0000 rw-p 00000000 00:00 0                          [stack]
 7fff623fe000-7fff62400000 r-xp 00000000 00:00 0                          [vdso]
 ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]

and named vmas have names as well:

 7fa5b02eb000-7fa5b6718000 r--p 00000000 08:03 1710237                    /usr/lib/locale/locale-archive

so why not allow some simple mechanism to descriptively name anonymous 
vmas as well?

Maybe the 8 bytes shouldn't be a pointer to user-space memory, but a short 
string, a bit like task_struct:comm[16]?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
