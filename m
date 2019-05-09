Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B113CC04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 12:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 649AD21479
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 12:43:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X8+t1ymT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 649AD21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F20846B0007; Thu,  9 May 2019 08:43:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED05E6B0008; Thu,  9 May 2019 08:43:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D98DE6B000A; Thu,  9 May 2019 08:43:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D05D6B0007
	for <linux-mm@kvack.org>; Thu,  9 May 2019 08:43:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y12so1405957ede.19
        for <linux-mm@kvack.org>; Thu, 09 May 2019 05:43:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QsgdOJDYHn/tfXe+apw05fuvXqjWkWLQh0vbJ3o4icQ=;
        b=DH8YSU8Re1cdubhBatJZ0fJhGlHysRqBmhZAWcgaNZLEOSeTPk0sYZ+xB6NVFZDqRf
         etLlnjgFrKVr66Kmz2AlXJNkLubMklsd4GlxUrr230J8B8fAHoenvTwxrbqhZ3f1LhTi
         zE6xTjpkJNvk+BrKIsqxAUfURbnaXiIANLtNR7+AFqovj6xqtFPRkn9ZeRxH+OtLPvBt
         ChAykA3OvuiKti9lPVqE75xP9dujwf8Vm+yQJqQNWcNoGZ8IM1Ju5Hy+O+uJMToReOB2
         4VGuUgnkPFDXaXh0l/BJpH+/vTTDXNEDy8zFFmb4DbGiolwAsbflYR7ZrDi4qsPgYQNs
         a15A==
X-Gm-Message-State: APjAAAXMjwfzIqnnvLUARrN9AxMv9ENncU3rkZ9b6jcAgYIN+gvSozXx
	8Os005b+jnXFBKSlLCZPR4I6s76KfdG7pUr5ajEfxcklIAkuqPpBhX4EhoaUI2V4x0TKNChlE+q
	idYG3vamxA6LY0bCZpNpqHiNJwYABUrRu+5P6e6dV4tLgtfULvYHSgRQHO8DEVc9IOA==
X-Received: by 2002:a17:906:f91:: with SMTP id q17mr3028068ejj.63.1557405785100;
        Thu, 09 May 2019 05:43:05 -0700 (PDT)
X-Received: by 2002:a17:906:f91:: with SMTP id q17mr3028003ejj.63.1557405784175;
        Thu, 09 May 2019 05:43:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557405784; cv=none;
        d=google.com; s=arc-20160816;
        b=PUmbVYBuCNtBI0KlfJ0VbHa1J8iawWbN0W2PEoOXUxRiGdt8x7iGA09dRVd6TLMsAP
         ODOLIYUxqWQYRctvgFsTDMdPltpcnM2KJGBBAc1OYqvw64qIbvsWzgDQPB7FNUFfjJ3s
         0QBDLG1ew6gxo5fy9u0omoTyopeEtyYrvB03Datjz7318UmL3wmRGchycCRV0rDDxU8F
         WK83BpFri9QaBNqPh/XTrP8+m53JnvzUGVgtzpvvvkP0bKrYanwjf5frZhW0tRZXtofQ
         kEKipb2AR20ZpkDFbOlGXvoQbvIKxkdGzQiNqDL3hebbqySHVl7w3MebaccT/lT/ilY1
         dwww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=QsgdOJDYHn/tfXe+apw05fuvXqjWkWLQh0vbJ3o4icQ=;
        b=KFtrC0bQ+99GxSQdkI91ejzZ5J3be1PsvRDgljfvuMZ1m3NBdwh78rRcal+BuR6oQ3
         fOGYvaPm9YzZnu4dqBpBdCdmPxkYcMefuOal+XftZHsp42drjb1FkMXRdHT98V9OfFba
         ma99jTONYk89MXSbnwbA5UUqnJtCpvaaaNgEVlKoC0CPsLMwH45MOzmsFdQMrmAUKu78
         PZuaCXxgDY2EakchefNxJgXaN5JFXPdS/2KwMADJ87smEsZag9x0ziNFy60muh9GP7us
         VJUP3v1XNl5jbtQOZqDRngrO+nWXypyxjmL7057FbGOD5FRs1o6f8tPrcA3FksIw98ka
         ri4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X8+t1ymT;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id gu10sor654854ejb.58.2019.05.09.05.43.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 05:43:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X8+t1ymT;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QsgdOJDYHn/tfXe+apw05fuvXqjWkWLQh0vbJ3o4icQ=;
        b=X8+t1ymTYcyltAjf8v1dQF+XWnX6+Ka0h/n/Sp7NhymDucJNtZxdecMYnob2Injauf
         prmYn1KR0VaeFSnO5nN8SN73MXJZF0qI0mBEWIBZB9pui+fjXk9cWdDD+EyINCqMgx1Q
         PT6yJp94Qz0hthu8VQ2H1YaSFHjZ38HZ42VY4SnfYBSPXK/HDzFbSeoj3OQPuaOLAeFe
         eEJ1P8uvRoUwH9aNBvgmstZw14Q6XOf7bFPU079ouZQh/1QDXXkqf2kPgwMwSU+bFA7e
         LD8hzyVTjeLmlSqIETgbTm+FSLcZYsbhL7kX75dUPEc6gceTAXEWMhIGe/3LdCM831GM
         7kmA==
