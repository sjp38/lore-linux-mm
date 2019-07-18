Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF89C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:47:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C54221849
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 14:47:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C54221849
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D8F46B000A; Thu, 18 Jul 2019 10:47:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 713448E0003; Thu, 18 Jul 2019 10:47:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 602288E0001; Thu, 18 Jul 2019 10:47:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AB2F06B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 10:47:46 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id y22so14020321plr.20
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 07:47:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KZsAY8nek+nSTjaeBYHbU6Z91grtiEsuPi63exZ2uLU=;
        b=VdgFJwH6h3o19C3Yv5Cwnu5WxTYciK5L1QWROBvpkIAq+oWlJTz/Mc1ByWE98U0YfI
         SUo8ncvr2pHWO2n5dLrBm+OOnj4eQiP8lwdKWFG5A7TbnsxqGd9yRflb6b9AT/Q848Op
         BxDqwpLbZy5qfo+KC5NK0z+agZnioDdpUyL1xhPZcwA4ea/Y0yMyTXQIkEHyL/0zrnzR
         2eCuGVVasILh0w105k3a8ANUVdIn2y5tyyJqDhT85LPP1QhLCrJBDnHo1XpM522QNFAR
         6X3NB61/uvg0YQADYPapQMe1Zl0xdYd0AOEyjddTF+CVN2jl1POChYDMCtDSzyJehIh0
         LgAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAWXhL9QovTp+h22KW4b3YX2u4y5Vd56s98i1fQm+RYI1owlKW0L
	bZ+5MgzheWjKM/IyK5mzJaWSUVwg91VJ1g3jw6Xdv4vSnAalS0Rcm9wFBTdhsZP/JfdiWIXgipq
	d+bWijnk/24p+r2gug1GzG+AOtHG2rvwWaCfaSWUjVjT85dGQZMD+vGi26sLGZvjuBg==
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr48731406plb.203.1563461266327;
        Thu, 18 Jul 2019 07:47:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEXG4GgMSdErnrOReYJ3WNX8m+aIZP4gFlGbM5jotC7HqgECu10OJe+g+SsB4n1C2AlZWj
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr48731343plb.203.1563461265367;
        Thu, 18 Jul 2019 07:47:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563461265; cv=none;
        d=google.com; s=arc-20160816;
        b=XNeUKGD+/730UGLwkOzqXcQX6s1EMJvTQdr3bITpHlbnzVSFhEmTD33ywl53tANKSL
         nWwBs9SkVzHcTNTxPAAXfLmOMpMzS+QllT06mamacaCBSCwDeEazgKJr2T/g1DlXoAmh
         wyyg/74HdRyP888hyXqyinLQHGUowNUla7+XfLLz+cXmbMxtTAaNxm8KRThiQopK7FHW
         /alTTiTTOL4hpSjYEtJgwoVfOWv2CLZgV/4cyfrhkCDNTkCgdisLJSM3DTUnvf1P+z9O
         Qnm1Ic61NCLeDKOMHcgqK/cBzJKHKz9ne2j1ynoV9bssvlMFv7sTdAkqYTRgvj37vlSs
         2zEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=KZsAY8nek+nSTjaeBYHbU6Z91grtiEsuPi63exZ2uLU=;
        b=frmy4FiQz/gySK97MXqSrmEQ1uZNNSLJt9U+3zeTG0dfZuBUsKnP8TRKf4fG5LN2KU
         i4X8y+iKAHg3utJSKyeSY1k0JAH/TSir4i0dcaW31LuWlSUCFwE7SohpVGwRcem8OOZb
         fSz0Op3gc7+3kxSCckHaBxp9PKTB9baNX2IXHiUdY5G+bXs5sTCU+Pq6pjFbGyR5R0OO
         hE6vhDIZ1jQpVInju4YN8dmUHYKoyD1BP1r8tf1tRVcjLgx+TYaI6uEuI1urD0ywUUBE
         /0C0PJ78jguRch/GYAn9k/Wa2qD0Ez9FU6nRAAQ+1quq6QrzejemctTx4JcvfQE+Sea+
         AjJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z5si2077321plo.434.2019.07.18.07.47.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 07:47:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav303.sakura.ne.jp (fsav303.sakura.ne.jp [153.120.85.134])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6IDoKAJ016195;
	Thu, 18 Jul 2019 22:50:20 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav303.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp);
 Thu, 18 Jul 2019 22:50:19 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav303.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6IDoJ60016190
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Thu, 18 Jul 2019 22:50:19 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
To: Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, Roman Gushchin <guro@fb.com>,
        Shakeel Butt <shakeelb@google.com>,
        Andrew Morton
 <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190718083014.GB30461@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <7478e014-e5ce-504c-34b6-f2f9da952600@i-love.sakura.ne.jp>
Date: Thu, 18 Jul 2019 22:50:14 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190718083014.GB30461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/18 17:30, Michal Hocko wrote:
> On Wed 17-07-19 19:55:01, Tetsuo Handa wrote:
>> Currently dump_tasks() might call printk() for many thousands times under
>> RCU, which might take many minutes for slow consoles.
> 
> Is is even wise to enable dumping tasks on systems with thousands of
> tasks and slow consoles? I mean you still have to call printk that is
> slow that many times. So why do we actually care? Because of RCU stall
> warnings?
> 

That's a stupid question. WE DO CARE.
We are making efforts for avoid calling printk() on each thread group (e.g.

  commit 0c1b2d783cf34324 ("mm/oom_kill: remove the wrong fatal_signal_pending() check in oom_kill_process()")
  commit b2b469939e934587 ("proc, oom: do not report alien mms when setting oom_score_adj"))

) under RCU and this patch is one of them (except that we can't remove
printk() for dump_tasks() case).

