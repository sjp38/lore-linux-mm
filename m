Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4109C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:31:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92F652173E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 08:31:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92F652173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BB556B0007; Fri,  9 Aug 2019 04:31:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11E346B0008; Fri,  9 Aug 2019 04:31:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED9506B000A; Fri,  9 Aug 2019 04:31:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id B69EA6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 04:31:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id g126so12821304pgc.22
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 01:31:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=bD8VH95v1y/oTBdRfQfaUFCHRNYYI7+/MU5Yp9lyWqE=;
        b=nao3Swp+c4OzJqyZiHT0LO/zVLouyqTyGsHoz2xEsN25pq4+8IaoVWqVpToHxY2z9v
         2oGnVGnIInAPQar5McsaN4EDl3Ww3m6AD53coKhk658CDcV450UTS4xDWl19ZghOtNfF
         hKk8at5sEaI5DoSgtsk5Mf7UTVgUzBcC6N9LwyQyiwhW07MWJt+alARsqo9jOkUwLCNx
         jQ9sNLiSeJ0P8eJ28w/B45xCm3u2avNhvmOf/JzU1TlpYMsV2YptsPELiWIcconbMth/
         8JOCc8Xj9ev3AXqSfUsmdr7EoGNVP2GH5y8zvGww8nM+mpOWHKSH1g3hzxtXJqruzVW5
         Jc7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVY7GRQPr94/rwM1mz2y16ihsBHo6evEUWx3fHrNlT410zI5nXL
	LGifoait+IQ7CnxI6r7Gc7aZkU/cCxXzO+ZNvoohtMeTRMyvPNQVyRrgzCMdNugtRjBxdIKzy9z
	wtPNYnMs5zsbpIPIG8sxfGLJukOZcQ/CzInUpzhcbfyfVx5VSsXPx2zN8UfAAXDO+aA==
X-Received: by 2002:a63:c246:: with SMTP id l6mr16665784pgg.210.1565339508169;
        Fri, 09 Aug 2019 01:31:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUDGG/Wf6QFYqxK9NI6sabW9Ji2k3kexnIF0AKBJ2XF3TdTioepG9E8XsPAgKpr/DNWwKB
X-Received: by 2002:a63:c246:: with SMTP id l6mr16665739pgg.210.1565339507458;
        Fri, 09 Aug 2019 01:31:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565339507; cv=none;
        d=google.com; s=arc-20160816;
        b=iUjHUWlShMaxSGEU4g7jAv7ukdiBTieic8/c6eg5ywTeZFlyXuQd94jPcXa0NQnT2m
         1N2XLRB7Y9Yu7nBnHZf3BzpVdedffyeW3dIf1S+nPc+x/6YYQvyFaNJbwoPxYsli8eCF
         AOg+clZ+Afl1mbOqHOKcQU1245lXRcj24CMy6bf9fSmSBbt7wfLq1EhIqMMXvIOtTG3V
         z4xswB/erlOknGFbwa2lZAYdP6A9ectQUo9ixcNXoBMAF4gUq7vG6DniZn0xjD1IJPOy
         jrjabZDlNsZxj3JRCvqu6R5Opyf+CEhTPc4//oI/zaUO3NsnekY6grCLnu85mLXV5S3u
         lhLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=bD8VH95v1y/oTBdRfQfaUFCHRNYYI7+/MU5Yp9lyWqE=;
        b=BoWfGEqQlc01tiuxzlOJRGfAGAxO8nbPs9aaKD6I/DxQg/i8jq1youj0kEDHR7phrf
         qitzSfHxPa1foWn9LwewtZNlDRNxkB4Xw8w/eyj/vrV9NPAuocQSV64O91ZL4J54lh9A
         781fiFYWpfe7WHp4/qLwqqqO0R/DCQcR8n27SRfdN5G0q3E4FGj/kBhP4fuZbraa0JMz
         Nx5Vcj+VTa9bQ7uaAZFVbfbt4TxD0TlxmKgniyYM/WFMyfBle0UNQ62r1nYqk8OydGDJ
         iKVSX28rTKoLEAr7uz9xJRZqRKFFLEiVa83Cxpcbjq4NeaqNQaf06tzTVrHjRQDEV6bJ
         dDGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f17si6952689plj.17.2019.08.09.01.31.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 01:31:47 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 01:31:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,364,1559545200"; 
   d="scan'208";a="375132991"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga006.fm.intel.com with ESMTP; 09 Aug 2019 01:31:45 -0700
Date: Fri, 9 Aug 2019 16:31:22 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	mhocko@suse.com, kirill.shutemov@linux.intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm/mmap.c: refine find_vma_prev with rb_last
Message-ID: <20190809083122.GA32128@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190809001928.4950-1-richardw.yang@linux.intel.com>
 <d47ee469-8ff6-d212-9c4b-242079e281e8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d47ee469-8ff6-d212-9c4b-242079e281e8@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 10:03:20AM +0200, Vlastimil Babka wrote:
>On 8/9/19 2:19 AM, Wei Yang wrote:
>> When addr is out of the range of the whole rb_tree, pprev will points to
>> the right-most node. rb_tree facility already provides a helper
>> function, rb_last, to do this task. We can leverage this instead of
>> re-implement it.
>> 
>> This patch refines find_vma_prev with rb_last to make it a little nicer
>> to read.
>> 
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>
>Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
>Nit below:
>
>> ---
>> v2: leverage rb_last
>> ---
>>  mm/mmap.c | 9 +++------
>>  1 file changed, 3 insertions(+), 6 deletions(-)
>> 
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 7e8c3e8ae75f..f7ed0afb994c 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2270,12 +2270,9 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
>>  	if (vma) {
>>  		*pprev = vma->vm_prev;
>>  	} else {
>> -		struct rb_node *rb_node = mm->mm_rb.rb_node;
>> -		*pprev = NULL;
>> -		while (rb_node) {
>> -			*pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
>> -			rb_node = rb_node->rb_right;
>> -		}
>> +		struct rb_node *rb_node = rb_last(&mm->mm_rb);
>> +		*pprev = !rb_node ? NULL :
>> +			 rb_entry(rb_node, struct vm_area_struct, vm_rb);
>
>It's perhaps more common to write it like:
>*pprev = rb_node ? rb_entry(rb_node, struct vm_area_struct, vm_rb) : NULL;
>

Do you prefer me to send v3 with this updated?

>>  	}
>>  	return vma;
>>  }
>> 

-- 
Wei Yang
Help you, Help me

