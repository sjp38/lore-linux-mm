Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FA90C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:50:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 593CB218A5
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 17:50:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="p8VRpRki"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 593CB218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D45996B000E; Fri, 29 Mar 2019 13:50:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCF086B0010; Fri, 29 Mar 2019 13:50:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B989C6B0269; Fri, 29 Mar 2019 13:50:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9295E6B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 13:50:20 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w124so2441440qkb.12
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 10:50:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=3iU4vJFcmV9tYu+4R51hGMcqNX2SfyXVOH+cKpv41qc=;
        b=eYwxsJFDtJ8929al8bPmIuy6+43gi66WHRhxa+K0isxERkHghI6K5wGPysDN5u+mer
         vmmRABN+VLe+ksWxlq/WQivyPt6h+pPB9KiLdOc4jYjqFrA1pwXGFt1Otrr4sdhETjEf
         e7LxXFRKjYw9hehbiiY5wuWLhJNitLEa51s/kQrolqBkFLzd1kphMaALsyvw2F4P+UL3
         oHdc3WuM6B+2NrAviBXW5c6qKMGjMS428CKGYf+t2x/aZmlpEoUcEsdpcmqby1ZbcBPT
         XIXcmF35dqlr+u2IYB3y80/P6sAXxmzXIJ2R4x64BEwpzh64nWrGAeJ6Sw45gPNys5Yf
         kN2w==
X-Gm-Message-State: APjAAAXVfyl20wVlihD6vdBIQXNOWSLZ/truVHTForLuRXw1M2KJfflG
	aY4xnwrfjySFm9UXfNQrLTyAW0pUqiuhrtXIV3V9wBzB+2fjVJ4HieuEfh0I52NTBTd8nhgAO7/
	qxezdDSqZ/kv6wAWNRkwKWVReXHpYGbERaNuMr+vdbev4krazzyU0jbDSzKezaiC8wg==
X-Received: by 2002:aed:3bd8:: with SMTP id s24mr41605546qte.358.1553881820345;
        Fri, 29 Mar 2019 10:50:20 -0700 (PDT)
