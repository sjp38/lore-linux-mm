Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E29B3C3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 04:45:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94C3222CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 04:45:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Pj6Bj+SG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94C3222CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 308186B0003; Wed,  4 Sep 2019 00:45:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B8116B0006; Wed,  4 Sep 2019 00:45:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17F366B0007; Wed,  4 Sep 2019 00:45:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0237.hostedemail.com [216.40.44.237])
	by kanga.kvack.org (Postfix) with ESMTP id E48796B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 00:45:04 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 82E8CAC0E
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:45:04 +0000 (UTC)
X-FDA: 75895998528.30.spy65_2c3df5e338521
X-HE-Tag: spy65_2c3df5e338521
X-Filterd-Recvd-Size: 8527
Received: from mail-wm1-f67.google.com (mail-wm1-f67.google.com [209.85.128.67])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:45:03 +0000 (UTC)
Received: by mail-wm1-f67.google.com with SMTP id k2so1674557wmj.4
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 21:45:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZdND8YxjoFl7C+oYjsjla5d+S11BgE1Rp3NLcbkw4D8=;
        b=Pj6Bj+SGv+AFUXT9EcZXmMudHNzHJsZrvUEwyc7OVQLmaWkuYZgZAX/FBObnO146Qc
         5dvzgB464Q5VdJ8uCikMxGriZSQcwpEf9la60hDCKTLzd8PAgTTt/zzJWcWqJMkBvsiz
         ansABPD5UFMCh5JfbgQ7BdJXTEkNaULX/jxQ9BJ6Ku/qcijiGpvFCdkRN9zBgw+tNlgB
         VMaB7BFGrTkNwaaK9xOr3UeW6Eir1bOCLkxv9WgbBAbLiW1dY/3La46eVOe8QwenrB8W
         SGYlvV6CXjcImie3WEjs+9Nv/eZrLGda8QxDv+iVQdKee/cz4gV1tX8BxRoGg1TfxGyj
         3Y2Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ZdND8YxjoFl7C+oYjsjla5d+S11BgE1Rp3NLcbkw4D8=;
        b=VQK2O7Uh0Fr7e23PHAV1ZPlsaIEbdlLZkKKP1aqjZmxxgvyaH4ybI8mbOUhtNzz/2W
         B1/QssEm53uqRDFC6OOM8cMz4TQDoDUYD+9W3t2sISPXrQlHceKsIINpuQBZtb46dYVK
         JlUYVSgKaDb9DiL9Y20W/6pRYaDHc5xlgSOrq2FQxTsihCON14ozB7pz+hi5JXoI4miy
         3AtZxVztOwOFbD0CyfJosDSST3eDyFSVUmbSjOY2mFWjgjaeBxJjV0Zi3snHH118n0kl
         rTNXhz+0h7G+/MzqdbS2LGc+mYN3KRz3DA+g5FaG7TH+XuEo9e5gzEgvsbA9JbEpvK2o
         QdCw==
X-Gm-Message-State: APjAAAVMjWHXW5qEYk50wIS2/6b67OGWxCBA0H4KiRy1qx4GnbLX5Jmw
	PzOqYwaZ9/zmzf9EQB42Nqt/IBnCy9e+kIntrHUjNw==
X-Google-Smtp-Source: APXvYqzVdFPCTLPRvogqdcbkkp+TeXmWoRy/CoZqD3sRTU6RZc6M0sqD8TH8Yg1FdKlCexfzyoFEllBFL7qlvvlhFyI=
X-Received: by 2002:a7b:c4d6:: with SMTP id g22mr2525255wmk.21.1567572301979;
 Tue, 03 Sep 2019 21:45:01 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org>
In-Reply-To: <20190903200905.198642-1-joel@joelfernandes.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 3 Sep 2019 21:44:51 -0700
Message-ID: <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Tim Murray <timmurray@google.com>, 
	Carmen Jackson <carmenjackson@google.com>, mayankgupta@google.com, 
	Daniel Colascione <dancol@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel-team <kernel-team@android.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, 
	linux-mm <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>, 
	Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
