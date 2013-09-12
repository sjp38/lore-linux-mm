Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 28BA16B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 22:10:15 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id z5so318964lbh.23
        for <linux-mm@kvack.org>; Wed, 11 Sep 2013 19:10:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1378805550-29949-28-git-send-email-mgorman@suse.de>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
	<1378805550-29949-28-git-send-email-mgorman@suse.de>
Date: Thu, 12 Sep 2013 10:10:13 +0800
Message-ID: <CAJd=RBCoJNPi0PPg3DQyRtuoKNvU42bpy9GPiNpzf5byMVQNOA@mail.gmail.com>
Subject: Re: [PATCH 27/50] mm: numa: Scan pages with elevated page_mapcount
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hillo Mel

On Tue, Sep 10, 2013 at 5:32 PM, Mel Gorman <mgorman@suse.de> wrote:
> Currently automatic NUMA balancing is unable to distinguish between false
> shared versus private pages except by ignoring pages with an elevated
> page_mapcount entirely. This avoids shared pages bouncing between the
> nodes whose task is using them but that is ignored quite a lot of data.
>
> This patch kicks away the training wheels in preparation for adding support
> for identifying shared/private pages is now in place. The ordering is so
> that the impact of the shared/private detection can be easily measured. Note
> that the patch does not migrate shared, file-backed within vmas marked
> VM_EXEC as these are generally shared library pages. Migrating such pages
> is not beneficial as there is an expectation they are read-shared between
> caches and iTLB and iCache pressure is generally low.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
[...]
> @@ -1658,13 +1660,6 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>         int page_lru = page_is_file_cache(page);
>
>         /*
> -        * Don't migrate pages that are mapped in multiple processes.
> -        * TODO: Handle false sharing detection instead of this hammer
> -        */
> -       if (page_mapcount(page) != 1)
> -               goto out_dropref;
> -
Is there rmap walk when migrating THP?

> -       /*
>          * Rate-limit the amount of data that is being migrated to a node.
>          * Optimal placement is no good if the memory bus is saturated and
>          * all the time is being spent migrating!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
