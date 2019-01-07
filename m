Return-Path: <SRS0=+lVK=PP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCB13C43387
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 07:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 462ED2085A
	for <linux-mm@archiver.kernel.org>; Mon,  7 Jan 2019 07:31:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 462ED2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=windriver.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8EF28E0009; Mon,  7 Jan 2019 02:31:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3DB08E0001; Mon,  7 Jan 2019 02:31:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 956A28E0009; Mon,  7 Jan 2019 02:31:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 536F58E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 02:31:32 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id j8so31345575plb.1
        for <linux-mm@kvack.org>; Sun, 06 Jan 2019 23:31:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=osfVfAN6sk7BBFrB+BYASlCwB+j+pdLBsMY/18N8aJM=;
        b=jXmCKhxhf60pyz3y1PydxJUXg/hsxuo9wg+TAsPswNH8yL8gOdjxEzNodQgVizVGsr
         kGQjN1Q2hQUjLwcY/ABNmXCqvPktpxTG+27+g+d4T3r3BrpzZmRSKplAnGAWwzi5GlCe
         ahzBMIYuB2e92QiX5CWV5eQ5GxVcmYSY90WJbNBkW25UK6gU3WbuP3zzsJxneSP4r1kr
         WJpFZ9Vx3YLm1mNIeC84McGY3+GVF/qSGqFEg22XBQr2/aBlLckg+/NkuRueFO1zU6d3
         ilzl9J51Yor4DsyvLG4b/1pie7ca4oeH02oMP7d8xFQBjvqArdt5WTYxBllS0dd5sjPn
         IiQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhe.he@windriver.com designates 147.11.1.11 as permitted sender) smtp.mailfrom=Zhe.He@windriver.com
X-Gm-Message-State: AJcUukegbKp0JqZ4Yd+al4+uxrMxFHtftlntC85MQzEIZX6gfxWPkhMl
	5hb3nNFYXRiCJUX5Oyf5iaSJhGeyJf3Q2KxGFuJJ1A8W+YJHhr9SAtUvMIOpJOB9QadRXobHZnx
	Zr35+TeD/RqP1HA1G1UJbUsEoMBOn2/y49ph+9HtXcZnct3UqG+kT0FRU2GNgfpzphQ==
X-Received: by 2002:a63:3287:: with SMTP id y129mr10132810pgy.337.1546846291859;
        Sun, 06 Jan 2019 23:31:31 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6DGp2m9TJujCOYWkvVV0t17Z1zDEe7MDAWfk24OoyoqlWCIex3XXc1bK9JyH4ztKcMQOVt
X-Received: by 2002:a63:3287:: with SMTP id y129mr10132757pgy.337.1546846290909;
        Sun, 06 Jan 2019 23:31:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546846290; cv=none;
        d=google.com; s=arc-20160816;
        b=yaHIdKzIk3nDD567p1xFuA1bMHRIn1R7YWhBKGwHti5B8+wq7dio5FUGAtmcRS3FM0
         5d08w4uicSVk3iVMQWHBkq69QmM1QLnOvxfMgBRjoCe53o3L63OpB08FoO9WTUnUeib0
         f3QYj67Bl9iT4r+8IdgifO4egn5mUclYha8jZObQm3+zbCVoBl2nObTnvsUqDRWzgGZv
         F2VvkMeFUs34PhB927S26mIdXd6S6Kza+FLM14yWDaoN1W5jo1ShqyCU9niV/pABsLK+
         hFDFS1z3Q7pTKudyXi7Tz1ypJW5dSKwHCwmE4fBIdLIFXS9xpFIrskJ3FD4M3ftJudoC
         pcDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=osfVfAN6sk7BBFrB+BYASlCwB+j+pdLBsMY/18N8aJM=;
        b=iINr6YNXtHWxNzQnMRVOJ1XdKKv1kIR0R1SLDmZlUb9ixu2XjbbHDYNgz0MKNUWtaC
         tqg0sawJqiCJfWW/TYZI4L/Yg7v1xPmtZbsQHRTY/18Ep8FWMColtrOrN3zuGGAQ7Fpb
         UW5gS5yNAltNhD4XZ5ghl6fSXhkXsOp3JMnKuOXAxLwlaNuV9CJHhnjz+AWheWjRMe5U
         XigkNyN3Ll5wBLOXBoRNpcJ+iUm+b1XPa7ugqlYNEKxGIlUAo4Y3JKMmWjEGMUmfjKs/
         RkfSDe5Sy4dK34vO86Fn6jESJ0NCYSW63lMGwA6jUNQOin5qmnEWDi9m/Yf4TeyVg1Cd
         hLqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhe.he@windriver.com designates 147.11.1.11 as permitted sender) smtp.mailfrom=Zhe.He@windriver.com
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id k5si12736984plt.111.2019.01.06.23.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 06 Jan 2019 23:31:30 -0800 (PST)
Received-SPF: pass (google.com: domain of zhe.he@windriver.com designates 147.11.1.11 as permitted sender) client-ip=147.11.1.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhe.he@windriver.com designates 147.11.1.11 as permitted sender) smtp.mailfrom=Zhe.He@windriver.com
Received: from ALA-HCA.corp.ad.wrs.com ([147.11.189.40])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTPS id x077VMIc020188
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL);
	Sun, 6 Jan 2019 23:31:22 -0800 (PST)
