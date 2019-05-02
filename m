Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFB18C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 07:48:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ABC152089E
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 07:48:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ABC152089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4090A6B0007; Thu,  2 May 2019 03:48:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B8906B0008; Thu,  2 May 2019 03:48:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2823C6B000A; Thu,  2 May 2019 03:48:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0EF16B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 03:48:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h12so631719edl.23
        for <linux-mm@kvack.org>; Thu, 02 May 2019 00:48:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rRN6J7UcxEzTCJplpAxTqwNg5+MNBwTAo1Vm/S22Ays=;
        b=oa4EWQAhPdGCeYyvr7lC7cdhkO71IxUSzKJiec9II0vt6RTmUIZ9vqXscNGKzEaHgO
         PnxmfzK/+F8tqo7fJrupdgLXUUAd781j1L5WsRF0FYZk19esLZzernkzSygmr8ETC3EV
         KSCRrHwv7ROB4s4VcGIXLyrsPtKG4U8UetZtoHYdENP+GIT6qJmS9Op5axECGK6jnPya
         b/0IO/XSn1MQCRR8mhHIz61+icOmf0ykRII4thkM0YHFpnmO6mu3noN3PNr1B5RXmxdg
         lNlfd77f02wGxERlpA6+TOxtOESgI1+XmB91ijWCuUbG0DumDLKhz5Ihsl6OdaQIJRbl
         B3Sw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAV2tebe8vAf1GZhyJXtr6r7Ew1S6DEPVXBlfw3ors0vhdtdVVKH
	UvvAoE4fveBx/UYzHMSjv0+v1hOPnH3LyENVInxkW2UMqGWI7+m+0O/bCDCnYlupfD8rWT271+X
	gVPFn1vuU32t0VtFevj7oBH0FFT5rIhIpNohHqxLQ0m4oC0OAzpXhCeMDCR+oZHj/qg==
X-Received: by 2002:a17:906:2e54:: with SMTP id r20mr1080475eji.146.1556783294383;
        Thu, 02 May 2019 00:48:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYzLgoponPhQcPyQcbczjvMOayCTahVedN8glmaXceD3Y56KuyEw4fnkwHtTAIETdXi9lU
X-Received: by 2002:a17:906:2e54:: with SMTP id r20mr1080446eji.146.1556783293376;
        Thu, 02 May 2019 00:48:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556783293; cv=none;
        d=google.com; s=arc-20160816;
        b=HFQOKRs8nhwXjL79EKyyxJhaJMtCQIc+Z1DkkKJHt/7EdvnASk64MSMVCH2vfxgioX
         7gwDjXVUoEUWsekAWVtIpLQOiTVzk7iADJQjWJcKoNFZXymXjvrWTxPsOcxNVf0nFtkq
         UO9QaIHdvznIbpIc3SGHgpTI20OoJ0oOmsk2cDO6lg9gLC3LuricJ1R1srV8C6AIRYt8
         GHh2wuWSxSzHRl8xTGclwUWTwZJtO/zUgufIIsYLNiQOIqJbUWt5AWtUaRLCbwOkVp+1
         ZsrhvUuGff1B7JNatrjF1B/p2EBl4QhRk7gQtO814jDFzQJedGNhpL0bacviCUg5roeI
         izLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rRN6J7UcxEzTCJplpAxTqwNg5+MNBwTAo1Vm/S22Ays=;
        b=CYWa3l6Gqyi5uDHeyNGmskWRzR+nmje+XjAsPGPsk4IMnQpo/cfcZ/9wLNCQafcgWC
         ggRptyI5AEgrKYONPbYtSFL3cVmcMZr+hfbDYEc8r1whlBUWteO/j4PDNaKlN5Me1D2C
         xB97lOAKRn9aziAOE1ScLeHAPotMwEyrQL+jKGRZSPEiLDPTQzzooG59HaAJXtqxtTqh
         1SP8kMc+dzMbXIsaVRUmd5KNAsIgf1lr9dUevPibA3yDRklVMWmzfU21FN6oKSBzSbLe
         isZgKqMCS7p4ytja1Rvor23WOuxrTOsIjfH4RTypNGU4QMofW7GXudmJBdqVkdg4zhX6
         AgCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w11si1755950edc.148.2019.05.02.00.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 00:48:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5EA80AD6D;
	Thu,  2 May 2019 07:48:12 +0000 (UTC)