<joel@joelfernandes.org> wrote:
>
> Useful to track how RSS is changing per TGID to detect spikes in RSS and
> memory hogs. Several Android teams have been using this patch in various
> kernel trees for half a year now. Many reported to me it is really
> useful so I'm posting it upstream.
>
> Initial patch developed by Tim Murray. Changes I made from original patch:
> o Prevent any additional space consumed by mm_struct.
> o Keep overhead low by checking if tracing is enabled.
> o Add some noise reduction and lower overhead by emitting only on
>   threshold changes.
>
> Co-developed-by: Tim Murray <timmurray@google.com>
> Signed-off-by: Tim Murray <timmurray@google.com>
> Signed-off-by: Joel Fernandes (Google) <joel@joelfernandes.org>
>
> ---
>
> v1->v2: Added more commit message.
>
> Cc: carmenjackson@google.com
> Cc: mayankgupta@google.com
> Cc: dancol@google.com
> Cc: rostedt@goodmis.org
> Cc: minchan@kernel.org
> Cc: akpm@linux-foundation.org
> Cc: kernel-team@android.com
>
>  include/linux/mm.h          | 14 +++++++++++---
>  include/trace/events/kmem.h | 21 +++++++++++++++++++++
>  mm/memory.c                 | 20 ++++++++++++++++++++
>  3 files changed, 52 insertions(+), 3 deletions(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 0334ca97c584..823aaf759bdb 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1671,19 +1671,27 @@ static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
>         return (unsigned long)val;
>  }
>
> +void mm_trace_rss_stat(int member, long count, long value);
> +
>  static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
>  {
> -       atomic_long_add(value, &mm->rss_stat.count[member]);
> +       long count = atomic_long_add_return(value, &mm->rss_stat.count[member]);
> +
> +       mm_trace_rss_stat(member, count, value);
>  }
>
>  static inline void inc_mm_counter(struct mm_struct *mm, int member)
>  {
> -       atomic_long_inc(&mm->rss_stat.count[member]);
> +       long count = atomic_long_inc_return(&mm->rss_stat.count[member]);
> +
> +       mm_trace_rss_stat(member, count, 1);
>  }
>
>  static inline void dec_mm_counter(struct mm_struct *mm, int member)
>  {
> -       atomic_long_dec(&mm->rss_stat.count[member]);
> +       long count = atomic_long_dec_return(&mm->rss_stat.count[member]);
> +
> +       mm_trace_rss_stat(member, count, -1);
>  }
>
>  /* Optimized variant when page is already known not to be PageAnon */
> diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
> index eb57e3037deb..8b88e04fafbf 100644
> --- a/include/trace/events/kmem.h
> +++ b/include/trace/events/kmem.h
> @@ -315,6 +315,27 @@ TRACE_EVENT(mm_page_alloc_extfrag,
>                 __entry->change_ownership)
>  );
>
> +TRACE_EVENT(rss_stat,
> +
> +       TP_PROTO(int member,
> +               long count),
> +
> +       TP_ARGS(member, count),
> +
> +       TP_STRUCT__entry(
> +               __field(int, member)
> +               __field(long, size)
> +       ),
> +
> +       TP_fast_assign(
> +               __entry->member = member;
> +               __entry->size = (count << PAGE_SHIFT);
> +       ),
> +
> +       TP_printk("member=%d size=%ldB",
> +               __entry->member,
> +               __entry->size)
> +       );
>  #endif /* _TRACE_KMEM_H */
>
>  /* This part must be outside protection */
> diff --git a/mm/memory.c b/mm/memory.c
> index e2bb51b6242e..9d81322c24a3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -72,6 +72,8 @@
>  #include <linux/oom.h>
>  #include <linux/numa.h>
>
> +#include <trace/events/kmem.h>
> +
>  #include <asm/io.h>
>  #include <asm/mmu_context.h>
>  #include <asm/pgalloc.h>
> @@ -140,6 +142,24 @@ static int __init init_zero_pfn(void)
>  }
>  core_initcall(init_zero_pfn);
>
> +/*
> + * This threshold is the boundary in the value space, that the counter has to
> + * advance before we trace it. Should be a power of 2. It is to reduce unwanted
> + * trace overhead. The counter is in units of number of pages.
> + */
> +#define TRACE_MM_COUNTER_THRESHOLD 128

IIUC the counter has to change by 128 pages (512kB assuming 4kB pages)
before the change gets traced. Would it make sense to make this step
size configurable? For a system with limited memory size change of
512kB might be considerable while on systems with plenty of memory
that might be negligible. Not even mentioning possible difference in
page sizes. Maybe something like
/sys/kernel/debug/tracing/rss_step_order with
TRACE_MM_COUNTER_THRESHOLD=(1<<rss_step_order)?

> +
> +void mm_trace_rss_stat(int member, long count, long value)
> +{
> +       long thresh_mask = ~(TRACE_MM_COUNTER_THRESHOLD - 1);
> +
> +       if (!trace_rss_stat_enabled())
> +               return;
> +
> +       /* Threshold roll-over, trace it */
> +       if ((count & thresh_mask) != ((count - value) & thresh_mask))
> +               trace_rss_stat(member, count);
> +}
>
>  #if defined(SPLIT_RSS_COUNTING)
>
> --
> 2.23.0.187.g17f5b7556c-goog
>
> --
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

