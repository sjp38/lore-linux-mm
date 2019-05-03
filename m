Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB92BC04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 12:56:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4655F208C3
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 12:56:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4655F208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A567D6B0003; Fri,  3 May 2019 08:56:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A06E16B0005; Fri,  3 May 2019 08:56:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F72A6B0006; Fri,  3 May 2019 08:56:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3FA6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 08:56:40 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id t58so3659198edb.22
        for <linux-mm@kvack.org>; Fri, 03 May 2019 05:56:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=k6+0+dCkuqLM9AEl8WzmBz7Em+Be0LDL8+SAWKxlVT0=;
        b=L5oh6s8KWzfGlUP09fxvES4k0/+uJvKDpxBnFx49F8+sGDl2aS+cKmGOVuFTSCwpS8
         rSlHAkZTgzmDfqmya6tYIa+RqHS8/iakBC0zfRBdpIUZEVB8QghwZ7W0KASmryStwRtk
         Q2YYnKz5Xr1QzoKfwEVl1khwgbfa5GZRkKoIB2ynPaZeJ0v3gRR+/vlk6Of0Pr9Ah6u1
         vP2fYKJlViYe1UcY6fHgDFWZZ/YeVcTavsaNSBP1ZWAwAfYeBZkD4BKMfjiQwJX3uIL7
         GrcehffSQg79rKAgislaQCWovjdc8W12IR7/ZrV1aPdga2mXWjJIjTly0c8mnBv3JlDp
         YzbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXpvVpdf+3u8hfC7PjnAjpFTum0PtNnzjampoZjOJRD7D6trRps
	NlyHejVz4vcyO+dDtjst/eiOkYvcwNgCsLQVdc9LEgCbJmWI+2gqL11MmMqopifbysu+RuRQNgZ
	c55c1HnAz6TK91R9wFOJmxnPNwEf4UOAXCIsmegyvXXVOXtBFRuhld8n+d2Wfl5Ktbw==
X-Received: by 2002:aa7:da81:: with SMTP id q1mr7988785eds.116.1556888199824;
        Fri, 03 May 2019 05:56:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxm+GF9qZkdqtxbqydcIs+EJ/kSFSkwhqsovKQOLC2HJ8uJCcn9frYS5CHCCOB8Q5MDPcmn
X-Received: by 2002:aa7:da81:: with SMTP id q1mr7988689eds.116.1556888198646;
        Fri, 03 May 2019 05:56:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556888198; cv=none;
        d=google.com; s=arc-20160816;
        b=eErqne9aNj4Z11TCnn8IQDi6eq0pqivIXFHpWjJpywH4pVVvFTjeruO0EMFsIGoyQ+
         4LBQekbBqbm+2JmX2HKYzEVXu4VWz5/tULcn6crVClY9o83qqO9/MtQVbDwMoC1btJlj
         CzBJ+NOMX1PY1+lVY4vajORmcRWnzL5lXBExvFQkrys7bfUWQ+dE38o4R53faVPZT9ws
         v84Qf+ZgKHJoJp8ZzpTskPKl9IGF/lnfSl1+YlBbm2v23TR00+8rcTXG3n4pffX7O2uP
         2+2kdth3xMy+a/Cn0TpHowqTcmwiCkt+1hkQaotWZS+GeeSps8GxyIcC5+AgmYbLbKvK
         yXLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=k6+0+dCkuqLM9AEl8WzmBz7Em+Be0LDL8+SAWKxlVT0=;
        b=BTFR5KcrybPbGeKhihHwtLbkYMJ7XuDXKPG6fd6DNJiOGe511sLx88NyFpp4RokBgF
         hcdOxATR8vP51LMoMqH9eB2zJo9BsmfTlDC0wMjKvjYSrqFR3Siv10RvxuK0/sRU5qJk
         YsZko0beIAinkgKN+jHuaHHqCjjELL3xFk80CWibE6iGitFKwy/NHzhwskO/XAJQ/nij
         d1wjHelrwjd0BZBgQkbY6KMI/bfRN/Rv8XovIgYBOZFg2O4CH+GqyYnvcoYuWY86YyzO
         Ro5n61WOhMJ4nE+LMKlEI2XuCWkF0FgoWxydll40LqeA0tGaS2re3RQYZ4k6IDzT3IU2
         bu/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si1140354ejj.258.2019.05.03.05.56.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 05:56:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 91E0EAD62;
	Fri,  3 May 2019 12:56:37 +0000 (UTC)
