Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36FD46B03D1
	for <linux-mm@kvack.org>; Fri,  7 Jul 2017 09:50:38 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 188so49996816itx.9
        for <linux-mm@kvack.org>; Fri, 07 Jul 2017 06:50:38 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id d197si3442223itb.138.2017.07.07.06.50.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jul 2017 06:50:37 -0700 (PDT)
Date: Fri, 7 Jul 2017 08:50:33 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: Add SLUB free list pointer obfuscation
In-Reply-To: <CAGXu5jKQJ=9B-uXV-+BB7Y0EQJ_Xpr3OvUHr6c57TceFvNkxbw@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1707070844100.11769@east.gentwo.org>
References: <20170706002718.GA102852@beast> <alpine.DEB.2.20.1707060841170.23867@east.gentwo.org> <CAGXu5jKHkKgF90LXbFvrc3fa2PAaaaYHvCbiBM-9aN16TrHL=g@mail.gmail.com> <alpine.DEB.2.20.1707061052380.26079@east.gentwo.org> <1499363602.26846.3.camel@redhat.com>
 <CAGXu5jKQJ=9B-uXV-+BB7Y0EQJ_Xpr3OvUHr6c57TceFvNkxbw@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Josh Triplett <josh@joshtriplett.org>, Andy Lutomirski <luto@kernel.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Tejun Heo <tj@kernel.org>, Daniel Mack <daniel@zonque.org>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Helge Deller <deller@gmx.de>, Linux-MM <linux-mm@kvack.org>, Tycho Andersen <tycho@docker.com>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On Thu, 6 Jul 2017, Kees Cook wrote:

> Right. This is about blocking the escalation of attack capability. For
> slab object overflow flaws, there are mainly two exploitation methods:
> adjacent allocated object overwrite and adjacent freed object
> overwrite (i.e. a freelist pointer overwrite). The first attack
> depends heavily on which slab cache (and therefore which structures)
> has been exposed by the bug. It's a very narrow and specific attack
> method. The freelist attack is entirely general purpose since it
> provides a reliable way to gain arbitrary write capabilities.
> Protecting against that attack greatly narrows the options for an
> attacker which makes attacks more expensive to create and possibly
> less reliable (and reliability is crucial to successful attacks).


The simplest thing here is to vary the location of the freelist pointer.
That way you cannot hit the freepointer in a deterministic way

The freepointer is put at offset 0 right now. But you could put it
anywhere in the object.

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c
+++ linux/mm/slub.c
@@ -3467,7 +3467,8 @@ static int calculate_sizes(struct kmem_c
 		 */
 		s->offset = size;
 		size += sizeof(void *);
-	}
+	} else
+		s->offset = s->size / sizeof(void *) * <insert random chance logic here>

 #ifdef CONFIG_SLUB_DEBUG
 	if (flags & SLAB_STORE_USER)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
