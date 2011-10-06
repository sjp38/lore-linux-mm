Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 21E936B002F
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 12:27:40 -0400 (EDT)
Message-ID: <4E8DD5B9.4060905@parallels.com>
Date: Thu, 06 Oct 2011 20:22:17 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 0/5] Slab objects identifiers
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
Cc: Glauber Costa <glommer@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>

Hi.


While doing the checkpoint-restore in the userspace we need to determine
whether various kernel objects (like mm_struct-s of file_struct-s) are shared
between tasks and restore this state.

The 2nd step can for now be solved by using respective CLONE_XXX flags and
the unshare syscall, while there's currently no ways for solving the 1st one.

One of the ways for checking whether two tasks share e.g. an mm_struct is to
provide some mm_struct ID of a task to its proc file. The best from the
performance point of view ID is the object address in the kernel, but showing
them to the userspace is not good for performance reasons. Thus the ID should
not be calculated based on the object address.

The proposal is to have the ID for slab objects as the mixture of two things -
the number of an object on the slub and the ID of a slab, which is calculated
simply by getting a monotonic 64 bit number at the slab allocation time which
gives us 200+ years of stable work (see comment in the patch #2) :)


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
