Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F406B6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:29:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id o64so144964093pfb.2
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:29:03 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s19si6144973pfg.28.2017.02.27.09.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 09:29:03 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1RHPrGh135506
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:29:02 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28uqvn1yda-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:29:02 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 27 Feb 2017 10:29:01 -0700
Date: Mon, 27 Feb 2017 11:28:52 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20170227092817.23571-1-mhocko@kernel.org>
Message-Id: <20170227172852.t52egmv743fi26ds@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, Michal Hocko <mhocko@suse.com>

On Mon, Feb 27, 2017 at 10:28:17AM +0100, Michal Hocko wrote: 
>diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
>index 134a2f69c21a..a72f7f64ee26 100644
>--- a/include/linux/memory_hotplug.h
>+++ b/include/linux/memory_hotplug.h
>@@ -100,8 +100,6 @@ extern void __online_page_free(struct page *page);
>
> extern int try_online_node(int nid);
>
>-extern bool memhp_auto_online;
>-
> #ifdef CONFIG_MEMORY_HOTREMOVE
> extern bool is_pageblock_removable_nolock(struct page *page);
> extern int arch_remove_memory(u64 start, u64 size);
>@@ -272,7 +270,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
>
> extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> 		void *arg, int (*func)(struct memory_block *, void *));
>-extern int add_memory(int nid, u64 start, u64 size);
>+extern int add_memory(int nid, u64 start, u64 size, bool online);
> extern int add_memory_resource(int nid, struct resource *resource, bool online);
> extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
> 		bool for_device);

It would be nice if instead of a 'bool online' argument, add_memory() 
and add_memory_resource() took an 'int online_type', ala online_pages().

That way we could specify offline, online, online+movable, etc.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