Date: Fri, 3 May 2019 14:56:34 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 09/12] mm/sparsemem: Support sub-section hotplug
Message-ID: <20190503125634.GH15740@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677657023.2336373.4452495266651002382.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155677657023.2336373.4452495266651002382.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:56:10PM -0700, Dan Williams wrote:
> The libnvdimm sub-system has suffered a series of hacks and broken
> workarounds for the memory-hotplug implementation's awkward
> section-aligned (128MB) granularity. For example the following backtrace
> is emitted when attempting arch_add_memory() with physical address
> ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
> within a given section:
> 
>  WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
>  devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
>  [..]
>  Call Trace:
>    dump_stack+0x86/0xc3
>    __warn+0xcb/0xf0
>    warn_slowpath_fmt+0x5f/0x80
>    devm_memremap_pages+0x3b5/0x4c0
>    __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
>    pmem_attach_disk+0x19a/0x440 [nd_pmem]
> 
> Recently it was discovered that the problem goes beyond RAM vs PMEM
> collisions as some platform produce PMEM vs PMEM collisions within a
> given section. The libnvdimm workaround for that case revealed that the
> libnvdimm section-alignment-padding implementation has been broken for a
> long while. A fix for that long-standing breakage introduces as many
> problems as it solves as it would require a backward-incompatible change
> to the namespace metadata interpretation. Instead of that dubious route
> [1], address the root problem in the memory-hotplug implementation.
> 
> [1]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  mm/sparse.c |  223 ++++++++++++++++++++++++++++++++++++++++-------------------
>  1 file changed, 150 insertions(+), 73 deletions(-)
> 
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 198371e5fc87..419a3620af6e 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -83,8 +83,15 @@ static int __meminit sparse_index_init(unsigned long section_nr, int nid)
>  	unsigned long root = SECTION_NR_TO_ROOT(section_nr);
>  	struct mem_section *section;
>  
> +	/*
> +	 * An existing section is possible in the sub-section hotplug
> +	 * case. First hot-add instantiates, follow-on hot-add reuses
> +	 * the existing section.
> +	 *
> +	 * The mem_hotplug_lock resolves the apparent race below.
> +	 */
>  	if (mem_section[root])
> -		return -EEXIST;
> +		return 0;

Just a sidenote: we do not bail out on -EEXIST, so it should be fine if we
stick with it.
But if not, I would then clean up sparse_add_section:

--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -901,13 +901,12 @@ int __meminit sparse_add_section(int nid, unsigned long start_pfn,
        int ret;
 
        ret = sparse_index_init(section_nr, nid);
-       if (ret < 0 && ret != -EEXIST)
+       if (ret < 0)
                return ret;
 
        memmap = section_activate(nid, start_pfn, nr_pages, altmap);
        if (IS_ERR(memmap))
                return PTR_ERR(memmap);
-       ret = 0;


> +
> +	if (!mask)
> +		rc = -EINVAL;
> +	else if (mask & ms->usage->map_active)

	else if (ms->usage->map_active) should be enough?

> +		rc = -EEXIST;
> +	else
> +		ms->usage->map_active |= mask;
> +
> +	if (rc) {
> +		if (usage)
> +			ms->usage = NULL;
> +		kfree(usage);
> +		return ERR_PTR(rc);
> +	}
> +
> +	/*
> +	 * The early init code does not consider partially populated
> +	 * initial sections, it simply assumes that memory will never be
> +	 * referenced.  If we hot-add memory into such a section then we
> +	 * do not need to populate the memmap and can simply reuse what
> +	 * is already there.
> +	 */

This puzzles me a bit.
I think we cannot have partially populated early sections, can we?
And how we even come to hot-add memory into those?

Could you please elaborate a bit here?

> +	ms = __pfn_to_section(start_pfn);
>  	section_mark_present(ms);
> -	sparse_init_one_section(ms, section_nr, memmap, usage);
> +	sparse_init_one_section(ms, section_nr, memmap, ms->usage);
>  
> -out:
> -	if (ret < 0) {
> -		kfree(usage);
> -		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
> -	}
> +	if (ret < 0)
> +		section_deactivate(start_pfn, nr_pages, nid, altmap);

Uhm, if my eyes do not trick me, ret is only used for the return value from
sparse_index_init(), so this is not needed. Can we get rid of it?

Unfortunately I am running out of time, but I plan to keep reviewing this patch
in the next few days.

-- 
Oscar Salvador
SUSE L3