X-Received: by 2002:aed:3bd8:: with SMTP id s24mr41605508qte.358.1553881819688;
        Fri, 29 Mar 2019 10:50:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553881819; cv=none;
        d=google.com; s=arc-20160816;
        b=ug81wV6UVoik7RCRvXhf3eyYfRIvTJSk2GyyvDkPzfSJRFG2pnxtCZauqdInjMxth+
         UOZf75ilMu6Ti2kuuMLOegH5Hh7ktwUU97LT9iW6huWgGeSVdZmWtu4NmG6Ekib5SkX/
         wogmqyumxWoQFCDvDnMUy7/vEB38sxkKJv8BvIzsfRCeE33cPB4tfRLvswkHJVRH6gsA
         36oBrTll4ojoLD4aw1JzKPoIZ4f7NPpKlyhw756l7yV0wFiysTBIh3Bttb4r7gTIHxGf
         BG6Ql0BPcVGYPrM7vFNvnVZ7wb52fhZKKxzqhVGYIJN5MYVHUVCV0sY2a0cBv/e7VHxz
         waYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=3iU4vJFcmV9tYu+4R51hGMcqNX2SfyXVOH+cKpv41qc=;
        b=FWCtW2+1H5m048xG1ED1ncANkTRJ4F6ZlJrk0SUsRQ3vyJ5opBt1wIWR5+vuSXLkOs
         VxIzNODqXOngJZowi7uWehwG1N5giAqDwx+bxGfCTyY1UuBzY6CIS75h5dmxaXubUN/X
         8hrFbY2bhcKoWYuoCgsbjkooOHWr8D94imJLimGDrLjNxQ/JvDGWfSn4UWmRieNOKhI5
         L4riL/wqKtH+8f9x6N6j1bQuH3JePir/56j27FD+6I6VqapyO9J7ARpm2xwwUn05X8oU
         Vm7mr/XJ3PdV8lgVMYanQ0DBAT7aHT7elgvHLNUfp28OgITAZmC33wHpRJs8qN+dm2ds
         SiUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p8VRpRki;
       spf=pass (google.com: domain of 321qexackcpqcpdahajckkcha.ykihejqt-iigrwyg.knc@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=321qeXAcKCPQcpdahajckkcha.Ykihejqt-iigrWYg.knc@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id p92sor2897144qvp.7.2019.03.29.10.50.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 10:50:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of 321qexackcpqcpdahajckkcha.ykihejqt-iigrwyg.knc@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=p8VRpRki;
       spf=pass (google.com: domain of 321qexackcpqcpdahajckkcha.ykihejqt-iigrwyg.knc@flex--gthelen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=321qeXAcKCPQcpdahajckkcha.Ykihejqt-iigrWYg.knc@flex--gthelen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=3iU4vJFcmV9tYu+4R51hGMcqNX2SfyXVOH+cKpv41qc=;
        b=p8VRpRkiNLGTt+JwfmkMCjck5+ZN90gGIfV39oRcXXfCX7p0KdhLO03SC0Fcwtzezq
         pGGK6NO7b+KM9v8IkREWVQn1cySl44ZwGMldSnBDGRWDFmzlsUd291E8aKx89jG1tChK
         5v/+y1SCpf7XKxV0iXISvJxjucT7VtbD+Uh2hqlbwNopqiUOilQY4tu23N4a8B8VSLvj
         kVpuqtKNlhvG1AlVGfthUS7AgDZ3yjflcLaS6Eg6VnkqE0ZA1hUmzAeZkq5DEYiZlBEN
         SO8zHK1KhdHvYuDvGumtVbcfuvHnuFty5ORfeUbePVHMnkNL+0x2VCXipOiRMrCNeSAy
         33mQ==
X-Google-Smtp-Source: APXvYqyNIuH84GzZGVP+fs2+r/hVUGR1UWcRbxODGazD/ZTe7ozxd5xNj2A37KLfPmKPx5sBVd2cgLQ3IWX0
X-Received: by 2002:a0c:af53:: with SMTP id j19mr4158438qvc.19.1553881819416;
 Fri, 29 Mar 2019 10:50:19 -0700 (PDT)
Date: Fri, 29 Mar 2019 10:50:17 -0700
In-Reply-To: <20190328142016.GA15763@cmpxchg.org>
Message-Id: <xr93imw1wox2.fsf@gthelen.svl.corp.google.com>
Mime-Version: 1.0
References: <20190307165632.35810-1-gthelen@google.com> <20190328142016.GA15763@cmpxchg.org>
Subject: Re: [PATCH] writeback: sum memcg dirty counters as needed
From: Greg Thelen <gthelen@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Mar 07, 2019 at 08:56:32AM -0800, Greg Thelen wrote:
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -3880,6 +3880,7 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
>>   * @pheadroom: out parameter for number of allocatable pages according to memcg
>>   * @pdirty: out parameter for number of dirty pages
>>   * @pwriteback: out parameter for number of pages under writeback
>> + * @exact: determines exact counters are required, indicates more work.
>>   *
>>   * Determine the numbers of file, headroom, dirty, and writeback pages in
>>   * @wb's memcg.  File, dirty and writeback are self-explanatory.  Headroom
>> @@ -3890,18 +3891,29 @@ struct wb_domain *mem_cgroup_wb_domain(struct bdi_writeback *wb)
>>   * ancestors.  Note that this doesn't consider the actual amount of
>>   * available memory in the system.  The caller should further cap
>>   * *@pheadroom accordingly.
>> + *
>> + * Return value is the error precision associated with *@pdirty
>> + * and *@pwriteback.  When @exact is set this a minimal value.
>>   */
>> -void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>> -			 unsigned long *pheadroom, unsigned long *pdirty,
>> -			 unsigned long *pwriteback)
>> +unsigned long
>> +mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>> +		    unsigned long *pheadroom, unsigned long *pdirty,
>> +		    unsigned long *pwriteback, bool exact)
>>  {
>>  	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
>>  	struct mem_cgroup *parent;
>> +	unsigned long precision;
>>  
>> -	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
>> -
>> +	if (exact) {
>> +		precision = 0;
>> +		*pdirty = memcg_exact_page_state(memcg, NR_FILE_DIRTY);
>> +		*pwriteback = memcg_exact_page_state(memcg, NR_WRITEBACK);
>> +	} else {
>> +		precision = MEMCG_CHARGE_BATCH * num_online_cpus();
>> +		*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
>> +		*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
>> +	}
>>  	/* this should eventually include NR_UNSTABLE_NFS */
>> -	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
>>  	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
>>  						     (1 << LRU_ACTIVE_FILE));
>>  	*pheadroom = PAGE_COUNTER_MAX;
>> @@ -3913,6 +3925,8 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
>>  		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
>>  		memcg = parent;
>>  	}
>> +
>> +	return precision;
>
> Have you considered unconditionally using the exact version here?
>
> It does for_each_online_cpu(), but until very, very recently we did
> this per default for all stats, for years. It only became a problem in
> conjunction with the for_each_memcg loops when frequently reading
> memory stats at the top of a very large hierarchy.
>
> balance_dirty_pages() is called against memcgs that actually own the
> inodes/memory and doesn't do the additional recursive tree collection.
>
> It's also not *that* hot of a function, and in the io path...
>
> It would simplify this patch immensely.

Good idea.  Done in -v2 of the patch:
https://lore.kernel.org/lkml/20190329174609.164344-1-gthelen@google.com/

