Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A4CEC31E40
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:31:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DF75214C6
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 00:31:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DF75214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06EF36B0003; Tue,  6 Aug 2019 20:31:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01F446B0006; Tue,  6 Aug 2019 20:31:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E77C66B0007; Tue,  6 Aug 2019 20:31:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B08CA6B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 20:31:35 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id b18so55937069pgg.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 17:31:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=SySmh9v0GsDAOq2yi8gIRmrsRpj1/7GNlPLQ68dhFiA=;
        b=YPujIxndJDmbpcz0V7RzW61aWycUJqQLjssTE+yn9zTK1yrSRxQ4gIs7xVuCGsw1Jv
         ZTbpWyJUCxGfXgTWEuGe2gmLEthl3MtDfSTczRJAt55O4z1WIOE8VhzU/rbikvaOkKgA
         GsPkIgoESBoDFc2wpOCRBJVftO7tZPP+2YRfDjvrnbK+02/FjzOravUknp+/yLxHzLVu
         kPmWWLC3XPujiLH9sG9eR+lY6J1wX2ifwD8BNkOv0SV76uRE6m6owAfV0JLRHnzlWC2W
         6HmWG21pupVjTbz8r2Z/XQH1hcH9PgAwh/9ttZl3/0wb2r6JxKCdDkZ7Oa2r1I9B1NvD
         NS+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWy43iNXVu3wgbPHZ58N0TwoL11/AwzZQ6K4gDkMMnM8kQ8RaTs
	6UzXP7adwv5FQjEqj6uXKQ8RE6GkmSAnr1wvyj5vIUfnyERpveoPn/FLNSfELHdQFa8pXwO0wwR
	BENN6f0RHgHQ+RyjbYSgqZAe812j/1TlHYXR+3hRQP4J0BhvrTRSj+B9jKr7bqtJM+Q==
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr5841778pje.33.1565137895221;
        Tue, 06 Aug 2019 17:31:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQvdE4uWmt6mpGg69mPAhaeYM1QRGcjn4ePIPm1bjSVGX5k0EVXXJjOKPCyiuyxTBoRRi2
X-Received: by 2002:a17:90a:220a:: with SMTP id c10mr5841718pje.33.1565137894195;
        Tue, 06 Aug 2019 17:31:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565137894; cv=none;
        d=google.com; s=arc-20160816;
        b=dPbaP1jhfJVbOrZD7K49VNCSVCG59MdSPy7yowtvKhyqlen/LcJFKqPTsGP4cTRHse
         NC9TLvWD6MEOVuSo9gGTjryfdNMQ23hKbLgBKw7ajylvaL7ogMJM19pAhMV8DiVGzBfq
         TRkJyS18kGoZtXgGK+45arFgu5LU+TUm6ydL9YmLRyNtpv/SJ7vcPNDyxqH45YOyFA85
         m0gkMaJg7OikUy5kGZAfhSLK0tMIweMt7xlRfGXF+hDSvCT02gg+RsVc+Td1Snhl93wH
         guqSk32fRaBflKFx4Pqhxr00E2dgraKTGzxVwzrReXOc9chUj8FNqh11jyq2uoDLZ3ge
         omWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date;
        bh=SySmh9v0GsDAOq2yi8gIRmrsRpj1/7GNlPLQ68dhFiA=;
        b=GohRH6FoNtK7dcqzSaJHyymSxHvj5G/6v7u7Asrt4yamQeBnj68UiwBYig1zIUAb0b
         FuvXmNXJnDjpyH/uEc+40AdhwXYd7bs66cNB08jZmKtgIKpXoPJpVkvm9sYfKWgkjNr8
         0upLNvWHH5SP9rJ4rSkK9jC5MD3JVyzJV8whzJdXGMDTKUXLflAPXx7AbJZVRlVNEGOG
         6Hrr7Z/IWUMk+TxriOKlJ/iwAKH1fXPvefQMfZNuY0TekDgx7gcc3K7l8syA2ysb8Tog
         d7tV1agOv2EbrTcqBAbBigVG6yWKqzvxij1nqkAkyWRkfNXc7hdTJdwBYhCNWC734Dad
         2Vwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a65si22047403pgc.213.2019.08.06.17.31.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 17:31:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of richardw.yang@linux.intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=richardw.yang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 17:31:33 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="176033856"
Received: from richard.sh.intel.com (HELO localhost) ([10.239.159.54])
  by fmsmga007.fm.intel.com with ESMTP; 06 Aug 2019 17:31:31 -0700
Date: Wed, 7 Aug 2019 08:31:09 +0800
From: Wei Yang <richardw.yang@linux.intel.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richardw.yang@linux.intel.com>, akpm@linux-foundation.org,
	mhocko@suse.com, kirill.shutemov@linux.intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/mmap.c: refine data locality of find_vma_prev
Message-ID: <20190807003109.GB24750@richard>
Reply-To: Wei Yang <richardw.yang@linux.intel.com>
References: <20190806081123.22334-1-richardw.yang@linux.intel.com>
 <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3e57ba64-732b-d5be-1ad6-eecc731ef405@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 11:29:52AM +0200, Vlastimil Babka wrote:
>On 8/6/19 10:11 AM, Wei Yang wrote:
>> When addr is out of the range of the whole rb_tree, pprev will points to
>> the biggest node. find_vma_prev gets is by going through the right most
>
>s/biggest/last/ ? or right-most?
>
>> node of the tree.
>> 
>> Since only the last node is the one it is looking for, it is not
>> necessary to assign pprev to those middle stage nodes. By assigning
>> pprev to the last node directly, it tries to improve the function
>> locality a little.
>
>In the end, it will always write to the cacheline of pprev. The caller has most
>likely have it on stack, so it's already hot, and there's no other CPU stealing
>it. So I don't understand where the improved locality comes from. The compiler
>can also optimize the patched code so the assembly is identical to the previous
>code, or vice versa. Did you check for differences?

Vlastimil

Thanks for your comment.

I believe you get a point. I may not use the word locality. This patch tries
to reduce some unnecessary assignment of pprev.

Original code would assign the value on each node during iteration, this is
what I want to reduce.

The generated code looks different from my side. Would you mind sharing me how
you compare the generated code?

>
>The previous code is somewhat more obvious to me, so unless I'm missing
>something, readability and less churn suggests to not change.
>
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
>>  	}
>>  	return vma;
>>  }
>> 

-- 
Wei Yang
Help you, Help me

