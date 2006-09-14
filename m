Subject: [RFC] page fault retry with NOPAGE_RETRY
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Content-Type: text/plain
Date: Fri, 15 Sep 2006 08:55:08 +1000
Message-Id: <1158274508.14473.88.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

Hi !

While tracking some issues with mapping of SPEs on Cell into userland
processes, I figured out that we have a problem that can be solved with
a small generic change (which might be useful for other situations as
well).

Basically, when a user tries to access some mmap'ed SPE registers, the
no_page() function for those tries to schedule in a physial SPE the
virtual SPE context of that user. For that, it needs to wait for an SPE
to become available, which can take some time, and with the current SPE
scheduler, can take a long time indeed.

This wait is interruptible. However, we have no way to fail "gracefully"
from no_page() if the routine we use underneath returns a failure due to
a signal (we use, logically, -EINTR). It's a generic issue with no_page
handlers. They can either wait non-interruptibly, or fail with a sigbus
or oom result.

However, it would be trivial to add the ability for no_page() to fail in
such a way that execution just comes back all the way to userland (and
thus pending signals are delivered), and the faulting instruction is
simply taken again. All we need is something like:

in mm.h:

 #define NOPAGE_SIGBUS   (NULL)
 #define NOPAGE_OOM      ((struct page *) (-1))
+#define NOPAGE_RETRY	((struct page *) (-2))

and in memory.c, in do_no_page():


        /* no page was available -- either SIGBUS or OOM */
        if (new_page == NOPAGE_SIGBUS)
                return VM_FAULT_SIGBUS;
        if (new_page == NOPAGE_OOM)
                return VM_FAULT_OOM;
+       if (new_page == NOPAGE_RETRY)
+               return VM_FAULT_MINOR;

In fact, it would be nicer to turn the whole serie into -one- if
(unlikely(something wrong)) and inside that if, a switch case of fault
codes. That would probably make the code better than what it is today
and allow for adding error cases without performance harm to the fast
path. I'll provide a patch doing that if there is no strong disagreement
with the approach.

With the above change, a no_page() handler can just return NOPAGE_RETRY
(for example if it was waiting on availability of a hardware resource
and a signal got detected) and this will simply be counted as a minor
fault. I've looked at the callers of handle_mm_fault() on a couple of
archs and it seems that the approach will work though I haven't looked
at all of them yet (though at this point, I only plan to use that for
PowerPC SPE code anyway).

Somebody pointed to me that this might also be used to shoot another
bird, though I have not really though about it and wether it's good or
bad, which is the old problem of needing struct page for things that can
be mmap'ed. Using that trick, a driver could do the set_pte() itself in
the no_page handler and return NOPAGE_RETRY. I'm not sure about
advertising that feature though as I like all  callers of things like
set_pte() to be in well known locations, as there are various issues
related to manipulating the page tables that driver writers might not
get right. Though I suppose that if we consider the approach good, we
can provide a helper that "does the right thing" as well (like calling
update_mmu_cache(), flush_tlb_whatever(), etc...).

Any comment ? If it's ok, I'll cook a patch candidate for 2.6.19 along
with the matching change to spufs to make use of it.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
