Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A2EEC10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:12:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C1C820883
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 06:12:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C1C820883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB1496B0007; Tue,  9 Apr 2019 02:12:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C38406B0008; Tue,  9 Apr 2019 02:12:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B28B56B000C; Tue,  9 Apr 2019 02:12:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 636746B0007
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 02:12:03 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p88so8081433edd.17
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 23:12:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=W+MqTxrHTTZ+YutO2kReARe8t8kkc5GLWYNjOGD63qs=;
        b=bb79ByEWC/HwY8x5pivLBFhhuQJGjU9Q/srsTTvbTB5vt8UZbnoFdhIn3Wj9rxwAbD
         3EuFmGd2qdCgse9DLwtZy2gJ7g4ooKHbovJR+1MiYXksCKDUua9Z+PYYs57Ywj4egGpU
         79CWEL6yfKaRTXjiXgRdQnWMCpKnvCBrElCS6yCPofT64JnnR6bglUsfw99AEsYMUh29
         Q8Kn7G7o+lQLiYUpp03qbnSsRzWDcQuCM6QQFMx7ewB7WyVxRZ8SZAyqwciwgDP+BOAT
         94diBjL1j/Jm8ym85VP/lRRxUbb0pe0K0Xt2kpeFjoqX7ZlsPiGA7PW+s5lK32jIJ/rW
         TXcQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVSlGWUbEy5kT21JhfWU7MLlqmzIPsMPwfvrvTb8Ta3RkzmBdLX
	3g8PHpQem4j4jRIKbIjQiLKvdbjYJHPzcJrke0fx7bFywThC/3UwMmwysFE4KABpRcEyydP0zqh
	WlGLtK39nO8nITLG/igURr6oT2SlnVtcHtuQwwIIfRsrwogkSJPyycoWK8UqeECo=
X-Received: by 2002:a50:fe03:: with SMTP id f3mr21923478edt.57.1554790322934;
        Mon, 08 Apr 2019 23:12:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl5ztiseNZKYC2jryXpmwqgQcABUrc1xy4jokT0UiZ0gZojQI/Y92CjiviRhUhA/Oximxx
X-Received: by 2002:a50:fe03:: with SMTP id f3mr21923431edt.57.1554790322113;
        Mon, 08 Apr 2019 23:12:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554790322; cv=none;
        d=google.com; s=arc-20160816;
        b=FgZGBkUZgWxUAwewY56TP8xgNsobOb4lk4u2W4aG4HiZGUebc+IK+9UalIPFb0sZ8E
         2QzbEleMcJUyf8pqajNVqp8sqrgyyCF7MQuw7kTxtp6W2pvJC2LC/cdXUT+ghWgS3WDP
         Hts51Yy79w30f/UcFHVPnZFvUqDV/WwSyerknduODzc07XLsxAZQCJHaGvFWebJVTsxL
         U/oCF+KpkvqSAWdOxRmJ5M5/iRDanQrmLgFj+smJuRlVwvyQaAwwILegHMiPzZZoT3lu
         idJ8eYkKALx3MTQMZv3E23eUjzCp6XR5OrWQwxHtJ5FpukGBs85Bj28qWZ8Er0iJO3Jz
         Cp2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=W+MqTxrHTTZ+YutO2kReARe8t8kkc5GLWYNjOGD63qs=;
        b=z6wR1bk6ZQ3UFeXSKAL/DvqchO/l9/T86WhhwGAm/0bNZ0pg+C+PGQiq5AJXZ/XjNU
         csW4Rr2OKWoAsvngy0RGUuv5o+uU5wvmnnVp/7+Gma6VNpfh/r7iA24jAPtKz78p7hmS
         Hir62GTGZw+C1Jp1GyipMN2VBflI18k/vx/IewYfc5R5s2kIf6q8ClBgbu4EsOBcKRzU
         yhCHV2Y+I+BPJfdbG2ZXK3BseOe4XCyh6WKc5BqWcvY9Aqx35W/DyzydzBDYsT01bqJp
         qSSWbbrn+sudpxigqArygwE7mVGZDat1SbVw8N/3YS+e3O0JZUKyPldal9M0oMslxlfX
         hXhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si168022edl.327.2019.04.08.23.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 23:12:02 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 36CE4AD5E;
	Tue,  9 Apr 2019 06:12:01 +0000 (UTC)
