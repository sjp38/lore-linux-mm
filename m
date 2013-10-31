Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE8A6B0035
	for <linux-mm@kvack.org>; Thu, 31 Oct 2013 00:55:50 -0400 (EDT)
Received: by mail-ie0-f178.google.com with SMTP id x13so4149007ief.9
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 21:55:49 -0700 (PDT)
Received: from psmtp.com ([74.125.245.119])
        by mx.google.com with SMTP id b10si1501855icq.131.2013.10.30.21.55.46
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 21:55:48 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id j15so4276935qaq.19
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 21:55:44 -0700 (PDT)
Message-ID: <5271E2CC.8040702@gmail.com>
Date: Thu, 31 Oct 2013 00:55:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Do not walk all of system memory during show_mem
References: <20131016104228.GM11028@suse.de>
In-Reply-To: <20131016104228.GM11028@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@gmail.com, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

(10/16/13 6:42 AM), Mel Gorman wrote:
> It has been reported on very large machines that show_mem is taking almost
> 5 minutes to display information. This is a serious problem if there is
> an OOM storm. The bulk of the cost is in show_mem doing a very expensive
> PFN walk to give us the following information
>
> Total RAM:	Also available as totalram_pages
> Highmem pages:	Also available as totalhigh_pages
> Reserved pages:	Can be inferred from the zone structure
> Shared pages:	PFN walk required
> Unshared pages:	PFN walk required
> Quick pages:	Per-cpu walk required
>
> Only the shared/unshared pages requires a full PFN walk but that information
> is useless. It is also inaccurate as page pins of unshared pages would
> be accounted for as shared.  Even if the information was accurate, I'm
> struggling to think how the shared/unshared information could be useful
> for debugging OOM conditions. Maybe it was useful before rmap existed when
> reclaiming shared pages was costly but it is less relevant today.
>
> The PFN walk could be optimised a bit but why bother as the information is
> useless. This patch deletes the PFN walker and infers the total RAM, highmem
> and reserved pages count from struct zone. It omits the shared/unshared page
> usage on the grounds that it is useless.  It also corrects the reporting
> of HighMem as HighMem/MovableOnly as ZONE_MOVABLE has similar problems to
> HighMem with respect to lowmem/highmem exhaustion.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

That's ok. I haven't used such information on my long oom debugging history.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
