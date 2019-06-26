Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29221C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 11:46:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9AD6204FD
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 11:46:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9AD6204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EBE66B0003; Wed, 26 Jun 2019 07:46:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29C5D8E0003; Wed, 26 Jun 2019 07:46:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18BCA8E0002; Wed, 26 Jun 2019 07:46:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2A606B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 07:46:11 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id i11so1475161pgt.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:46:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LF4Q8Xl1kQUAAMWqPztMgPI5BDA+/HmVsh+AS0T/ixU=;
        b=Ypz5S422IR+MF4zWo9Ii5ReukCBOY+x47GbN50NBgE98yrdAnvJ95VS11ilJVhgK87
         QAlKc//vASdBIiBC1bXH69nlEYgw4Zsy7rXaPn4pfsr1TG2dcvSUNB8nUDTpSDuJiFW7
         3tYRKdTsvgh6Cbeea6sqElhmoVUvuEV3A1CmIYetMOde7O3ey2j3glkkNhfYCDvVvvW2
         ZlDiVs90OoiPMhbcAlDzs7WTfARpUGZg43HIKyVTY8o7B/c8CNRCqCpRbw3INSxwNy8n
         GN+JAlaZo7+MumUraA1OF33tdTQdgWGY0E/ylMSl6dD8UuKj3/e32t3lxql4Iz0WeAJU
         A2Gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWFqWsom1NsNJQQ/L2NSPF0jocktjgbXCV7/xEow6QE+XPbgFBR
	DpnHvTDqGbNYOKzKnq/VX/Ykm6UDplp1EzhH/PnsF1taU+O1Vu6+BpGtXMXMU/Hevw4tzXDC+oy
	FMwSAYVbaRKLXCDPe4H7pICE4dQc5UgK8gkvz+X1w5Rv6Mc2IaDUrwTowF7xTO7E6OA==
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr4223554pjc.4.1561549571497;
        Wed, 26 Jun 2019 04:46:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5qwxzr8GIW3ArMsa6z1cE26OollumwUfC6W97TrA6ejPt0XRVy5WBR/Xwverdh1txvzwb
X-Received: by 2002:a17:90a:2008:: with SMTP id n8mr4223472pjc.4.1561549570627;
        Wed, 26 Jun 2019 04:46:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561549570; cv=none;
        d=google.com; s=arc-20160816;
        b=KDdry4RB1aPjgUafePqsQ4/5AkcmHns7csjn5FERMhuV+Lr6JPR3OJhi1YBodxEarA
         hmNNUNOUsyAV+8u5EzyZAJMxbDnJDFzimDX4onNB9TfpicVlBeVUpdaKiG6Ths4H7T54
         mKDjsNoSB0U82tinb1LmVIe7/X+sTqJog2NFkiEj5crLVY3cAAYoI0Pc7AVTE25yf9RE
         kDqoSDIhXmsa50PhMXQDkgxHSH9UIZdZ0//7KfEO8fCqYrLI8bmQBf/oz7alXd0AwgNO
         n9SBcLIOIl+oP1+Tp2pHxNvpIFRIwlIo4T/Yq+Z+mprmcp/JSW8mBscvs2zseEL0FkEV
         AGpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=LF4Q8Xl1kQUAAMWqPztMgPI5BDA+/HmVsh+AS0T/ixU=;
        b=QwPuO+rUujV5y9exvBi9lTc1nTaSXGpyrUzQ1lZZh9R8+4zWfZ1XDFnkq89Cq4hVea
         hV3NLc31nt6lX5zEPmefIVkm93b7FhYW4pfjYkpmg7euI0VUW4cFspJV0KO3bhKkPtu0
         /YhtKwQqyP25UVOeJziim81yItHaXh5g4tZCLCnBTHKYLTnM5QV9VVyvB3h+4LBw4NCH
         cCnIQWMJ9eCWUZsQBL+IFQOiSalZ5OOYOu1mVVOn0XSPz22hE6B5HR89+xJei5zXjO3y
         +TlA9pc9+dVP4skeSk2O2uCEAqQ0Smel1nBQr5OsRWF6Jv8hh+OPvbMNE/X23o9UcaxV
         DS1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c82si18048285pfb.32.2019.06.26.04.46.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 04:46:10 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav102.sakura.ne.jp (fsav102.sakura.ne.jp [27.133.134.229])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5QBk3Rx085937;
	Wed, 26 Jun 2019 20:46:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav102.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav102.sakura.ne.jp);
 Wed, 26 Jun 2019 20:46:03 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav102.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5QBk30s085932
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 26 Jun 2019 20:46:03 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH v3 3/3] oom: decouple mems_allowed from
 oom_unkillable_task
To: Michal Hocko <mhocko@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org
References: <20190624212631.87212-1-shakeelb@google.com>
 <20190624212631.87212-3-shakeelb@google.com>
 <20190626065118.GJ17798@dhcp22.suse.cz>
 <a94acd91-2bae-0634-b8a4-d5c8674b54f2@i-love.sakura.ne.jp>
 <20190626104737.GQ17798@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <3ec3304f-7d3f-cb08-5635-12c6b9c0905c@i-love.sakura.ne.jp>
Date: Wed, 26 Jun 2019 20:46:02 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190626104737.GQ17798@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/26 19:47, Michal Hocko wrote:
> On Wed 26-06-19 19:19:20, Tetsuo Handa wrote:
>> Is "mempolicy_nodemask_intersects(tsk) returning true when tsk already
>> passed mpol_put_task_policy(tsk) in do_exit()" what we want?
>>
>> If tsk is an already exit()ed thread group leader, that thread group is
>> needlessly selected by the OOM killer because mpol_put_task_policy()
>> returns true?
> 
> I am sorry but I do not really see how this is related to this
> particular patch. Are you suggesting that has_intersects_mems_allowed is
> racy? More racy now?

I'm suspecting the correctness of has_intersects_mems_allowed().
If mask != NULL, mempolicy_nodemask_intersects() is called on each thread in
"start" thread group. And as soon as mempolicy_nodemask_intersects(tsk) returned
true, has_intersects_mems_allowed(start) returns true and "start" is considered
as an OOM victim candidate. And if one of threads in "tsk" thread group has already
passed mpol_put_task_policy(tsk) in do_exit() (e.g. dead thread group leader),
mempolicy_nodemask_intersects(tsk) returns true because tsk->mempolicy == NULL.

I don't know how mempolicy works, but can mempolicy be configured differently for
per a thread basis? If each thread in "start" thread group cannot have different
mempolicy->mode, there is (mostly) no need to use for_each_thread() at
has_intersects_mems_allowed(). Instead, we can use find_lock_task_mm(start)
(provided that MMF_OOM_SKIP is checked like

 	/* p may not have freeable memory in nodemask */
-	if (!is_memcg_oom(oc) && !has_intersects_mems_allowed(task, oc))
+	if (!tsk_is_oom_victim(task) && !is_memcg_oom(oc) && !is_sysrq_oom(oc) &&
+	    !has_intersects_mems_allowed(task, oc))
 		goto next;

) because find_lock_task_mm() == NULL thread groups won't be selected as
an OOM victim candidate...

