Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5E1888D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:38:18 -0400 (EDT)
Date: Tue, 29 Mar 2011 17:38:13 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH]mmap: add alignment for some variables
In-Reply-To: <20110329152434.d662706f.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1103291734001.11817@router.home>
References: <1301277536.3981.27.camel@sli10-conroe> <m2oc4v18x8.fsf@firstfloor.org> <1301360054.3981.31.camel@sli10-conroe> <20110329152434.d662706f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, 29 Mar 2011, Andrew Morton wrote:

> > -struct percpu_counter vm_committed_as;
> > +struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;
>
> Why ____cacheline_internodealigned_in_smp?  That's pretty aggressive.
>
> afacit the main benefit from this will occur if the read-only
> vm_committed_as.counters lands in the same cacheline as some
> write-frequently storage.
>
> But that's a complete mad guess and I'd prefer not to have to guess.

It would  be useful to have some functionality that allows us to give
hints as to which variables are accessed together and therefore would be
useful to put in the same cacheline. Thus avoiding things like the
readmostly segment and the above aberration.

Andi had a special pda area in earlier version before the merger of 32 and
64 bit code for x86 that resulted in placement of the most performance
critical variables near one another. I am afraid now they are all spread
out.

So maybe something that allows us to define multiple pdas? Or just structs
that are cacheline aligned?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
