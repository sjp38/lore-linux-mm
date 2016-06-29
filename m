Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B85F828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 18:37:00 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g62so133638031pfb.3
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 15:37:00 -0700 (PDT)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id c63si604557pfa.138.2016.06.29.15.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 15:36:59 -0700 (PDT)
Date: Wed, 29 Jun 2016 15:37:00 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when
 terminating freeing scanner
Message-ID: <20160629223700.GA26264@kroah.com>
References: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1606291436300.145590@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, minchan@kernel.org, stable@vger.kernel.org, vbabka@suse.cz

On Wed, Jun 29, 2016 at 02:47:20PM -0700, David Rientjes wrote:
> It's possible to isolate some freepages in a pageblock and then fail 
> split_free_page() due to the low watermark check.  In this case, we hit 
> VM_BUG_ON() because the freeing scanner terminated early without a 
> contended lock or enough freepages.
> 
> This should never have been a VM_BUG_ON() since it's not a fatal 
> condition.  It should have been a VM_WARN_ON() at best, or even handled 
> gracefully.
> 
> Regardless, we need to terminate anytime the full pageblock scan was not 
> done.  The logic belongs in isolate_freepages_block(), so handle its state
> gracefully by terminating the pageblock loop and making a note to restart 
> at the same pageblock next time since it was not possible to complete the 
> scan this time.
> 
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Note: I really dislike the low watermark check in split_free_page() and
>  consider it poor software engineering.  The function should split a free
>  page, nothing more.  Terminating memory compaction because of a low
>  watermark check when we're simply trying to migrate memory seems like an
>  arbitrary heuristic.  There was an objection to removing it in the first
>  proposed patch, but I think we should really consider removing that
>  check so this is simpler.
> 
>  mm/compaction.c | 37 +++++++++++++++----------------------
>  1 file changed, 15 insertions(+), 22 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
