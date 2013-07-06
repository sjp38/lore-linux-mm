Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id B966F6B0033
	for <linux-mm@kvack.org>; Sat,  6 Jul 2013 07:54:38 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1372901537-31033-1-git-send-email-ccross@android.com>
	<87txkaq600.fsf@xmission.com> <51D7BA21.4030105@kernel.org>
Date: Sat, 06 Jul 2013 04:53:47 -0700
In-Reply-To: <51D7BA21.4030105@kernel.org> (Pekka Enberg's message of "Sat, 06
	Jul 2013 09:33:05 +0300")
Message-ID: <87ip0nlx9w.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH] mm: add sys_madvise2 and MADV_NAME to name vmas
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Colin Cross <ccross@android.com>, linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, Rob Landley <rob@landley.net>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rusty Russell <rusty@rustcorp.com.au>, Oleg Nesterov <oleg@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Anton Vorontsov <anton.vorontsov@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, open@ebiederm.org, list@ebiederm.org, DOCUMENTATION <linux-doc@vger.kernel.org>list@ebiederm.org, MEMORY MANAGEMENT <linux-mm@kvack.org>, linux-arch@vger.kernel.org

Pekka Enberg <penberg@kernel.org> writes:

> On 7/4/13 7:54 AM, Eric W. Biederman wrote:
>> How can adding glittler to /proc/<pid>/maps and /proc/<pid>/smaps
>> justify putting a hand break on the linux kernel?
>
> It's not just glitter, it's potentially very useful for making
> perf work nicely with JVM, for example, to know about JIT
> codegen regions and GC regions.

Ah yes.  The old let's make it possible to understand the performance
and behavior by making the bottleneck case even slower.  At least for
variants of GC that use occasionally make have use of mprotect that
seems to be exactly what this patch proposes.

> The implementation seems very heavy-weight though and I'm not
> convinced a new syscall makes sense.

Strongly agreed.  Oleg's idea of a simple integer (that can be though of
as a 4 or 8 byte string) seems much more practical.

What puzzles me is what is the point?  What is gained by putting this
knowledge in the kernel that can not be determend from looking at how
user space has allocated the memory?  The entire concept feels like a
layering violation.  Instead of modifying the malloc in glibc or the jvm
or whatever it is propsed to modify the kernel.

Even after all of the discussion I am still seeing glitter and hand breaks.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
