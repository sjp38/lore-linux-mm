Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id B63D46B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 09:39:40 -0500 (EST)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH] Ensure that walk_page_range()'s start and end are page-aligned
References: <1328902796-30389-1-git-send-email-danms@us.ibm.com>
	<alpine.DEB.2.00.1202130211400.4324@chino.kir.corp.google.com>
	<87zkcm23az.fsf@caffeine.danplanet.com>
	<alpine.DEB.2.00.1202131350500.17296@chino.kir.corp.google.com>
	<87pqdh1mvs.fsf@caffeine.danplanet.com>
	<alpine.DEB.2.00.1202141259420.28450@chino.kir.corp.google.com>
Date: Wed, 15 Feb 2012 06:39:37 -0800
In-Reply-To: <alpine.DEB.2.00.1202141259420.28450@chino.kir.corp.google.com>
	(David Rientjes's message of "Tue, 14 Feb 2012 13:04:45 -0800 (PST)")
Message-ID: <87lio417py.fsf@caffeine.danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

DR> And do what if they're not?  What behavior are you trying to fix
DR> from the pagewalk code with respect to page-aligned addresses?  Any
DR> specific examples?

Sorry, I thought I detailed this in the patch header.

In walk_pte_entry(), the exit condition is when the end address is equal
to the start address + n*PAGE_SIZE. If they're not both page aligned,
then we'll never exit the loop and we'll start handing bad pte entries
to the handler function.

As was pointed out earlier in the thread, we could "solve" this by
making the exit condition be > instead of ==. However, that changes the
entirety of walk_page_range() from requiring page-aligned attributes to
silently tolerating them. IMHO, it's better to just
declare/check/enforce that they are.

I hit this recently because I was working with a prototype syscall that
took an address range from userspace and walked the pages. I ended up
passing non-page-aligned addresses, not knowing that walk_page_range()
needed it, and it took me a few days to figure out why my pte_entry
handler got a few good entries and then garbage until I crashed. I
turned on DEBUG_VM and got zero additional help. With the proposed
patch, I would have received a helpful smack in the head.

Does that make sense?

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
