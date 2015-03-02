Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC726B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 16:49:46 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id hq11so2989393vcb.8
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:49:46 -0800 (PST)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com. [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id eu4si5927301vdd.76.2015.03.02.13.49.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 13:49:45 -0800 (PST)
Received: by mail-vc0-f181.google.com with SMTP id le20so5219732vcb.12
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 13:49:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425316867-6104-1-git-send-email-jeffv@google.com>
References: <1425316867-6104-1-git-send-email-jeffv@google.com>
Date: Mon, 2 Mar 2015 13:49:45 -0800
Message-ID: <CAFJ0LnFyM+6fiCvtdfWVg2f-8uQFesVgXoHiMFQu6Zix7ZWNGQ@mail.gmail.com>
Subject: Re: [PATCH] mm: reorder can_do_mlock to fix audit denial
From: Nick Kralevich <nnk@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Vander Stoep <jeffv@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Paul Cassella <cassella@cray.com>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, Stephen Smalley <sds@tycho.nsa.gov>

On Mon, Mar 2, 2015 at 9:20 AM, Jeff Vander Stoep <jeffv@google.com> wrote:
> A userspace call to mmap(MAP_LOCKED) may result in the successful
> locking of memory while also producing a confusing audit log denial.
> can_do_mlock checks capable and rlimit. If either of these return
> positive can_do_mlock returns true. The capable check leads to an LSM
> hook used by apparmour and selinux which produce the audit denial.
> Reordering so rlimit is checked first eliminates the denial on success,
> only recording a denial when the lock is unsuccessful as a result of
> the denial.
>

Acked-By: Nick Kralevich <nnk@google.com>

> Signed-off-by: Jeff Vander Stoep <jeffv@google.com>
> ---
>  mm/mlock.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 73cf098..8a54cd2 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -26,10 +26,10 @@
>
>  int can_do_mlock(void)
>  {
> -       if (capable(CAP_IPC_LOCK))
> -               return 1;
>         if (rlimit(RLIMIT_MEMLOCK) != 0)
>                 return 1;
> +       if (capable(CAP_IPC_LOCK))
> +               return 1;
>         return 0;
>  }
>  EXPORT_SYMBOL(can_do_mlock);
> --
> 2.2.0.rc0.207.ga3a616c
>



-- 
Nick Kralevich | Android Security | nnk@google.com | 650.214.4037

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
