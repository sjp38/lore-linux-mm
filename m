Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5AC0A6B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 20:00:35 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id jh10so1168853pab.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 17:00:34 -0700 (PDT)
Date: Wed, 3 Apr 2013 17:00:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] compiler: clarify ACCESS_ONCE() relies on compiler
 implementation
In-Reply-To: <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1304031659160.718@chino.kir.corp.google.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com> <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com> <alpine.LNX.2.00.1304021600420.22412@eggly.anvils> <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org> <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com> <20130403045814.GD4611@cmpxchg.org> <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com> <20130403143302.GL1953@cmpxchg.org>
 <alpine.DEB.2.02.1304031648170.718@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Ian Lance Taylor <iant@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

The dereference of a volatile-qualified pointer does not guarantee that it
cannot be optimized by the compiler to be loaded multiple times into
memory even if assigned to a local variable by C99 or any previous C
standard.

Clarify the comment of ACCESS_ONCE() to state explicitly that its current
form relies on the compiler's implementation to work correctly.

Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/compiler.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/compiler.h b/include/linux/compiler.h
--- a/include/linux/compiler.h
+++ b/include/linux/compiler.h
@@ -348,6 +348,15 @@ void ftrace_likely_update(struct ftrace_branch_data *f, int val, int expect);
  * merging, or refetching absolutely anything at any time.  Its main intended
  * use is to mediate communication between process-level code and irq/NMI
  * handlers, all running on the same CPU.
+ *
+ * The current implementation of ACCESS_ONCE() works in all mainstream C
+ * compilers (including of course gcc), but is not guaranteed by the C standard.
+ * However, there is a lot of software that depends on the semantics of volatile
+ * casts, so we have good reason to believe that there will always be a way of
+ * implementing ACCESS_ONCE().  The implementation of ACCESS_ONCE() might well
+ * change to track the C standard and the mainstream C compilers, so if you copy
+ * this definition into some other code base, be sure to check back here
+ * periodically for changes.
  */
 #define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
