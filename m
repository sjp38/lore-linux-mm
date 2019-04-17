Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A714EC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F1AD21773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 12:46:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F1AD21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43016B0005; Wed, 17 Apr 2019 08:46:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF4166B0006; Wed, 17 Apr 2019 08:46:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE22E6B0007; Wed, 17 Apr 2019 08:46:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0786B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:46:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o8so11923382edh.12
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 05:46:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oRHBVbSc+h1xDDP2E9YsjjnPlvD02v4fzWP8aoh+1kI=;
        b=KTHhbN/E6Bd1yyLmaF+KDWrnIJNjKBlc062uok+0VFYEcf/WoU8cpW2iDX7Qaqkgrn
         t0XhZhxeFYB19L+umrwfa9/lvyuj8lw+mZjwPbnjZA2clzIK/1d+kexqPVrqYC7akQvi
         axl4Y7GYUql2EAb0LIKcoF7wgzjL5J+D+FKR4PSjPy4ne3G276AOvzgvL8WOg9awK6wK
         dpmVE7ruqZxPMmGQPsz7FsH/NFN4cUYZrH2aPtW5kIIIXWcGz3MiSu6/IXpAX6hojAf6
         5N5bvwBzo/68k3Fs7Phn64F1D6+Iqk5Je3tR6l6wT+rh8oGmrjUUEpQZArqddsRe1Vpu
         KU4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWPrnLi7d8gNBPs7PNPNPoK5DCs0Bq2E/vrwaH8rR6adco8lfLO
	foNx0yeKclR0SJ2xf7W3WdOVr44E7xGbnSb4Ao/IBodgeGRJjQprx3JyKqDSUHt7lKxt9LYZJmX
	LIqsJOCSgixpayowjGznLg4HhWKmoOTWeOCUfLtedpt8s8ISa6TLKdv61dF+YJIp1dg==
X-Received: by 2002:a50:e712:: with SMTP id a18mr54799509edn.155.1555505164897;
        Wed, 17 Apr 2019 05:46:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKqu563Grc2qjwwq34sqX2ZvN7hfp60fBItO96t22vkdpOX4/fbfzHXFC17n9xiqgWfLFr
X-Received: by 2002:a50:e712:: with SMTP id a18mr54799441edn.155.1555505163851;
        Wed, 17 Apr 2019 05:46:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555505163; cv=none;
        d=google.com; s=arc-20160816;
        b=xNP+O46jkDzmv0cyp1II8Ac0rkz34WSAhrcRbFT65PCK1b5q642CTOZtt4hqv3l9NV
         L/OCGe5fRQyu3wvE0qTQ+lE1RhHvYwMC0NCB8Vxfx1EB9T0YolITZ5u2qgbOxhxpKTwm
         1fx5169v3KdbOzyZ6zrWSeVEDviUZ1yxiHp09c05ZUsMLomTjFQWjJDpuk5wzxjDyL4e
         wW0GawtJEP9Mu3c9Fb8HuBe1KKNbj5SkUDnGnYJHv5ML3ySwAaAvOM7hRKcvVfi7RdF8
         P9pVoUhhOUIxiapmk74CDruOqkOKInPXlPS3aLWjekiAwUj2Q4nVImyp+XOI520G7n8M
         TBrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=oRHBVbSc+h1xDDP2E9YsjjnPlvD02v4fzWP8aoh+1kI=;
        b=u7znzd8RbhXPAY1Hrlm/HIUztdFYpAX0YZuVg10g9wnCtAT/rz7Y2QswETJKTsaiY1
         lqYv3LRv0xBmYF8Bv1mw6LAhoA5KM/UTuClwhNAQr6uH7WSmS5bpYkTruUr2w5v97RRn
         v2sl21ACG78TewzrIDfaaHjw4ibOQ1ruly0I1UfUI/xWtL0K8uOxJUHrvS+yQPQNIB6r
         pf3H4HUR2NwIkFx0ShVOs2bFR2RzLo6xZAI1H2ZciCGKxCi/r+N2L5eRfspyleqnr0jy
         F/wmqKy+qsKRJDBzfqbm7F37uwZbQlNrRUFBmUYN1QAhbtXFb21Z9PHA/l7y11WzRDCs
         vDMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2si932689ejs.335.2019.04.17.05.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 05:46:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EF28AAE43;
	Wed, 17 Apr 2019 12:46:02 +0000 (UTC)