X-Google-Smtp-Source: APXvYqwSMvc+IkN0goCuzZGHyfnoTzg7aUzcqfUpVzHNwIsf6cZyZm3yry5tEzCvNGV+FZLlTxCadw==
X-Received: by 2002:a17:906:1984:: with SMTP id g4mr3006437ejd.260.1557405783809;
        Thu, 09 May 2019 05:43:03 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id e21sm300748ejk.86.2019.05.09.05.43.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 09 May 2019 05:43:02 -0700 (PDT)
Date: Thu, 9 May 2019 12:43:02 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	"mike.travis@hpe.com" <mike.travis@hpe.com>,
	Ingo Molnar <mingo@kernel.org>,
	Andrew Banman <andrew.banman@hpe.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>, Qian Cai <cai@lca.pw>,
	Wei Yang <richard.weiyang@gmail.com>,
	Arun KS <arunks@codeaurora.org>,
	Mathieu Malaterre <malat@debian.org>
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
Message-ID: <20190509124302.at7jltfrycj7sxbd@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507183804.5512-5-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 08:38:00PM +0200, David Hildenbrand wrote:
>Only memory to be added to the buddy and to be onlined/offlined by
>user space using memory block devices needs (and should have!) memory
>block devices.
>
>Factor out creation of memory block devices Create all devices after
>arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>because it is now effectively stale.
>
>Only after memory block devices have been added, memory can be onlined
>by user space. This implies, that memory is not visible to user space at
>all before arch_add_memory() succeeded.
>
>Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>Cc: David Hildenbrand <david@redhat.com>
>Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Ingo Molnar <mingo@kernel.org>
>Cc: Andrew Banman <andrew.banman@hpe.com>
>Cc: Oscar Salvador <osalvador@suse.de>
>Cc: Michal Hocko <mhocko@suse.com>
>Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>Cc: Qian Cai <cai@lca.pw>
>Cc: Wei Yang <richard.weiyang@gmail.com>
>Cc: Arun KS <arunks@codeaurora.org>
>Cc: Mathieu Malaterre <malat@debian.org>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
> include/linux/memory.h |  2 +-
> mm/memory_hotplug.c    | 15 ++++-----
> 3 files changed, 53 insertions(+), 34 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 6e0cb4fda179..862c202a18ca 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
> 	return 0;
> }
> 
>+static void unregister_memory(struct memory_block *memory)
>+{
>+	BUG_ON(memory->dev.bus != &memory_subsys);
>+
>+	/* drop the ref. we got via find_memory_block() */
>+	put_device(&memory->dev);
>+	device_unregister(&memory->dev);
>+}
>+
> /*
>- * need an interface for the VM to add new memory regions,
>- * but without onlining it.
>+ * Create memory block devices for the given memory area. Start and size
>+ * have to be aligned to memory block granularity. Memory block devices
>+ * will be initialized as offline.
>  */
>-int hotplug_memory_register(int nid, struct mem_section *section)
>+int hotplug_memory_register(unsigned long start, unsigned long size)
> {
>-	int ret = 0;
>+	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
>+	unsigned long start_pfn = PFN_DOWN(start);
>+	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>+	unsigned long pfn;
> 	struct memory_block *mem;
>+	int ret = 0;
> 
>-	mutex_lock(&mem_sysfs_mutex);
>+	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
>+	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));

After this change, the call flow looks like this:

add_memory_resource
    check_hotplug_memory_range
    hotplug_memory_register

Since in check_hotplug_memory_range() has checked the boundary, do we need to
check here again?

-- 
Wei Yang
Help you, Help me

