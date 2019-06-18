Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78A30C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:37:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 482282089E
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:37:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 482282089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD6328E0007; Mon, 17 Jun 2019 20:37:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C87D48E0005; Mon, 17 Jun 2019 20:37:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9DBD8E0007; Mon, 17 Jun 2019 20:37:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 855828E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:37:08 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id u10so6769946plq.21
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:37:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=OGbAlJCpBkDFtoMsbv9VSxllcd750Nk+HaI9snxW6hw=;
        b=pB/2xP5kY4wuJBPhUoE2I8bcElC13EF79luvae/l9XTi2zxTBpovmlMCmLESGDpRGo
         hj2d0+hSzrNzlSfK+vL/o2zYm2q9nTBiJqn2NmeebFaS4Y9eBTWh5c5Kfp+cx4+DRQJm
         X2aW7KGj+4nc2kT00THrjBIL3lJ+ffP6zjl8dz8iFrNcPGfRoxaR9Eo3aE65ZmHvqfKL
         n8MRkP/ykcJ9I47MPRWiElDqC8hKDRTDT+3uyCWqKTLEK/1kMzlIUobBxFNgfWk+Zo1S
         U+QW8HAvB+BXM23i8wfNo8Ub7bHOedxB12zOkAoz//4hHwBMdSP9k3oxqEB5qIpDSAK+
         VAHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVxUh2C5lGLcXhQCXmPsSFA4yyYuBjPbBdhq6XRvy1WMEhhcKIp
	xnQoPy0nNGgz/im+sAoJuBI5ZNFBRB7hIiP9xNISrU79R/pefamztgQfbxLxKUnGrDSmq9Y+8tH
	OWi0nJsk3OPeADlamyiI2/CKFtiebJQ+bU22X1bpX+6zvdUZuF8s7t/ARkguTHBSN8Q==
X-Received: by 2002:a62:778d:: with SMTP id s135mr45997268pfc.204.1560818228238;
        Mon, 17 Jun 2019 17:37:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydZBORHK/LlgkFbKI18SYlYXl/bcuEXeCQsSTW2OB3935Bch47RYvbuKrnK+6cBD7Ib8Iv
X-Received: by 2002:a62:778d:: with SMTP id s135mr45997223pfc.204.1560818227429;
        Mon, 17 Jun 2019 17:37:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560818227; cv=none;
        d=google.com; s=arc-20160816;
        b=LRTdZJSXfWiQmnkWXoG0m361tY6U35EM8X154CUUf1zogERY0ZPfCTr2AmjJtlysKk
         DL/HoeWT71ZbXGMyAwANFAPilvzYgz5exiSEKjq57l2ToRvcUlzezmroEVTaBll2N/37
         WETaAKt7XLky351sN0ZT4F855MQYbZjo13DYhq9sWDe15owBSYy0B4+YBgZEJJInG4ZM
         fSBbs7sloLaXcxIzCcvQk/m+i1nRVLMAnFwCSFw45ymaJfKNtZGrj3aszmmKJhYSEMiL
         3tMc4VCfMoADHReJvldMKVkGTm622tGMm8TKfVo6mebnnEIrJ6+90h6V7tM7R5SRrlj+
         mkmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=OGbAlJCpBkDFtoMsbv9VSxllcd750Nk+HaI9snxW6hw=;
        b=TjIK/Eznd5sWDi9wFxcleBmwVY76b9DM5NgCW/f8PC4WATn3+NonoljXCTgMbn9gDB
         Mu/AOt7A8e37ktuTp//YJJes8pqw91Kvet3QXn3L9zcbweeZgbMGMJMWIH84rFVUoWeK
         6wAGQ+oPAnuLKad1OXlMYzeq+DBREaPmBZXrRASX+Por32xzhxM+TWsimd2EgG4jt2l6
         FhdwnNr8Ing+d74yma06Mlmz6iuC+8yAuEdU0eK3fvkb8TgX0T+GL9YSzmT4qe8GwEDr
         syvsR7iuerpMfRCOVYApc8Dj9Xm1Cufa5C81SpOozfrkki136cRM1Nf7l5leGl8aYsIg
         J/Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id be11si10907233plb.218.2019.06.17.17.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:37:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 17:37:07 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga007.fm.intel.com with ESMTP; 17 Jun 2019 17:37:06 -0700
Date: Tue, 18 Jun 2019 08:36:42 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com,
	osalvador@suse.de
Subject: Re: [PATCH] mm/sparse: set section nid for hot-add memory
Message-ID: <20190618003642.GA18161@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190616023554.19316-1-richardw.yang@linux.intel.com>
 <0a1704aa-6f5b-6e0b-eb3f-4038c2523aeb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0a1704aa-6f5b-6e0b-eb3f-4038c2523aeb@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 03:13:33PM +0200, David Hildenbrand wrote:
>On 16.06.19 04:35, Wei Yang wrote:
>> section_to_node_table[] is used to record section's node id, which is
>> used in page_to_nid(). While for hot-add memory, this is missed.
>> 
>> BTW, current online_pages works because it leverages nid in memory_block.
>> But the granularity of node id should be mem_section wide.
>
>set_section_nid() is only relevant if the NID is not part of the vmemmaps.
>

Yep, you are right.

>> 
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>> ---
>>  mm/sparse.c | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index fd13166949b5..3ba8f843cb7a 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -735,6 +735,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
>>  	 */
>>  	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
>>  
>> +	set_section_nid(section_nr, nid);
>>  	section_mark_present(ms);
>>  	sparse_init_one_section(ms, section_nr, memmap, usemap);
>>  
>> 
>
>Although I dislike basically all of the current ->nid design, this seems
>to be the right thing to do
>
>Reviewed-by: David Hildenbrand <david@redhat.com>
>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me

