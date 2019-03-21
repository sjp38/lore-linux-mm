Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09835C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:58:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 96B0321902
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 23:58:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MPlhlOyy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 96B0321902
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B6DE6B0003; Thu, 21 Mar 2019 19:58:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 140786B0006; Thu, 21 Mar 2019 19:58:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 004F66B0007; Thu, 21 Mar 2019 19:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C708C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 19:58:29 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id t13so444791qkm.2
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:58:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yDJgdezwv9pb242vYRRmjQ+71NeLZ6x0P4nCuwhNF0Y=;
        b=VqH1p0LNXQMqR2tutIYXirKOlXwsypU9TIW0UqN3KPzULgY7byjR2p9/6tdmfoDYRU
         +F7XT9Z/Wd516wr0zQiXUxnmA8S9f+uRKKt8Nao7nF1KJtCpESxyI6/Uxr6qmGC8Kb80
         S2PN90z/hIGqFss8ET5ehP2wdWQBu4S9qWCm46an5SvkDSgEKlglLGfXUyQsIn8Nsh4F
         36C4o57PI+ycTv80AqP4fCgSLs57JmSBUhG+rAM2LlCMD0anBG+fDQutUai+clGhVuMH
         C4Uq/bCdOQE2x+rvddEeIyFldn2ZIUs9HiGlHvnb1K3Vz1uJr+Pbzkhw2EK7EYyjSrZ1
         AZyQ==
X-Gm-Message-State: APjAAAVg2AAYlExwjN2rHtHUNS8iC2EomdLKv66g+/kihnwEETqCQLtS
	AzMaPKqzJu+o6timrkcg6P2rY3ijiNo1K37kFT4b4E0w0Bm5cPcLeH9pHbtVcvS5LwFOU85V7Mh
	t7vFTYph1bItir4bJqs9jk4MsB/qVtJVFh6jRxncVrGJHvzgRNxsSuB8JT/mYOy38pQ==
X-Received: by 2002:ae9:df41:: with SMTP id t62mr4970413qkf.150.1553212709481;
        Thu, 21 Mar 2019 16:58:29 -0700 (PDT)