Date: Tue, 9 Apr 2019 08:12:00 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oscar Salvador <osalvador@suse.de>, david@redhat.com,
	dan.j.williams@intel.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH v2 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
Message-ID: <20190409061200.GA10383@dhcp22.suse.cz>
References: <20190408082633.2864-1-osalvador@suse.de>
 <20190408082633.2864-3-osalvador@suse.de>
 <20190408213041.50350dac32ed315839c57e09@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190408213041.50350dac32ed315839c57e09@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 08-04-19 21:30:41, Andrew Morton wrote:
> On Mon,  8 Apr 2019 10:26:33 +0200 Oscar Salvador <osalvador@suse.de> wrote:
> 
> > arch_add_memory, __add_pages take a want_memblock which controls whether
> > the newly added memory should get the sysfs memblock user API (e.g.
> > ZONE_DEVICE users do not want/need this interface). Some callers even
> > want to control where do we allocate the memmap from by configuring
> > altmap.
> > 
> > Add a more generic hotplug context for arch_add_memory and __add_pages.
> > struct mhp_restrictions contains flags which contains additional
> > features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
> > currently) and altmap for alternative memmap allocator.
> > 
> > This patch shouldn't introduce any functional change.
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug-fix
> 
> x86_64 allnoconfig:
> 
> In file included from ./include/linux/mmzone.h:744:0,
>                  from ./include/linux/gfp.h:6,
>                  from ./include/linux/umh.h:4,
>                  from ./include/linux/kmod.h:22,
>                  from ./include/linux/module.h:13,
>                  from init/do_mounts.c:1:
> ./include/linux/memory_hotplug.h:353:11: warning: ‘struct mhp_restrictions’ declared inside parameter list will not be visible outside of this definition or declaration
>     struct mhp_restrictions *restrictions);
>            ^~~~~~~~~~~~~~~~
> 
> Fix this by moving the arch_add_memory() definition inside
> CONFIG_MEMORY_HOTPLUG and moving the mhp_restrictions definition to a more
> appropriate place.

LGTM. Thanks for the fixup!

> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  include/linux/memory_hotplug.h |   24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> --- a/include/linux/memory_hotplug.h~mm-memory_hotplug-provide-a-more-generic-restrictions-for-memory-hotplug-fix
> +++ a/include/linux/memory_hotplug.h
> @@ -54,6 +54,16 @@ enum {
>  };
>  
>  /*
> + * Restrictions for the memory hotplug:
> + * flags:  MHP_ flags
> + * altmap: alternative allocator for memmap array
> + */
> +struct mhp_restrictions {
> +	unsigned long flags;
> +	struct vmem_altmap *altmap;
> +};
> +
> +/*
>   * Zone resizing functions
>   *
>   * Note: any attempt to resize a zone should has pgdat_resize_lock()
> @@ -101,6 +111,8 @@ extern void __online_page_free(struct pa
>  
>  extern int try_online_node(int nid);
>  
> +extern int arch_add_memory(int nid, u64 start, u64 size,
> +			struct mhp_restrictions *restrictions);
>  extern u64 max_mem_size;
>  
>  extern bool memhp_auto_online;
> @@ -126,16 +138,6 @@ extern int __remove_pages(struct zone *z
>  
>  #define MHP_MEMBLOCK_API               (1<<0)
>  
> -/*
> - * Restrictions for the memory hotplug:
> - * flags:  MHP_ flags
> - * altmap: alternative allocator for memmap array
> - */
> -struct mhp_restrictions {
> -	unsigned long flags;
> -	struct vmem_altmap *altmap;
> -};
> -
>  /* reasonably generic interface to expand the physical pages */
>  extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
>  		       struct mhp_restrictions *restrictions);
> @@ -349,8 +351,6 @@ extern int walk_memory_range(unsigned lo
>  extern int __add_memory(int nid, u64 start, u64 size);
>  extern int add_memory(int nid, u64 start, u64 size);
>  extern int add_memory_resource(int nid, struct resource *resource);
> -extern int arch_add_memory(int nid, u64 start, u64 size,
> -			struct mhp_restrictions *restrictions);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> _
> 

-- 
Michal Hocko
SUSE Labs

