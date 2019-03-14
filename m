Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBB86C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:56:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 963682184C
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 13:56:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 963682184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 306C48E0003; Thu, 14 Mar 2019 09:56:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B54A8E0001; Thu, 14 Mar 2019 09:56:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A55D8E0003; Thu, 14 Mar 2019 09:56:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8AE18E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 09:56:00 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id 190so4656932itv.3
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:56:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=BRj+g5un19Xq209f35ZfyID+NwddZdoqJTeWHtbHKk8=;
        b=hAXfU1T2Wz4zY4psOulOFaxGSRWy+44HC7qb+WNkR1boXGP+66w8YIZLqU7gzKHSW4
         VZnT+i7rAJpJX0QvaKN8PqecVBEbYpRBtHk5bc0JgcYcHHPe4/RIDlbjn22fMPGxxG+l
         qSAhiaZdacg0PEgos7Z3XSN1GUHB+pK52uIZceZDNp2p5PMYlfqx8mXkDrUF4EY/g0nf
         B8vTwebKFOugMKUwxShAlqF0dkrhPCFIRsq5yM5bCrdC9KxoY2rtQOBKDFI1knD04V7U
         YQnsQjvCgEFmT1pNLrcFYm8F/1DoZd/2CxMeE7S05uor5RPZS6en6JR5sjzQrNhqL8Mp
         AMyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAV270KKLaQuK8URj6jiPEb6DRpX3f4u52y+Ub1+2N8UR5pQI9XQ
	aMeSG9NgkdinVJPuXqK/sZ7uYd3e0iiC4NF3FsbPZWZBqnfYFG9es9G2oYZfr8U8widvMfZZgPk
	MPi71v/3pXxd3KI9/kPYEKGNv3IufTkBqg2D7aroXOvOH89OtiKl0eIPo9aA66LI1GQ==
X-Received: by 2002:a24:360d:: with SMTP id l13mr1951169itl.83.1552571760716;
        Thu, 14 Mar 2019 06:56:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxq6VNSqx1CV56Il+Xk+NlWULD6FhtBnDWGPFHV2KV6v/B1ozU0RHYcz3BtiTmE58/QyeDU
X-Received: by 2002:a24:360d:: with SMTP id l13mr1951113itl.83.1552571759596;
        Thu, 14 Mar 2019 06:55:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552571759; cv=none;
        d=google.com; s=arc-20160816;
        b=l3xHLrQSychTMtSLyS8f5VlesffkezRExmM90eB7qZkZvy/gAfI69hoDkOK3Ucbftk
         w6T0gmsyXO3ZktZko+RTEIZadi0j83QTVcAIGq9r15EgLa29GQDMPi56D7ox9QZB3abX
         5M72eS3FTSc5gQ2y2E7wBlwQ8BpGZY91E1iFF7WI00cDLg8oqMY/mfSdJW/66byJT2f1
         ZYQey68Jz9pENlg1O0RDSFCjOQ4K8yUFboFQ6+jGiucaDtHwxfRSXtY+H1iYTZdqPf0/
         0wcLkhTxdxVh7FDvMX1hSzFstAqfOC1u4pcw6v6e+6uuiKSF/Zqd+/Ka55mHQ2rL1S1O
         VoXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=BRj+g5un19Xq209f35ZfyID+NwddZdoqJTeWHtbHKk8=;
        b=r0o3fDVGW3nLYy8ilmycvo4nNJcVS0t2Ppa1o5raVRjADeKeWpkSrKUJDTDRDBLUec
         v4hJn7yBTGKfvGWue99BvAr+tsAEJO/KgKYP36YvysojSnrtoFwAMPhq6KxTM0YZtkq1
         U3ewkR+eR8tZiBWwVxTy/CrEb4qhTkWqPOstFqdupXDdlD8xkC8r58S//tAgMG1UcRom
         /TG3nUzTuJ1gZWvyOBJehWznGySjln0Q9vmwj4/06lcXZ9RV7CXCfeSQoHNcdsOY+Xuq
         +5byIofaVJzkO3GzLr/w0VNkh/bnxHabKyN2j0sgh+7n6jq/I4e6ZOEKJiMkIpV7ts5z
         u7DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j11si6931105ioa.83.2019.03.14.06.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Mar 2019 06:55:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2EDtdqf062838;
	Thu, 14 Mar 2019 22:55:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav107.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp);
 Thu, 14 Mar 2019 22:55:39 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2EDtYnn062822
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 14 Mar 2019 22:55:39 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm,oom: Teach lockdep about oom_lock.
To: Michal Hocko <mhocko@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
References: <1552040522-9085-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190308110325.GF5232@dhcp22.suse.cz>
 <0ada8109-19a7-6d9c-8420-45f32811c6aa@i-love.sakura.ne.jp>
 <20190308115413.GI5232@dhcp22.suse.cz> <20190308115802.GJ5232@dhcp22.suse.cz>
 <20190308150105.GZ32494@hirez.programming.kicks-ass.net>
 <20190308151327.GU5232@dhcp22.suse.cz>
 <dd3c9f12-84e9-7cf8-1d24-02a9cfbcd509@i-love.sakura.ne.jp>
 <20190311103012.GB5232@dhcp22.suse.cz>
 <d9b49a08-5d5a-ec4a-7cb7-c268999a9906@i-love.sakura.ne.jp>
 <20190312153140.GU5721@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <195f38a9-5409-180c-2ccc-807942ab1994@i-love.sakura.ne.jp>
Date: Thu, 14 Mar 2019 22:55:34 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190312153140.GU5721@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/13 0:31, Michal Hocko wrote:
>> @@ -1120,8 +1129,25 @@ void pagefault_out_of_memory(void)
>>  	if (mem_cgroup_oom_synchronize(true))
>>  		return;
>>  
>> -	if (!mutex_trylock(&oom_lock))
>> +	if (!mutex_trylock(&oom_lock)) {
>> +		/*
>> +		 * This corresponds to prepare_alloc_pages(). Lockdep will
>> +		 * complain if e.g. OOM notifier for global OOM by error
>> +		 * triggered pagefault OOM path.
>> +		 */
>> +		oom_reclaim_acquire(GFP_KERNEL);
>> +		oom_reclaim_release(GFP_KERNEL);
>>  		return;
>> +	}
>> +	/*
>> +	 * Teach lockdep to consider that current thread is not allowed to
>> +	 * involve (even indirectly via dependency) __GFP_DIRECT_RECLAIM &&
>> +	 * !__GFP_NORETRY allocation from this function, for such allocation
>> +	 * will have to wait for completion of this function when
>> +	 * __alloc_pages_may_oom() is called.
>> +	 */
>> +	oom_reclaim_release(GFP_KERNEL);
>> +	oom_reclaim_acquire(GFP_KERNEL);
> 
> This part is not really clear to me. Why do you release&acquire when
> mutex_trylock just acquire the lock? If this is really needed then this
> should be put into the comment.

I think there is a reason lockdep needs to distinguish trylock and lock.
I don't know how lockdep utilizes "trylock or lock" information upon validation, but
explicitly telling lockdep that "oom_lock acts as if held by lock" should not harm.

#define mutex_acquire(l, s, t, i)               lock_acquire_exclusive(l, s, t, NULL, i)
#define lock_acquire_exclusive(l, s, t, n, i)           lock_acquire(l, s, t, 0, 1, n, i)
void lock_acquire(struct lockdep_map *lock, unsigned int subclass, int trylock, int read, int check, struct lockdep_map *nest_lock, unsigned long ip);

> 
>>  	out_of_memory(&oc);
>>  	mutex_unlock(&oom_lock);
>>  }
> 

