Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D4D856B0033
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 05:15:48 -0400 (EDT)
Date: Fri, 12 Jul 2013 11:14:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
Message-ID: <20130712091445.GQ25631@dyad.programming.kicks-ass.net>
References: <1373596462-27115-1-git-send-email-ccross@android.com>
 <1373596462-27115-2-git-send-email-ccross@android.com>
 <51DF9682.9040301@kernel.org>
 <20130712081348.GM25631@dyad.programming.kicks-ass.net>
 <CAOJsxLHEGBdFtnmhDv2AekUhXB00To5JBjsw0t8eFzJPr8eLZQ@mail.gmail.com>
 <20130712085504.GO25631@dyad.programming.kicks-ass.net>
 <51DFC6AE.3020504@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51DFC6AE.3020504@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Colin Cross <ccross@android.com>, LKML <linux-kernel@vger.kernel.org>, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Dave Hansen <dave.hansen@intel.com>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, "list@ebiederm.org:DOCUMENTATION" <linux-doc@vger.kernel.org>, "list@ebiederm.org:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Jul 12, 2013 at 12:04:46PM +0300, Pekka Enberg wrote:
> On 07/12/2013 11:55 AM, Peter Zijlstra wrote:
> >Mmap the file PROT_READ|PROT_WRITE|PROT_EXEC, map the _entire_ file, not just
> >the text section; make the symbol table larger than you expect. Then write the
> >symbol name after you've jit'ed the text but before you use it.
> >
> >IIRC you once told me you never overwrite text but always append new symbols.
> >So you can basically fill the DSO with text/symbols use mmap memory writes.
> 
> I don't but I think Hotspot, for example, does recompile method. Dunno
> if it's a problem really, we could easily come up with a versioning
> scheme for the methods and teach perf to treat the different memory
> regions as the same method.

Anything that overwrites symbols is going to have issues with profiling;
there's really nothing we can do about that.

> On 07/12/2013 11:55 AM, Peter Zijlstra wrote:
> >Once the DSO is full -- equal to your previous anon-exec region being full,
> >you simply mmap a new DSO.
> >
> >Wouldn't that work?
> 
> Okay and then whenever 'perf top' sees a non-mapped IP it reloads the
> DSO (if it has changed)?

I suppose, yeah. There might be a few issues with determining if a mmap()
written file has changed though :/

> Yeah, I could see that working. It doesn't solve the problems Ingo mentioned
> which are also important, though.

Nothing I've yet seen would do that. Its intrinsic to the fact that we want
'anonymous' text tied to a process instance but require part of that text
(symbol information at the very least) to be available after the process
instance.

That are two contradictory requirements. You cannot preserve and not preserve
at the same time.

And pushing the symbol info into the kernel isn't going to fix that either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
