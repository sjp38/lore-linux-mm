Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 717F06B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 13:04:41 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lf10so8975492pab.8
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:04:41 -0700 (PDT)
Received: from USMAMAIL.TILERA.COM (usmamail.tilera.com. [12.216.194.151])
        by mx.google.com with ESMTPS id f9si19375107pdk.6.2014.09.24.10.04.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Sep 2014 10:04:40 -0700 (PDT)
Message-ID: <5422F9A3.2010303@tilera.com>
Date: Wed, 24 Sep 2014 13:04:35 -0400
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: introduce VM_BUG_ON_MM
References: <1410032326-4380-1-git-send-email-sasha.levin@oracle.com> <1410032326-4380-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1410032326-4380-2-git-send-email-sasha.levin@oracle.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>, akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 9/6/2014 3:40 PM, Sasha Levin wrote:
> Very similar to VM_BUG_ON_PAGE and VM_BUG_ON_VMA, dump struct_mm
> when the bug is hit.
>
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>   include/linux/mmdebug.h |   10 +++++++
>   mm/debug.c              |   69 +++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 79 insertions(+)
>
> [...]
> diff --git a/mm/debug.c b/mm/debug.c
> index c19af12..8418893 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> +#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> +		"tlb_flush_pending %d\n",
> +#endif

Putting the comma that separates the format string from the arguments
inside an ifdef means that if you don't build with NUMA_BALANCING or
COMPACTION you get a compile error.  Perhaps this instead:

+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+		"tlb_flush_pending %d\n"
+#endif
-		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
+		, mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
