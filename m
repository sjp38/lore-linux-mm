Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 92EF06B006C
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 13:09:17 -0400 (EDT)
Received: by labe2 with SMTP id e2so75292058lab.3
        for <linux-mm@kvack.org>; Fri, 27 Mar 2015 10:09:16 -0700 (PDT)
Received: from forward-corp1m.cmail.yandex.net (forward-corp1m.cmail.yandex.net. [5.255.216.100])
        by mx.google.com with ESMTPS id k10si1765700lbs.115.2015.03.27.10.09.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Mar 2015 10:09:15 -0700 (PDT)
Message-ID: <55158EB5.5040301@yandex-team.ru>
Date: Fri, 27 Mar 2015 20:09:09 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] mm, shmem: Add shmem resident memory accounting
References: <1427474441-17708-1-git-send-email-vbabka@suse.cz> <1427474441-17708-4-git-send-email-vbabka@suse.cz>
In-Reply-To: <1427474441-17708-4-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>

On 27.03.2015 19:40, Vlastimil Babka wrote:
> From: Jerome Marchand <jmarchan@redhat.com>
>
> Currently looking at /proc/<pid>/status or statm, there is no way to
> distinguish shmem pages from pages mapped to a regular file (shmem
> pages are mapped to /dev/zero), even though their implication in
> actual memory use is quite different.
> This patch adds MM_SHMEMPAGES counter to mm_rss_stat to account for
> shmem pages instead of MM_FILEPAGES.
>
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> ---


> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -327,9 +327,12 @@ struct core_state {
>   };
>
>   enum {
> -	MM_FILEPAGES,
> -	MM_ANONPAGES,
> -	MM_SWAPENTS,
> +	MM_FILEPAGES,	/* Resident file mapping pages */
> +	MM_ANONPAGES,	/* Resident anonymous pages */
> +	MM_SWAPENTS,	/* Anonymous swap entries */
> +#ifdef CONFIG_SHMEM
> +	MM_SHMEMPAGES,	/* Resident shared memory pages */
> +#endif

I prefer to keep that counter unconditionally:
kernel has MM_SWAPENTS even without CONFIG_SWAP.

>   	NR_MM_COUNTERS
>   };
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
