Return-Path: <SRS0=AzIT=P5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5DBAC312E1
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 01:23:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6A27217D4
	for <linux-mm@archiver.kernel.org>; Mon, 21 Jan 2019 01:23:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6A27217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C7EC8E0003; Sun, 20 Jan 2019 20:23:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278388E0001; Sun, 20 Jan 2019 20:23:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18DE68E0003; Sun, 20 Jan 2019 20:23:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3C818E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 20:23:37 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id n22so7643321otq.8
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 17:23:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:mime-version:date:references:in-reply-to
         :content-transfer-encoding;
        bh=IrpDpQRmv2ZJkZZHibl5FPTqOC+BpdBcNVZHRa2MjVg=;
        b=qnhwRg2dvL9u6q1QVSTTKRKR58ZTdw3XWWbRRqaGjNuUIk3Kg6ezFjF+Ooto7VXlER
         agF0VXKP6vRWmem2Fz0wKZIMWYrPk7zsqzjiAhsiosjtzknkNaRCW1QZSjTXgPYTjEJM
         ub5JHS6R7Dpm99j21+Cq1JFslH+JDHNNvGYYMUQfFwAZ/r3BOkGfeJRHcypDKIc2KCMx
         M/yVc5ELLCcyQCBYvC8i54TAgR09LZxkVFUnOrlSHxtFURM9TUErSpdKLYeeJbAPRxaN
         IBvqa0FJ4bFhK/3BrhcP0cQ99hxS3fDZl/FSOOfyXs4B3c3Qq6+oRKxaX9t8FoQ73KYk
         lzSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukeRybmdfGLUyofBw8wDlt87DqgQgFniB+G7jxXCQku05yHEMHAP
	e9yjTOfBPzSYtVSUitSgzV6uAXuVNeEKE9CpXXjwwS/dmXSoeEBVTx9HjrQzhRjO0vwLo1fQzK+
	5nVhRIb1pUzLPBZCVBz3GTYPXujbQIg2inpWpi+KWoE0v8BzkwYyJ/F03Yj6ias+vQQ==
X-Received: by 2002:a9d:2015:: with SMTP id n21mr18955663ota.289.1548033817551;
        Sun, 20 Jan 2019 17:23:37 -0800 (PST)
X-Google-Smtp-Source: ALg8bN60cM06Dkwt1VA/3iNooect+2LknI1CoGCiUMkjBvB7EA68FvrjIJu2WbVDf+UZh+1nFt9w
X-Received: by 2002:a9d:2015:: with SMTP id n21mr18955648ota.289.1548033816879;
        Sun, 20 Jan 2019 17:23:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548033816; cv=none;
        d=google.com; s=arc-20160816;
        b=qlR4m5nkN4h73p2yghwhOV0rW57mzc9GgQzepaYmsruMIw3A+jJBe0m2o3O6McDK19
         n6xXDi+2T3b3aVLEJ9D1pg2vX/gYFPIO7ugr5nk4GsWGCUUUJixw/k27WcKuTjy8wBkp
         E11ebS4rIpwlXz0hDEumSDVv8FH9/DLRGhRW9Kctn044/f+Mc05p8QJfzWp7B3hdsNGZ
         z/gxk+k4VET0L16MKj1MK4mTIn0rTNxvkB2HIWLWP6vlDVVkGzS3hFj2RWd74G7zctBa
         4kPhORJ5hgdIE56B3qE7XSV8M+v1ftxlpIRwTj0uRVz/9rlhqMsqaXOBE4/qFNk++bj1
         RSzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:date:mime-version
         :cc:to:from:subject:message-id;
        bh=IrpDpQRmv2ZJkZZHibl5FPTqOC+BpdBcNVZHRa2MjVg=;
        b=kIHjnIyVAcEiSWAVUOs/ObpVp5OXeiA1iVrG05zjNGyp4XQBAUsV4/dJmASp1ygJHo
         122PkKQdW/fMVDZQXiphezNZnxS601i2T8zXyqxIEkaTyh3KgXKyeauBVHaQO7CVCLUv
         3fWrJhAKAYJm0F+/Yvs3IcfC3d1DwuxXe7BfDLT3D/MrRML0CSA4zSHBbADvDN30M7Jv
         XN0EmHS+bZGc7N58vW0SqvQo2Obgm3mB2haSuuWiT8YAPQMXl68zJWktjSJamM2EplNv
         4o99t9/ynuM6HA5cMWsWtDHdOKGcLd/wE8zSl2V3cEaUyv7bNfhJF3LDAcQIQY1Ii8jT
         +F9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id i20si5789157oto.71.2019.01.20.17.23.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Jan 2019 17:23:36 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav104.sakura.ne.jp (fsav104.sakura.ne.jp [27.133.134.231])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0L1NL1A043042;
	Mon, 21 Jan 2019 10:23:21 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav104.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp);
 Mon, 21 Jan 2019 10:23:21 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav104.sakura.ne.jp)
Received: from www262.sakura.ne.jp (localhost [127.0.0.1])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x0L1NLis043031;
	Mon, 21 Jan 2019 10:23:21 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: (from i-love@localhost)
	by www262.sakura.ne.jp (8.15.2/8.15.2/Submit) id x0L1NLFJ043029;
	Mon, 21 Jan 2019 10:23:21 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Message-Id: <201901210123.x0L1NLFJ043029@www262.sakura.ne.jp>
X-Authentication-Warning: www262.sakura.ne.jp: i-love set sender to penguin-kernel@i-love.sakura.ne.jp using -f
Subject: Re: [PATCH] mm, oom: remove 'prefer children over parent' heuristic
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
To: Shakeel Butt <shakeelb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Roman Gushchin <guro@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Shakeel Butt <shakeelb@google.com>
MIME-Version: 1.0
Date: Mon, 21 Jan 2019 10:23:21 +0900
References: <20190120215059.183552-1-shakeelb@google.com>
In-Reply-To: <20190120215059.183552-1-shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190121012321.Z9ubwM_oE3B_hfcfxY7qk50wmDCRnjfMvoodxwrr91I@z>

Shakeel Butt wrote:
> +	pr_err("%s: Kill process %d (%s) score %lu or sacrifice child\n",
> +		message, task_pid_nr(p), p->comm, oc->chosen_points);

This patch is to make "or sacrifice child" false. And, the process reported
by this line will become always same with the process reported by

	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
		K(get_mm_counter(victim->mm, MM_FILEPAGES)),
		K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));

. Then, better to merge these pr_err() lines?