X-Received: by 2002:ae9:df41:: with SMTP id t62mr4970376qkf.150.1553212708602;
        Thu, 21 Mar 2019 16:58:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553212708; cv=none;
        d=google.com; s=arc-20160816;
        b=wG5pPxjnLtQqSdo759H5tdo60vUviEnnXc7SKjMzWyduNlSSfLsNxdPdjIHPUKgrBq
         rraWHDVNx1oxfW36vAlXY1sw6JnRV8LRDeraWRtqV5xWrtVvTWFzCs/dHcfWfhhDzDNJ
         l4crHMc4bqn3o0hzxIgjmQNPXoVkPFrYFDoYgO9BnKim57M6fXBcpqUxZUUt7N8EO3uy
         Vr3NhPh0+zri6BxvEPBlw5H3moNJ3b7V9WIGuv3pKflFRrRZsYMJZX0N7+o1VxJRsyXh
         4ftaaWNsfvqitYAUZgPqJaQ95E7ZBXKiRKYVcsrWbDYFSER8N167TztACfERPb+s7HWO
         JBRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yDJgdezwv9pb242vYRRmjQ+71NeLZ6x0P4nCuwhNF0Y=;
        b=JJrI1WzcjFOuTHCMl2fjuhDfXN7Vu8WHjopTrML2XbtczAVRv9rBo7OfqBQDEnZxSh
         3a5Bow1vNq1es4dmYKeEwx39M1tjP7IOEP4PDbUHwtAqIjI9Vh5yprHd3ECntD8Ntzx4
         qb1lazmDbU5ocStfQHXmEsufIOKbhb1lQpX0QYCWl8bHBWsrROQCDV3G9siREGrHdNsQ
         SlmTatKE/S2zqqJOG+LP9d3YSmft/N9yXI+/LcSWt6HSu97P55ZKpYRCs2y+8T+zjgn3
         kmrnyIHvIMFfnnXaekr592pfBFAoGDTiGUmP7RH2ZwIGWCiXxmETQwjJg2r/jM8MtBd+
         H50w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MPlhlOyy;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k42sor10808009qtk.11.2019.03.21.16.58.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 16:58:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=MPlhlOyy;
       spf=pass (google.com: domain of shy828301@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shy828301@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yDJgdezwv9pb242vYRRmjQ+71NeLZ6x0P4nCuwhNF0Y=;
        b=MPlhlOyyK7u4fqsteq1DAEZTAYrFd+a2qBWI/pK5peJhhF2+Uul6P2iYAgx2H97Jeg
         N+N8zwJdJISkaib/XjXsjMcwD/Gukrdo3YtTkWGAMsXbgPeDnlpRpX+MdbtoUS2NwBKo
         2dBmLsN12RBI8cqFobRCfWG9GwF4uId38gnan/UP024I/cerlCxP2yZ16+bZDkO5KXGA
         KIME3MjKWo8rP1/Xvf5pO8LzPByR3aIgLn8EGZT8MohLa9HfR+K672xPem2gHboejnNB
         Mlv/pMyC8QTwfVEdPz0jXRvDV+oq4eVMwzJvDeQyUF8R+NvGSBm4O4IuSQsXUrlGZ7G1
         qamQ==
X-Google-Smtp-Source: APXvYqyg4mvl7a96NwP/BjBX/ejJizfb0+w4DB6UBlte5NkFd6Cn97Y9pIRsoiyE3EBPwp70t0jQVR6v1T0HOBVgfOA=
X-Received: by 2002:ac8:2e99:: with SMTP id h25mr5780960qta.166.1553212708415;
 Thu, 21 Mar 2019 16:58:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190321200157.29678-1-keith.busch@intel.com> <20190321200157.29678-4-keith.busch@intel.com>
In-Reply-To: <20190321200157.29678-4-keith.busch@intel.com>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 21 Mar 2019 16:58:16 -0700
Message-ID: <CAHbLzkqGGJ7dFiZkR-=yvGEF0AM4JbBe6pxGFbSe9tSnC7wgzQ@mail.gmail.com>
Subject: Re: [PATCH 3/5] mm: Attempt to migrate page in lieu of discard
To: Keith Busch <keith.busch@intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 1:03 PM Keith Busch <keith.busch@intel.com> wrote:
>
> If a memory node has a preferred migration path to demote cold pages,
> attempt to move those inactive pages to that migration node before
> reclaiming. This will better utilize available memory, provide a faster
> tier than swapping or discarding, and allow such pages to be reused
> immediately without IO to retrieve the data.
>
> Some places we would like to see this used:
>
>  1. Persistent memory being as a slower, cheaper DRAM replacement
>  2. Remote memory-only "expansion" NUMA nodes
>  3. Resolving memory imbalances where one NUMA node is seeing more
>     allocation activity than another.  This helps keep more recent
>     allocations closer to the CPUs on the node doing the allocating.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  include/linux/migrate.h        |  6 ++++++
>  include/trace/events/migrate.h |  3 ++-
>  mm/debug.c                     |  1 +
>  mm/migrate.c                   | 45 ++++++++++++++++++++++++++++++++++++++++++
>  mm/vmscan.c                    | 15 ++++++++++++++
>  5 files changed, 69 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e13d9bf2f9a5..a004cb1b2dbb 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -25,6 +25,7 @@ enum migrate_reason {
>         MR_MEMPOLICY_MBIND,
>         MR_NUMA_MISPLACED,
>         MR_CONTIG_RANGE,
> +       MR_DEMOTION,
>         MR_TYPES
>  };
>
> @@ -79,6 +80,7 @@ extern int migrate_huge_page_move_mapping(struct address_space *mapping,
>  extern int migrate_page_move_mapping(struct address_space *mapping,
>                 struct page *newpage, struct page *page, enum migrate_mode mode,
>                 int extra_count);
> +extern bool migrate_demote_mapping(struct page *page);
>  #else
>
>  static inline void putback_movable_pages(struct list_head *l) {}
> @@ -105,6 +107,10 @@ static inline int migrate_huge_page_move_mapping(struct address_space *mapping,
>         return -ENOSYS;
>  }
>
> +static inline bool migrate_demote_mapping(struct page *page)
> +{
> +       return false;
> +}
>  #endif /* CONFIG_MIGRATION */
>
>  #ifdef CONFIG_COMPACTION
> diff --git a/include/trace/events/migrate.h b/include/trace/events/migrate.h
> index 705b33d1e395..d25de0cc8714 100644
> --- a/include/trace/events/migrate.h
> +++ b/include/trace/events/migrate.h
> @@ -20,7 +20,8 @@
>         EM( MR_SYSCALL,         "syscall_or_cpuset")            \
>         EM( MR_MEMPOLICY_MBIND, "mempolicy_mbind")              \
>         EM( MR_NUMA_MISPLACED,  "numa_misplaced")               \
> -       EMe(MR_CONTIG_RANGE,    "contig_range")
> +       EM(MR_CONTIG_RANGE,     "contig_range")                 \
> +       EMe(MR_DEMOTION,        "demotion")
>
>  /*
>   * First define the enums in the above macros to be exported to userspace
> diff --git a/mm/debug.c b/mm/debug.c
> index c0b31b6c3877..53d499f65199 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -25,6 +25,7 @@ const char *migrate_reason_names[MR_TYPES] = {
>         "mempolicy_mbind",
>         "numa_misplaced",
>         "cma",
> +       "demotion",
>  };
>
>  const struct trace_print_flags pageflag_names[] = {
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 705b320d4b35..83fad87361bf 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1152,6 +1152,51 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
>         return rc;
>  }
>
> +/**
> + * migrate_demote_mapping() - Migrate this page and its mappings to its
> + *                           demotion node.
> + * @page: An isolated, non-compound page that should move to
> + *       its current node's migration path.
> + *
> + * @returns: True if migrate demotion was successful, false otherwise
> + */
> +bool migrate_demote_mapping(struct page *page)
> +{
> +       int rc, next_nid = next_migration_node(page_to_nid(page));
> +       struct page *newpage;
> +
> +       /*
> +        * The flags are set to allocate only on the desired node in the
> +        * migration path, and to fail fast if not immediately available. We
> +        * are already in the memory reclaim path, we don't want heroic
> +        * efforts to get a page.
> +        */
> +       gfp_t mask = GFP_NOWAIT | __GFP_NOWARN | __GFP_NORETRY |
> +                    __GFP_NOMEMALLOC | __GFP_THISNODE;
> +
> +       VM_BUG_ON_PAGE(PageCompound(page), page);
> +       VM_BUG_ON_PAGE(PageLRU(page), page);
> +
> +       if (next_nid < 0)
> +               return false;
> +
> +       newpage = alloc_pages_node(next_nid, mask, 0);
> +       if (!newpage)
> +               return false;
> +
> +       /*
> +        * MIGRATE_ASYNC is the most light weight and never blocks.
> +        */
> +       rc = __unmap_and_move_locked(page, newpage, MIGRATE_ASYNC);
> +       if (rc != MIGRATEPAGE_SUCCESS) {
> +               __free_pages(newpage, 0);
> +               return false;
> +       }
> +
> +       set_page_owner_migrate_reason(newpage, MR_DEMOTION);
> +       return true;
> +}
> +
>  /*
>   * gcc 4.7 and 4.8 on arm get an ICEs when inlining unmap_and_move().  Work
>   * around it.
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a5ad0b35ab8e..0a95804e946a 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1261,6 +1261,21 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                         ; /* try to reclaim the page below */
>                 }
>
> +               if (!PageCompound(page)) {
> +                       if (migrate_demote_mapping(page)) {
> +                                unlock_page(page);
> +                                if (likely(put_page_testzero(page)))
> +                                        goto free_it;
> +
> +                                /*
> +                                * Speculative reference will free this page,
> +                                * so leave it off the LRU.
> +                                */
> +                                nr_reclaimed++;
> +                                continue;
> +                        }
> +               }

It looks the reclaim path would fall through if the migration is
failed. But, it looks, with patch #4, you may end up trying reclaim an
anon page on swapless system if migration is failed?

And, actually I have the same question with Yan Zi. Why not just put
the demote candidate into a separate list, then migrate all the
candidates in bulk with migrate_pages()?

Thanks,
Yang

> +
>                 /*
>                  * Anonymous process memory has backing store?
>                  * Try to allocate it some swap space here.
> --
> 2.14.4
>