Received: from [128.224.162.180] (128.224.162.180) by ALA-HCA.corp.ad.wrs.com
 (147.11.189.50) with Microsoft SMTP Server (TLS) id 14.3.408.0; Sun, 6 Jan
 2019 23:31:21 -0800
Subject: Re: [PATCH] mm: kmemleak: Turn kmemleak_lock to spin lock and RCU
 primitives
To: Catalin Marinas <catalin.marinas@arm.com>, <paulmck@linux.ibm.com>,
        <josh@joshtriplett.org>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
References: <1546612153-451172-1-git-send-email-zhe.he@windriver.com>
 <20190104183715.GC187360@arrakis.emea.arm.com>
From: He Zhe <zhe.he@windriver.com>
Message-ID: <f923e9e9-ed73-5054-3d82-b2244c67a65e@windriver.com>
Date: Mon, 7 Jan 2019 15:31:18 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.2.1
MIME-Version: 1.0
In-Reply-To: <20190104183715.GC187360@arrakis.emea.arm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Originating-IP: [128.224.162.180]
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190107073118.0WvjC1yLjCnGx9APxdRsN2FGwYCeo5goRfE62UEK-IE@z>



On 1/5/19 2:37 AM, Catalin Marinas wrote:
> On Fri, Jan 04, 2019 at 10:29:13PM +0800, zhe.he@windriver.com wrote:
>> It's not necessary to keep consistency between readers and writers of
>> kmemleak_lock. RCU is more proper for this case. And in order to gain better
>> performance, we turn the reader locks to RCU read locks and writer locks to
>> normal spin locks.
> This won't work.
>
>> @@ -515,9 +515,7 @@ static struct kmemleak_object *find_and_get_object(unsigned long ptr, int alias)
>>  	struct kmemleak_object *object;
>>  
>>  	rcu_read_lock();
>> -	read_lock_irqsave(&kmemleak_lock, flags);
>>  	object = lookup_object(ptr, alias);
>> -	read_unlock_irqrestore(&kmemleak_lock, flags);
> The comment on lookup_object() states that the kmemleak_lock must be
> held. That's because we don't have an RCU-like mechanism for removing
> removing objects from the object_tree_root:
>
>>  
>>  	/* check whether the object is still available */
>>  	if (object && !get_object(object))
>> @@ -537,13 +535,13 @@ static struct kmemleak_object *find_and_remove_object(unsigned long ptr, int ali
>>  	unsigned long flags;
>>  	struct kmemleak_object *object;
>>  
>> -	write_lock_irqsave(&kmemleak_lock, flags);
>> +	spin_lock_irqsave(&kmemleak_lock, flags);
>>  	object = lookup_object(ptr, alias);
>>  	if (object) {
>>  		rb_erase(&object->rb_node, &object_tree_root);
>>  		list_del_rcu(&object->object_list);
>>  	}
>> -	write_unlock_irqrestore(&kmemleak_lock, flags);
>> +	spin_unlock_irqrestore(&kmemleak_lock, flags);
> So here, while list removal is RCU-safe, rb_erase() is not.
>
> If you have time to implement an rb_erase_rcu(), than we could reduce
> the locking in kmemleak.

Thanks, I really neglected that rb_erase is not RCU-safe here.

I'm not sure if it is practically possible to implement rb_erase_rcu. Here
is my concern:
In the code paths starting from rb_erase, the tree is tweaked at many
places, in both __rb_erase_augmented and ____rb_erase_color. To my
understanding, there are many intermediate versions of the tree
during the erasion. In some of the versions, the tree is incomplete, i.e.
some nodes(not the one to be deleted) are invisible to readers. I'm not
sure if this is acceptable as an RCU implementation. Does it mean we
need to form a rb_erase_rcu from scratch?

And are there any other concerns about this attempt?

Let me add RCU supporters Paul and Josh here. Your advice would be
highly appreciated.

Thanks,
Zhe


>

