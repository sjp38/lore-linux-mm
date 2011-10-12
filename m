Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0C3516B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 18:42:04 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p9CMfw1j018614
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:41:59 -0700
Received: from qabg27 (qabg27.prod.google.com [10.224.20.219])
	by wpaz9.hot.corp.google.com with ESMTP id p9CMcprw021419
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:41:57 -0700
Received: by qabg27 with SMTP id g27so2923929qab.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 15:41:57 -0700 (PDT)
Date: Wed, 12 Oct 2011 15:41:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH -v2 -mm] add extra free kbytes tunable
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com>
Message-ID: <alpine.DEB.2.00.1110121537380.16286@chino.kir.corp.google.com>
References: <20110901105208.3849a8ff@annuminas.surriel.com> <20110901100650.6d884589.rdunlap@xenotime.net> <20110901152650.7a63cb8b@annuminas.surriel.com> <alpine.DEB.2.00.1110072001070.13992@chino.kir.corp.google.com> <20111010153723.6397924f.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516CBC4@USINDEVS02.corp.hds.com> <20111011125419.2702b5dc.akpm@linux-foundation.org> <65795E11DBF1E645A09CEC7EAEE94B9CB516CBFE@USINDEVS02.corp.hds.com> <20111011135445.f580749b.akpm@linux-foundation.org>
 <65795E11DBF1E645A09CEC7EAEE94B9CB516D055@USINDEVS02.corp.hds.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Randy Dunlap <rdunlap@xenotime.net>, Satoru Moriya <smoriya@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, Seiji Aguchi <saguchi@redhat.com>, "hughd@google.com" <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, 12 Oct 2011, Satoru Moriya wrote:

> >> Also, if we increase the free-page reserves a.k.a min_free_kbytes, 
> >> the possibility of direct reclaim on other workloads increases.
> >> I think it's a bad side effect.
> > 
> > extra_free_kbytes has the same side-effect.
> 
> I don't think so. If we make low watermark bigger to increase
> free-page reserves by extra_free_kbytes, the possibility of
> direct reclaim on other workload does not increase directly
> because min watermark is not changed. 

I think the point was that extra_free_kbytes needs to be tuned to cover at 
least the amount of memory of the largest allocation burst or it doesn't 
help to prevent latencies for rt threads and, depending on how the 
implementation of the VM evolves, that value may change significantly over 
time from kernel release to kernel release.

For example, if we were to merge Con's patch so kswapd operates at a much 
higher priority for rt threads later on for another issue, it may 
significantly reduce the need for extra_free_kbytes to be set as high as 
it is.  Everybody who is setting this in init scripts, though, will 
continue to set the value because they have no reason to believe it should 
be changed.  Then, we have users who start to use the tunable after Con's 
patch has been merged and now we have widely different settings for the 
same tunable and it can never be obsoleted because everybody is using it 
but for different historic reasons.

This is why I nack'd the patch originally: it will never be removed, it 
is widely misunderstood, and is tied directly to the implementation of 
reclaim which will change over time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