Date: Thu, 2 May 2019 09:48:08 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>,
	Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 03/12] mm/sparsemem: Add helpers track active portions
 of a section at boot
Message-ID: <20190502074803.GA3495@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155677653785.2336373.11131100812252340469.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:55:37PM -0700, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> section active bitmask, each bit representing 2MB (SECTION_SIZE (128M) /
> map_active bitmask length (64)). If it turns out that 2MB is too large
> of an active tracking granularity it is trivial to increase the size of
> the map_active bitmap.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Tested-by: Jane Chu <jane.chu@oracle.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Unfortunately I did not hear back about the comments/questions I made for this
in the previous version.

> ---
>  include/linux/mmzone.h |   29 ++++++++++++++++++++++++++++-
>  mm/page_alloc.c        |    4 +++-
>  mm/sparse.c            |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 79 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 6726fc175b51..cffde898e345 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1175,6 +1175,8 @@ struct mem_section_usage {
>  	unsigned long pageblock_flags[0];
>  };
>  
> +void section_active_init(unsigned long pfn, unsigned long nr_pages);
> +
>  struct page;
>  struct page_ext;
>  struct mem_section {
> @@ -1312,12 +1314,36 @@ static inline struct mem_section *__pfn_to_section(unsigned long pfn)
>  
>  extern int __highest_present_section_nr;
>  
> +static inline int section_active_index(phys_addr_t phys)
> +{
> +	return (phys & ~(PA_SECTION_MASK)) / SECTION_ACTIVE_SIZE;
> +}
> +
> +#ifdef CONFIG_SPARSEMEM_VMEMMAP
> +static inline int pfn_section_valid(struct mem_section *ms, unsigned long pfn)
> +{
> +	int idx = section_active_index(PFN_PHYS(pfn));
> +
> +	return !!(ms->usage->map_active & (1UL << idx));

section_active_mask() also converts the value to address/size.
Why do we need to convert the values and we cannot work with pfn/pages instead?
It should be perfectly possible unless I am missing something.

The only thing required would be to export earlier your:

+#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
+#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))

and change section_active_index to:

static inline int section_active_index(unsigned long pfn)
{
	return (pfn & ~(PAGE_SECTION_MASK)) / SUB_SECTION_ACTIVE_PAGES;
}

In this way we do need to shift the values every time and we can work with them
directly.
Maybe you made it work this way because a reason I am missing.

> +static unsigned long section_active_mask(unsigned long pfn,
> +		unsigned long nr_pages)
> +{
> +	int idx_start, idx_size;
> +	phys_addr_t start, size;
> +
> +	if (!nr_pages)
> +		return 0;
> +
> +	start = PFN_PHYS(pfn);
> +	size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK)));

It seems to me that we already picked the lowest value back in
section_active_init, so we should be fine if we drop the min() here?

Another thing is why do we need to convert the values to address/size, and we
cannot work with pfns/pages.
Unless I am missing something it should be possible.

> +	size = ALIGN(size, SECTION_ACTIVE_SIZE);
> +
> +	idx_start = section_active_index(start);
> +	idx_size = section_active_index(size);
> +
> +	if (idx_size == 0)
> +		return -1;

Maybe we would be better off converting that -1 into something like "FULL_SECTION",
or at least dropping a comment there that "-1" means that the section is fully
populated.

> +	return ((1UL << idx_size) - 1) << idx_start;
> +}
> +
> +void section_active_init(unsigned long pfn, unsigned long nr_pages)
> +{
> +	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> +	int i, start_sec = pfn_to_section_nr(pfn);
> +
> +	if (!nr_pages)
> +		return;
> +
> +	for (i = start_sec; i <= end_sec; i++) {
> +		struct mem_section *ms;
> +		unsigned long mask;
> +		unsigned long pfns;
> +
> +		pfns = min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK));
> +		mask = section_active_mask(pfn, pfns);
> +
> +		ms = __nr_to_section(i);
> +		ms->usage->map_active |= mask;
> +		pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i, ms->usage->map_active);
> +
> +		pfn += pfns;
> +		nr_pages -= pfns;
> +	}
> +}
> +
>  /* Record a memory area against a node. */
>  void __init memory_present(int nid, unsigned long start, unsigned long end)
>  {
> 

-- 
Oscar Salvador
SUSE L3