Message-ID: <1555505146.3139.26.camel@suse.de>
Subject: Re: [PATCH v1 2/4] mm/memory_hotplug: Make
 unregister_memory_section() never fail
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ingo
 Molnar <mingo@kernel.org>, Andrew Banman <andrew.banman@hpe.com>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Andrew Morton
 <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>, Wei Yang
 <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>, Mathieu
 Malaterre <malat@debian.org>
Date: Wed, 17 Apr 2019 14:45:46 +0200
In-Reply-To: <20190409100148.24703-3-david@redhat.com>
References: <20190409100148.24703-1-david@redhat.com>
	 <20190409100148.24703-3-david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-04-09 at 12:01 +0200, David Hildenbrand wrote:
> Failing while removing memory is mostly ignored and cannot really be
> handled. Let's treat errors in unregister_memory_section() in a nice
> way, warning, but continuing.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 16 +++++-----------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    |  4 +---
>  3 files changed, 7 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 0c9e22ffa47a..f180427e48f4 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -734,15 +734,18 @@ unregister_memory(struct memory_block *memory)
>  {
>  	BUG_ON(memory->dev.bus != &memory_subsys);
>  
> -	/* drop the ref. we got in remove_memory_section() */
> +	/* drop the ref. we got via find_memory_block() */
>  	put_device(&memory->dev);
>  	device_unregister(&memory->dev);
>  }
>  
> -static int remove_memory_section(struct mem_section *section)
> +void unregister_memory_section(struct mem_section *section)
>  {
>  	struct memory_block *mem;
>  
> +	if (WARN_ON_ONCE(!present_section(section)))
> +		return;
> +
>  	mutex_lock(&mem_sysfs_mutex);
>  
>  	/*
> @@ -763,15 +766,6 @@ static int remove_memory_section(struct
> mem_section *section)
>  
>  out_unlock:
>  	mutex_unlock(&mem_sysfs_mutex);
> -	return 0;
> -}
> -
> -int unregister_memory_section(struct mem_section *section)
> -{
> -	if (!present_section(section))
> -		return -EINVAL;
> -
> -	return remove_memory_section(section);
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index a6ddefc60517..e1dc1bb2b787 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -113,7 +113,7 @@ extern int
> register_memory_isolate_notifier(struct notifier_block *nb);
>  extern void unregister_memory_isolate_notifier(struct notifier_block
> *nb);
>  int hotplug_memory_register(int nid, struct mem_section *section);
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -extern int unregister_memory_section(struct mem_section *);
> +extern void unregister_memory_section(struct mem_section *);
>  #endif
>  extern int memory_dev_init(void);
>  extern int memory_notify(unsigned long val, void *v);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 696ed7ee5e28..b0cb05748f99 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -527,9 +527,7 @@ static int __remove_section(struct zone *zone,
> struct mem_section *ms,
>  	if (!valid_section(ms))
>  		return ret;
>  
> -	ret = unregister_memory_section(ms);
> -	if (ret)
> -		return ret;
> +	unregister_memory_section(ms);

So, technically unregister_memory_section() can __only__ fail in case
the section is not present, returning -EINVAL.

Now, I was checking how the pair valid/present sections work.
Unless I am mistaken, we only mark sections as memmap those sections
that are present.

This can come from two paths:

- Early boot:
  * memblocks_present
     memory_present           - mark sections as present
    sparse_init               - iterates only over present sections
     sparse_init_nid
      sparse_init_one_section - mark section as valid

- Hotplug path:
  * sparse_add_one_section
     section_mark_present     - mark section as present
     sparse_init_one_section  - mark section as valid
   

During early boot, sparse_init iterates __only__ over present sections,
so only those are marked valid as well, and during hotplug, the section
is both marked present and valid.

All in all, I think that we are safe if we remove the present_section
check in your new unregister_memory_section(), as a valid_section
cannot be non-present, and we do already catch those early in
__remove_section().

Then, the only thing missing to be completely error-less in that
codepath is to make unregister_mem_sect_under_nodes() void return-type.
Not that it matters a lot as we are already ignoring its return code,
but I find that quite disturbing and wrong.

So, would you like to take this patch in your patchset in case you re-
submit?

From: Oscar Salvador <osalvador@suse.de>
Date: Wed, 17 Apr 2019 14:41:32 +0200
Subject: [PATCH] mm,memory_hotplug: Refactor
unregister_mem_sect_under_nodes

Currently, the return code of unregister_mem_sect_under_nodes gets
ignored.
It can only fail in case we are not able to allocate a nodemask_t,
but such allocation is too small, so it is not really clear
we can actually fail.

The maximum a nodemask_t can be is 128 bytes, so we can make the whole
thing more simple if we simply allocate a nodemask_t within the stack.

With this change, we can convert unregister_mem_sect_under_nodes to
be void-return type.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/base/node.c  | 16 ++++------------
 include/linux/node.h |  5 ++---
 2 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 8598fcbd2a17..fcd0f442e73d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -802,19 +802,13 @@ int register_mem_sect_under_node(struct
memory_block *mem_blk, void *arg)
 }
 
 /* unregister memory section under all nodes that it spans */
-int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
+void unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 				    unsigned long phys_index)
 {
-	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
+	nodemask_t unlinked_nodes;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
-	if (!mem_blk) {
-		NODEMASK_FREE(unlinked_nodes);
-		return -EFAULT;
-	}
-	if (!unlinked_nodes)
-		return -ENOMEM;
-	nodes_clear(*unlinked_nodes);
+	nodes_clear(unlinked_nodes);
 
 	sect_start_pfn = section_nr_to_pfn(phys_index);
 	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
@@ -826,15 +820,13 @@ int unregister_mem_sect_under_nodes(struct
memory_block *mem_blk,
 			continue;
 		if (!node_online(nid))
 			continue;
-		if (node_test_and_set(nid, *unlinked_nodes))
+		if (node_test_and_set(nid, unlinked_nodes))
 			continue;
 		sysfs_remove_link(&node_devices[nid]->dev.kobj,
 			 kobject_name(&mem_blk->dev.kobj));
 		sysfs_remove_link(&mem_blk->dev.kobj,
 			 kobject_name(&node_devices[nid]->dev.kobj));
 	}
-	NODEMASK_FREE(unlinked_nodes);
-	return 0;
 }
 
 int link_mem_sections(int nid, unsigned long start_pfn, unsigned long
end_pfn)
diff --git a/include/linux/node.h b/include/linux/node.h
index 1a557c589ecb..094ec9922bf5 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -139,7 +139,7 @@ extern int register_cpu_under_node(unsigned int
cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int
nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 						void *arg);
-extern int unregister_mem_sect_under_nodes(struct memory_block
*mem_blk,
+extern void unregister_mem_sect_under_nodes(struct memory_block
*mem_blk,
 					   unsigned long phys_index);
 
 extern int register_memory_node_under_compute_node(unsigned int
mem_nid,
@@ -176,10 +176,9 @@ static inline int
register_mem_sect_under_node(struct memory_block *mem_blk,
 {
 	return 0;
 }
-static inline int unregister_mem_sect_under_nodes(struct memory_block
*mem_blk,
+static inline void unregister_mem_sect_under_nodes(struct memory_block
*mem_blk,
 						  unsigned long
phys_index)
 {
-	return 0;
 }
 
 static inline void
register_hugetlbfs_with_node(node_registration_func_t reg,
-- 
2.12.3


-- 
Oscar Salvador
SUSE L3

