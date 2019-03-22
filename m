Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3C1CC10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:35:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9091321916
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:35:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9091321916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11C1D6B0007; Fri, 22 Mar 2019 10:35:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CC576B0008; Fri, 22 Mar 2019 10:35:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED7306B000A; Fri, 22 Mar 2019 10:35:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C96786B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:35:25 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so2077131qkg.5
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:35:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=pLPPXAfElSV+eLwLcnJGPUAEA79wHbNbWg4yR8J8abI=;
        b=dqzjnBMaXNmFzFN/prl8rxkQp6DPjQX/nDejs4azjIlrv9+OQGWj6+A+brREhKGQLU
         wtk261nT0++aqCPqcVJjkcx/4qlHfXYt0/DcyF7FmYhq34tvYNae4c2d3zLdwvjD3GBS
         ELiYD26jMV9iKDcb5B83PXipof3MC5yuuyXovwlN/e3iO2NVXx+sZFs5Xc9tB0ZO9yxl
         jG8mzE4UXK0K/X5XjTESYhRBE8z3fz2MmZbIVMN76R7bjCuVGziv3LJJVTytJlZtY9xc
         nzVyaCFMwKYSIw2jnFzWPNWcb56i+gHkFUU3yT+g5zve/N8lpjx+SFMesLvmglx3agpU
         RXVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWDrPBkb7p/voiF1SlnNXR+IdBKB0JmHyVSKN2S47CJGVibYypX
	o984zkGjrxlKVmAg2eNYZh/1DLj52lrRfZiya86ZgE3vyB+kuV7I7JpIr7Dzgb5arl0dE+6s2Up
	xF0gYaXSClEKCfJ5zJ0+yragXdvA4Rmt3Oh75ugLZkoT+gHMxsVJtwYHmGxL3sa2wXw==
X-Received: by 2002:ac8:2207:: with SMTP id o7mr8360585qto.376.1553265325463;
        Fri, 22 Mar 2019 07:35:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoSQ+ImVtWlQtOoYQadgiBBrmS82DMp7HSy8eCR2+wyW3fUecHmExLPbg2iH7ObyyGjZnK
X-Received: by 2002:ac8:2207:: with SMTP id o7mr8360504qto.376.1553265324551;
        Fri, 22 Mar 2019 07:35:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553265324; cv=none;
        d=google.com; s=arc-20160816;
        b=S4E1AY8iUlxuanUdjMBByysDawi7oVvEbPMpR/gBZ/CU/xka9DRP0Ea8TYRScu0t3l
         ELKvkJWbA99qC77DLk1A+WnlrAJG2soB4Ao1wdcb+pykwvuQ6Dco/SmVnoSFlnSMeXo7
         xUzOu2poYUq1g+tv5U8ghpAgRvZCjA/wt2tmOTPsOeE1IseX6ua5lcgQadz09X+11i/O
         8DEWtGMbY7MITp8rx6N1PBgHaakwgALugoCfLIrdNAdIWoAZvrU9BRr7wh3EjfPUD8Gd
         qoLY8XVJ7H1gQefDF3q2R49j8CkOJAfJ2g9Ic9a1BwOK+HDFcI2NvReoiTZpd7NcL5Cf
         gpEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=pLPPXAfElSV+eLwLcnJGPUAEA79wHbNbWg4yR8J8abI=;
        b=lbAWHGd6D+fegYih2Edf++a4ykXK7A7B4XWcXCNz2hzMSB294cPe7pKix10wuqCuBP
         J5M/nQYVTMBt7DyKEudfnhufTbZkXKNNUBBFhjAZatlyC+HLBfC3YRCld66AT4SeyQy9
         Cd+qvESmIfKNjoxlfXccaD55xYg2Zh938Sga36u0DwaWKqq0SM0KmeKL3KpjQyfa9tEB
         /wK/ryfshvPIeC4Mc0ivh70yGUUoMQ5CONP1HDSJWxA7GJPv1tsCuVqds1u0NfQq0QB7
         /eb0yGcRr3kjfVNPpZzqaHqwXjnGO+DhmWChCkF1gTKroMfSz1LKiRykIDZMjeW0mE0D
         hSTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k7si4871032qvh.206.2019.03.22.07.35.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 07:35:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 57B723078AB5;
	Fri, 22 Mar 2019 14:35:23 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-47.bos.redhat.com [10.18.17.47])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8F7A219C59;
	Fri, 22 Mar 2019 14:35:18 +0000 (UTC)
Subject: Re: [PATCH 4/4] mm: Do periodic rescheduling when freeing objects in
 kmem_free_up_q()
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, selinux@vger.kernel.org,
 Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
 Eric Paris <eparis@parisplace.org>, Oleg Nesterov <oleg@redhat.com>
References: <20190321214512.11524-1-longman@redhat.com>
 <20190321214512.11524-5-longman@redhat.com>
 <20190321220035.GF7905@worktop.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=longman@redhat.com; prefer-encrypt=mutual; keydata=
 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
 weim8xU=
Organization: Red Hat
Message-ID: <2434d78c-b77c-571d-7add-e111f9d81485@redhat.com>
Date: Fri, 22 Mar 2019 10:35:18 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190321220035.GF7905@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 22 Mar 2019 14:35:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/21/2019 06:00 PM, Peter Zijlstra wrote:
> On Thu, Mar 21, 2019 at 05:45:12PM -0400, Waiman Long wrote:
>> If the freeing queue has many objects, freeing all of them consecutively
>> may cause soft lockup especially on a debug kernel. So kmem_free_up_q()
>> is modified to call cond_resched() if running in the process context.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
>> ---
>>  mm/slab_common.c | 11 ++++++++++-
>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index dba20b4208f1..633a1d0f6d20 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -1622,11 +1622,14 @@ EXPORT_SYMBOL_GPL(kmem_free_q_add);
>>   * kmem_free_up_q - free all the objects in the freeing queue
>>   * @head: freeing queue head
>>   *
>> - * Free all the objects in the freeing queue.
>> + * Free all the objects in the freeing queue. The caller cannot hold any
>> + * non-sleeping locks.
>>   */
>>  void kmem_free_up_q(struct kmem_free_q_head *head)
>>  {
>>  	struct kmem_free_q_node *node, *next;
>> +	bool do_resched = !in_irq();
>> +	int cnt = 0;
>>  
>>  	for (node = head->first; node; node = next) {
>>  		next = node->next;
>> @@ -1634,6 +1637,12 @@ void kmem_free_up_q(struct kmem_free_q_head *head)
>>  			kmem_cache_free(node->cachep, node);
>>  		else
>>  			kfree(node);
>> +		/*
>> +		 * Call cond_resched() every 256 objects freed when in
>> +		 * process context.
>> +		 */
>> +		if (do_resched && !(++cnt & 0xff))
>> +			cond_resched();
> Why not just: cond_resched() ?

cond_resched() calls ___might_sleep(). So it is prudent to check for
process context first to avoid erroneous message. Yes, I can call
cond_resched() after every free. I added the count just to not call it
too frequently.

Cheers,
Longman

