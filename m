Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18C00C433FF
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:32:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB8BB214C6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:32:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB8BB214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AE196B0003; Tue,  6 Aug 2019 20:32:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 835826B0006; Tue,  6 Aug 2019 20:32:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 724C26B0007; Tue,  6 Aug 2019 20:32:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 394656B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 20:32:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f25so56980148pfk.14
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 17:32:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=G19LaDcw47KOsTDKeBQJ44iiFM5SdGYklrtzM0JqbqM=;
        b=fmrb4xrimx21egsVT5gaD1O9VfmBQR9mit0hks0lM86AYj0bxpmN2UKHhudtJ1qxZX
         BS6V6raR4Z1KAF0shkE6/HfKzCn6FLB9MfA8FOl7VdiZQxF3z90nQWnT7R12qf8SYo22
         qDmAVSWDZLHs6i/VSeC5taNaX6l2DSfMfvmOJxa5XIoOmOzoZnU93AdSEXmguMxUra9A
         hoHuDTkDhrV3oVcdzTvlExSjeFNmX22Et9xI4/ZO2g91Rn5J5KyiawYa+AebAlytfynJ
         LXpSuV3rRbwEHta9dsAZ+og+d4BOoUS78aTnhl3Uvmt2kZIvLLpMJvs/LkI0YRbVIMAx
         X99Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVMsTWPgPuNHcBx6uxqN9q8foU/4Kp+DevFBUrVJGPJrQpntaMo
	0Xuy/btpKCxYFj0aHVFgks3xqFa2Q7ay3fKjgk0iLS++evEfSAY/xL+t+oefi92xO1tW3zgtZj+
	oalk1DsfT32Q6v9nWGMeXfHQ8aHmUAHBrMJUhbNVBxbJeeSbuqRIbYhha8bnzUJesFg==
X-Received: by 2002:a17:90a:de02:: with SMTP id m2mr5794800pjv.18.1565137960869;
        Tue, 06 Aug 2019 17:32:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoPb3OVcuPLbAiiyP5Ce1PSPwHV/qy3G8z2lv4ToMv3cvzKxrDRm9AdxNt86LcuAB4BllP
X-Received: by 2002:a17:90a:de02:: with SMTP id m2mr5794762pjv.18.1565137960237;
        Tue, 06 Aug 2019 17:32:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565137960; cv=none;
        d=google.com; s=arc-20160816;
        b=Gb4qqG3RBK6UPJrBc6qTpQEa83OUDHklL3D2cgPvDR8wNF9AUr6c2WgZsaE/R8wpPi
         BHSQ7hbNIzJX9VO00K8gQOPWMwo07BviqZNU97zliDb9Y7/Bxu4owgV/QQ8k64X+U0Kl
         hm/xH4jCeaYl47znVHmfAven0sTeAWj/hV5p0dBlsEXFwsJMQg9+rUVH0ylpCDsN4WDY
         cOUsBG4ADkNpij5lk3A+rdO1Vop3eDoU6ZDUvm48pcltFTgvqphwS70t3QNBjSN1fFON
         9E/aZsnCdUDcKdnQZwbbuBg9gycrZ2RzBhVZe7QDK8oHD+u/L38D57AFJHBMmpwXrf6Q
         LO1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=G19LaDcw47KOsTDKeBQJ44iiFM5SdGYklrtzM0JqbqM=;
        b=OGNbaVNQodv3EWqpgH+BikHQ5DaUb1PBPeEsUTaiaAt+NZ+S7cOH1Vr1hJRyQ5y7Lk
         yhsuj0CVtaLvlU+ZfX8Tde3/20idB/Rhp/+yjJGz0pplb9ijRZAvmbGPi0KLB2lxc4P9
         Y1cG7i/fNz6Bd+SvHE3ApL15036J+9MKcmOVPHBqlCPobIEmd2xhyMvawWKHTIQ1hCvE
         vNIMgcvYDU3M5HqI3zjxg1Nf8QrfQouO2tJ2V5YNBcTHJIkP47xy/eZY/HP1PTJf4zdm
         KWA0S3xYZtudYDxUGA70a4Ju0G+qEKMKncX6tXk9WmK6qQ0WeWzecj5Wro8OhI4vnfJD
         2Fyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e14si41056182pgg.442.2019.08.06.17.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 17:32:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 17:32:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="185828104"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by orsmga002.jf.intel.com with ESMTP; 06 Aug 2019 17:32:37 -0700
Date: Wed, 7 Aug 2019 08:32:14 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Balbir Singh <sblbir@amzn.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	mhocko@suse.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190807003214.GC24750@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <20190806105822.GA25354@dev-dsk-sblbir-2a-88e651b2.us-west-2.amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806105822.GA25354@dev-dsk-sblbir-2a-88e651b2.us-west-2.amazon.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 10:58:22AM +0000, Balbir Singh wrote:
>On Tue, Aug 06, 2019 at 04:11:23PM +0800, Wei Yang wrote:
>> When addr is out of the range of the whole rb_tree, pprev will points to
>> the biggest node. find_vma_prev gets is by going through the right most
>> node of the tree.
>> 
>> Since only the last node is the one it is looking for, it is not
>> necessary to assign pprev to those middle stage nodes. By assigning
>> pprev to the last node directly, it tries to improve the function
>> locality a little.
>> 
>> Signed-off-by: Wei Yang <richardw.yang@linux.intel.com>
>> ---
>>  mm/mmap.c | 7 +++----
>>  1 file changed, 3 insertions(+), 4 deletions(-)
>> 
>> diff --git a/mm/mmap.c b/mm/mmap.c
>> index 7e8c3e8ae75f..284bc7e51f9c 100644
>> --- a/mm/mmap.c
>> +++ b/mm/mmap.c
>> @@ -2271,11 +2271,10 @@ find_vma_prev(struct mm_struct *mm, unsigned long addr,
>>  		*pprev = vma->vm_prev;
>>  	} else {
>>  		struct rb_node *rb_node = mm->mm_rb.rb_node;
>> -		*pprev = NULL;
>> -		while (rb_node) {
>> -			*pprev = rb_entry(rb_node, struct vm_area_struct, vm_rb);
>> +		while (rb_node && rb_node->rb_right)
>>  			rb_node = rb_node->rb_right;
>> -		}
>> +		*pprev = rb_node ? NULL
>> +			 : rb_entry(rb_node, struct vm_area_struct, vm_rb);
>
>Can rb_node ever be NULL? assuming mm->mm_rb.rb_node is not NULL when we
>enter here
>

My bad, it should be 

	*pprev = !rb_node ? NULL
		 : rb_entry(rb_node, struct vm_area_struct, vm_rb);

Thanks

>Balbir Singh

-- 
Wei Yang
Help you, Help me

