Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F86BC31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 08:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D447F20673
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 08:32:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D447F20673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 580546B0003; Tue, 18 Jun 2019 04:32:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 530A38E0002; Tue, 18 Jun 2019 04:32:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 446A78E0001; Tue, 18 Jun 2019 04:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 107036B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 04:32:39 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so7392621pld.15
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 01:32:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aCm/I4ok8kJNtkdigJZxqVB+IKiarLZqX6fbYoIgO9E=;
        b=MVKdxXwe2LlPdwiesMBjCMY7/90MzQ/qfMW1lATJVrx0VD0tMAh6VZg0ewnS6/KYH8
         EF5134u2UGsTMmyPdcKYmyN05S+rP0OvRVH0J8MntVc7TTRxJJVcgEcKVRx8eYFNZEi/
         oaF0rVFYO7WMxQEysyO7b5zBj8lUwYgdzLSZep8lJD0yIZmKN/Ep+ODMycAvPAaMv3ui
         XFfmrTbTMQabMF/bYbTkcEgqR9W8Jj+h7BXMq5nx6m8HMipYhToQ2b8M5FcYLm6KWlv4
         38E/2scf1VhPAlixOxxEdcnZjN0JE/JzTvOAoy4aVOzRUFsYdc5yMx4qAf3NmeaQd28c
         RlDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWhg87hvlMlHUIa3G+xplpTxo4TiWr6iLiERsdRj/fxQIlvSfDO
	uatXeVR75trkNvtcskVhyFZ7A5xDvM1AJbrp9+rjHbm8/uPQMTTc3HxRZX1UE6md+04wFkk9hlU
	esZU3WKkq1EhrbGQeniHKltzP9D+PXAZ+gNkhrc+6o3c86TT4w4EKHVXeEEJ6aE+xJQ==
X-Received: by 2002:aa7:9407:: with SMTP id x7mr76938695pfo.163.1560846758593;
        Tue, 18 Jun 2019 01:32:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYu/6kgld8NTYb71s6FCSeeS1KSDApzUfGBvUmmH1ENmtzYpT7gsFjD3ZWZkopvmz8AKLK
X-Received: by 2002:aa7:9407:: with SMTP id x7mr76938606pfo.163.1560846757412;
        Tue, 18 Jun 2019 01:32:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560846757; cv=none;
        d=google.com; s=arc-20160816;
        b=qUaVxYisQhFEJRYO4hjzFmr0rw7+MG3sORp8N28q6jOME/O30MvpIo99GwA1JgOKQh
         30AZWq41FGNYAMncO+USoHcosYJxmPZWo/gqV3yBaOgj2Q3xhfl9pg0FBsQNFtJFfYpq
         mQY/fH40GpHlXyIid1Ah6knvrf/5+vKoT67kJ/E5kXJBATcSMHlZoEHGa3mp3q3MS1Ps
         jfMusZLzqquyVVZwknTGbTWrSqNVVRPtip0YpwyAPH6WJ/X21MwDKCtq4OH3PF6ZaMay
         CTjKdmu+raovx398ewNsz504GaYX0J6bU+ju0CgnwZ9Ih48RJ0GZkGuQLUOobCfuyCQu
         qNRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=aCm/I4ok8kJNtkdigJZxqVB+IKiarLZqX6fbYoIgO9E=;
        b=oIVhAnGyJbakm2s8Oy4AxUYsmLsEk8K83k3/27YAPIh2TVeM0gVEh+nB/ez6g7ZZwL
         GrMnynUitZGCQByb2gC0CMFIsV/ZRCgPxlPl8gfNQAWrKw5TRbasj2Jn1aV7IBT7xySJ
         1AuWRmxS7bQ5XtlLa/4xfGYSl21wAP95bTNV+Ny77se63EYEXpaFYjrBoAlWp7Nm7sy6
         Ilh4XDZ8H0IDF0PMpFNnwSXEHgg4RLICp8LptElRollT4WUsrtF+wlMVI/EGpN//FeXL
         4R8ySGaapRdS3YQlPUzBkuwtP2UQepdkwdFJNxb5IKM9AuMDAtZYw07cLtXrr5Y8wKQL
         T2/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o26si12825404pgv.311.2019.06.18.01.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 01:32:37 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 01:32:36 -0700
X-ExtLoop1: 1
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga008.fm.intel.com with ESMTP; 18 Jun 2019 01:32:35 -0700
Date: Tue, 18 Jun 2019 16:32:12 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
	akpm@linux-foundation.org, david@redhat.com,
	anshuman.khandual@arm.com
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
Message-ID: <20190618083212.GA24738@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618074900.GA10030@linux>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 09:49:48AM +0200, Oscar Salvador wrote:
>On Tue, Jun 18, 2019 at 08:55:37AM +0800, Wei Yang wrote:
>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
>> section_to_node_table[]. While for hot-add memory, this is missed.
>> Without this information, page_to_nid() may not give the right node id.
>> 
>> BTW, current online_pages works because it leverages nid in memory_block.
>> But the granularity of node id should be mem_section wide.
>
>I forgot to ask this before, but why do you mention online_pages here?
>IMHO, it does not add any value to the changelog, and it does not have much
>to do with the matter.
>

Since to me it is a little confused why we don't set the node info but still
could online memory to the correct node. It turns out we leverage the
information in memblock.

>online_pages() works with memblock granularity and not section granularity.
>That memblock is just a hot-added range of memory, worth of either 1 section or multiple
>sections, depending on the arch or on the size of the current memory.
>And we assume that each hot-added memory all belongs to the same node.
>

So I am not clear about the granularity of node id. section based or memblock
based. Or we have two cases:

* for initial memory, section wide
* for hot-add memory, mem_block wide

>
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>> Reviewed-by: David Hildenbrand <david@redhat.com>
>> Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> 
>> ---
>> v2:
>>   * specify the case NODE_NOT_IN_PAGE_FLAGS is effected.
>>   * list one of the victim page_to_nid()
>> 
>> ---
>>  mm/sparse.c | 1 +
>>  1 file changed, 1 insertion(+)
>> 
>> diff --git a/mm/sparse.c b/mm/sparse.c
>> index 4012d7f50010..48fa16038cf5 100644
>> --- a/mm/sparse.c
>> +++ b/mm/sparse.c
>> @@ -733,6 +733,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
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

