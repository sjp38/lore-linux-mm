Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 615366B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:38:47 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa11so8809619pad.19
        for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130712092647.GB5315@gmail.com>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
	<1373596462-27115-2-git-send-email-ccross@android.com>
	<51DF9682.9040301@kernel.org>
	<20130712081348.GM25631@dyad.programming.kicks-ass.net>
	<CAOJsxLHEGBdFtnmhDv2AekUhXB00To5JBjsw0t8eFzJPr8eLZQ@mail.gmail.com>
	<20130712085504.GO25631@dyad.programming.kicks-ass.net>
	<51DFC6AE.3020504@kernel.org>
	<20130712092647.GB5315@gmail.com>
Date: Fri, 12 Jul 2013 12:38:46 +0300
Message-ID: <CAOJsxLGBAKCxbxfxF4NTJh5yDZDOOw_ws_ht2rA7-WvBtw-8Ag@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous memory
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Jul 12, 2013 at 12:26 PM, Ingo Molnar <mingo@kernel.org> wrote:
> Well, the JIT profiling case is really special - there we are constructing
> code and a symbol table on the fly. Talking to perf via a temporary file
> sounds unavoidable (and thus proper), because symbol information on that
> level is not something the kernel knows (or should know) about.
>
> I was arguing primarily in the context of the original patch: naming
> allocator heaps. Today the kernel makes a few educated guesses about what
> each memory area is about, in /proc/*/maps:
>
>  34511ac000-34511b0000 r--p 001ac000 08:03 1706770                        /usr/lib64/libc-2.15.so
>  34511b0000-34511b2000 rw-p 001b0000 08:03 1706770                        /usr/lib64/libc-2.15.so
>  34511b2000-34511b7000 rw-p 00000000 00:00 0
>  7f5bdff94000-7f5be63c1000 r--p 00000000 08:03 1710237                    /usr/lib/locale/locale-archive
>  7f5be63c1000-7f5be63c4000 rw-p 00000000 00:00 0
>  7f5be63d6000-7f5be63d7000 rw-p 00000000 00:00 0
>  7fff7677f000-7fff767a0000 rw-p 00000000 00:00 0                          [stack]
>  7fff767dd000-7fff767df000 r-xp 00000000 00:00 0                          [vdso]
>  ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
>
> ... but on any larger app there's lots of anon mmap areas that are ...
> anonymous! ;-) User-space could help out a bit by naming them. It's not
> like there's many heaps, so the performance overhead aspect is minimal.
>
> In the JIT case we have something different, a 'file IO' abstraction
> really: the JIT is generating (writing) new code and associated symbol
> records. So using temporary files there is natural and proper and most of
> the disadvantages I list don't apply because the sheer volume of new code
> generated dillutes the overhead of open()/close(), plus we do need some
> space for those symbols so a JIT cannot really expect to be able to run in
> a pure readonly environment.
>
> In the allocator/heap case we have a _memory_ abstraction it's just that
> we also want to name the heap minimally.
>
> For any finer than vma granularity user-space attributes the kernel cannot
> help much, it does not know (and probably should not know) about all
> user-space data structures.
>
> Right now I don't see any good way to merge the two. (might be due to lack
> of imagination)

I have no trouble with the imagination part but you make a strong point about
the kernel not helping at finer granularity than vma anyway.

The current functionality is already quite helpful for VMs as well. We could
annotate the different GC and JIT regions and make perf more human-friendly
by default.

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
