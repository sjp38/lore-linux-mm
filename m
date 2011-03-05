Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 125EF8D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 19:13:33 -0500 (EST)
Date: Sat, 5 Mar 2011 11:25:08 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
Message-ID: <20110305162508.GA11120@thunk.org>
References: <AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
 <1299270709.3062.313.camel@calx>
 <1299271377.2071.1406.camel@dan>
 <AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
 <1299272907.2071.1415.camel@dan>
 <AANLkTina+O77BFV+7mO9fX2aJimpO0ov_MKwxGtMwqG+@mail.gmail.com>
 <1299275042.2071.1422.camel@dan>
 <AANLkTikA=88EMs8RRm0RPQ+Q9nKj=2G+G86h5nCnV7Se@mail.gmail.com>
 <AANLkTikQxOgYFLbc2KbEKgRYL1RCnkPE-T80-GBY2Cgj@mail.gmail.com>
 <1299279756.3062.361.camel@calx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1299279756.3062.361.camel@calx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Pekka Enberg <penberg@kernel.org>, Dan Rosenberg <drosenberg@vsecurity.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Mar 04, 2011 at 05:02:36PM -0600, Matt Mackall wrote:
> copies too many bytes from userspace. Every piece of code writes its own
> bound checks on copy_from_user, for instance, and gets it wrong by
> hitting signed/unsigned issues, alignment issues, etc. that are on the
> very edge of the average C coder's awareness.

Agreed.  Maybe something that would help is to have helper routines
which handle the most common patterns that driver writers need.  Some
of the most common that I've seen from doing a quick survey are:

1) kmalloc() followed by copy_from_user()
2) kmem_cache_alloc() followed by copy_from_user()
3) copy_from_user() to a buffer allocated on the stack, where the length
   is passed in from userspace, and the maximum expected input size is
   declared by the driver.  (Used by debugfs, proc, and sysfs handlers)
4) copy_from_user() to a structure allocated on the stack

If we had wrappers for the most common cases, then any cases that were
left that used copy_from_user() explicitly could be flagged and
checked by hand, since they would be exception, and not the rule.

	   	       	    	     		- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
