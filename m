Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAC6FC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAB1520663
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 00:46:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAB1520663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CC208E0007; Mon, 17 Jun 2019 20:46:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57BE08E0005; Mon, 17 Jun 2019 20:46:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 491E08E0007; Mon, 17 Jun 2019 20:46:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1294C8E0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 20:46:10 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x3so8777769pgp.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 17:46:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=lhzXK1WLPLGDChV0gJF3Qnp1lG8zH0cbKOjWqB1to2w=;
        b=shSRCfWHSQatbpvHxt+BmpObaGhndyoCxSd3bDhgG2xbduZdQ1LP6ReAOMO8bWtFlb
         B2jFeYE06i0+lFwjZlZVb3NsK2kUvVuY7y5RPxzzt/jm284RybjYviqxQwWu9k/uMMVr
         i4UX5gfXBJGROtSiD4qrS0ncqnI7/nx11WFAOzyXYThrb/avReArLXdxaUlJPueWjJ1O
         bwpPLprhjbmRqYt+ooiHAP9NiPAasB4q2JIzoTc6TRioL3JxUw/zgL5l/qLxmKXgtDSg
         clVfeNn+7POydYVm7CJWjfvH8HR3ApbqYJ/PWoGhDgc27BhOsvkDPUyz/4sMoB4ANAQV
         EF7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWZ+q3O0hjqg93kHA41GRgujLIyPMMjU7Q/GHf1Gz/VXvnLGL3W
	X7zZ+RYqqtaifMkTdNwQDGchIOHdrKYrj50vV/gmDuGmovp2yVOjEPBPNwHeZbXO0MnsjXQsKP+
	8nShJ59ZCo9DUs2TghROxpI4ftpbgcIbDKlyz1X8nhEVDfvxhDbm9LTnFEn2Zou5OBA==
X-Received: by 2002:a63:1462:: with SMTP id 34mr94923pgu.417.1560818769661;
        Mon, 17 Jun 2019 17:46:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8ROtYDzL5DAse7oaEXAjdNEDRs3joEpsjRyL+ENgxQfUNh6/1t/ewG5+TtzMiyxF5vEPJ
X-Received: by 2002:a63:1462:: with SMTP id 34mr94884pgu.417.1560818768988;
        Mon, 17 Jun 2019 17:46:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560818768; cv=none;
        d=google.com; s=arc-20160816;
        b=fqTw6zFOTD3YFMIvV1jOUyCzJyZOqkwd4Cq1W3fO/MXE/mwuNMcIVLzbOBcx3Djj45
         L3KfAygZz653q0SPGDgmDGN6YbS1uz1tv+UgcvYJOtrIlO+DM18nqOJk7R7cZVCzTtJw
         zTpTZJJNvejPjl2D+2oAiJuYiKIgfC3oTj0l3H137zjQZYaGQa97NtWkUqemSvoRet2w
         55U51341xRq9oSrX4O9rN9foGKm5h56FFRZSpKsmGWbMN3U2OWORmaVGDKMTFalo+b09
         rogwcIVAlrTG8MFKhqSZWxadeLhmiQalmBEl3uaieawloFXqAx3Z+AU94pVz1VoEiKGf
         1/Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=lhzXK1WLPLGDChV0gJF3Qnp1lG8zH0cbKOjWqB1to2w=;
        b=XuaD+RHDRCmKoQDGrTNYZ/S3gMkNToRQ08UFHhEwyf+4kztz7INH7oBm+DiC67vEu7
         vuYNRSDBdr6B5I63lhsR6hA/mezzhLKdM0xPvk2EN479kPB52nmtxdGiZ9lHBWutjG6a
         l/sRrRMvkWiOJ6jYpb+E+lH6eMH4TRIXKdIWxV5rC2GHktGSi3hlgMq6gS/mKKUmL0jW
         tLMvwyM0g4uEdnZkF4VjbZookSPVFM45Iv7DYTVQhS3WH4sptV+U+2v/cXj6QI4ui8tN
         3EfhyFHzL1zoFNTeiMkUTK5DeKyKzkmFpNIfJ91dvgUCCp3ITaVmQ6RHF6bM7hHN37Me
         2eHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id n1si8140142pfn.32.2019.06.17.17.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 17:46:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 17:46:08 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga002.jf.intel.com with ESMTP; 17 Jun 2019 17:46:06 -0700
Date: Tue, 18 Jun 2019 08:45:43 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, pasha.tatashin@oracle.com
Subject: Re: [PATCH] mm/sparse: set section nid for hot-add memory
Message-ID: <20190618004543.GB18161@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190616023554.19316-1-richardw.yang@linux.intel.com>
 <20190617154314.GA2407@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617154314.GA2407@linux>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:43:25PM +0200, Oscar Salvador wrote:
>On Sun, Jun 16, 2019 at 10:35:54AM +0800, Wei Yang wrote:
>> section_to_node_table[] is used to record section's node id, which is
>> used in page_to_nid(). While for hot-add memory, this is missed.
>> 
>> BTW, current online_pages works because it leverages nid in memory_block.
>> But the granularity of node id should be mem_section wide.
>> 
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>
>While the patch is valid, I think that the changelog could be improved a bit.
>For example, I would point out the possible problems we can face if it is not set
>properly (e.g: page_to_nid() operations failing to give the right node) and when
>section_to_node_table[] is used (NODE_NOT_IN_PAGE_FLAGS scenario).
>

Thanks, let me give more words on this.

>Reviewed-by: Oscar Salvador <osalvador@suse.de>
>
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
>> -- 
>> 2.19.1
>> 
>
>-- 
>Oscar Salvador
>SUSE L3

-- 
Wei Yang
Help you, Help me

