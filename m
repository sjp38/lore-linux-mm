Date: Wed, 4 Feb 2004 14:45:21 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/5] mm improvements
In-Reply-To: <4020BDFF.3010201@cyberone.com.au>
Message-ID: <Pine.LNX.4.44.0402041444560.24515-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; FORMAT=flowed
Content-ID: <Pine.LNX.4.44.0402041444562.24515@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Nick Piggin wrote:

> > 1/5: vm-no-rss-limit.patch
> >     Remove broken RSS limiting. Simple problem, Rik is onto it.
> >

Does the patch below fix the performance problem with the
rss limit patch ?


===== fs/exec.c 1.103 vs edited =====
--- 1.103/fs/exec.c	Mon Jan 19 01:35:50 2004
+++ edited/fs/exec.c	Wed Feb  4 14:38:10 2004
@@ -1117,6 +1117,11 @@
 	retval = init_new_context(current, bprm.mm);
 	if (retval < 0)
 		goto out_mm;
+	if (likely(current->mm)) {
+		bprm.mm->rlimit_rss = current->mm->rlimit_rss;
+	} else {
+		bprm.mm->rlimit_rss = init_mm.rlimit_rss;
+	}
 
 	bprm.argc = count(argv, bprm.p / sizeof(void *));
 	if ((retval = bprm.argc) < 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
