Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69F88C31E50
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 21:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 133A52183F
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 21:34:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 133A52183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 68E916B0003; Sat, 15 Jun 2019 17:34:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63E706B0005; Sat, 15 Jun 2019 17:34:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 508248E0001; Sat, 15 Jun 2019 17:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 288496B0003
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 17:34:40 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a198so2099736oii.15
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 14:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0dbH8wo68G1P+e+lAtwGcw6CeVHBhPqcl3R994ZLLUE=;
        b=TYHlXWbDFmge+d4gRyTla2ZSFZnFpvH4Lsc12B0nLY7w+JbyTTs9j1EuljQj34Wiqo
         +C9ycDdfq3z6nu1jM5PmWxJCGFZkw359FgCJFNXW0Vfr91ypnss+EhNouoQ0XF8Vu1Mq
         4hAr0KsJ2/2ZShvl8GKrRtaSHhC7ueHQR1TQe3gf4W3Hwum0ku3NiN+kB8WP6zAkvgue
         3MPCeJdVJQZgPZUjVRcy1eI6MTgNYy+kEkDjlF5oiEvWCDvZu7FyvhgZJuonestX0xDA
         qUUoBHyyDugStcGeaXSvfC5p7t9apdqD6aYbN/za0VSk2PRxgCUUlAImcRWUL4fvu7HL
         xNOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAW1IuE5OrUEwBS2GDxqAiydJYTXgt+YzkY6vlcVA1+mdiRwb70F
	w34w2/AiZCOvgMelpgPmvDFmG8OGx144TQXsMAuuY4RSEumCrdpYN+KjblUQ0xLO4UH/Wgt2OfA
	bIIhJma8pPgaQrMWw3x9kgKBT9ZMzjoyVGMBezQuIceRBy5Ao5BoWjQReNuIVUtK2yg==
X-Received: by 2002:aca:51cf:: with SMTP id f198mr6319473oib.140.1560634479849;
        Sat, 15 Jun 2019 14:34:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4fszhcUDFGBw1pdVphHlCPw+7EdfJknulVPDGV48tra3zyqL5h9gWDL3eZLN1WBAplcMO
X-Received: by 2002:aca:51cf:: with SMTP id f198mr6319451oib.140.1560634479168;
        Sat, 15 Jun 2019 14:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560634479; cv=none;
        d=google.com; s=arc-20160816;
        b=P901C+BZt7LHDWNrFe2j3z6yTxESIeYhvJkmOePjj/JQdQTGmUlroh0/m9kTbltgmR
         jKbkldAj2LtuUwlrGiio82+ELWIuDVVaGKsvP+I2hxZkjArJkAoD8lGIZ2IkChLgN9vY
         qNw+kJbKbuuFSHKcZeEpnjzmmnSH9S/0aI/MlBTL2PK/vU5BOeMaLHdSjOvJPdM01v+l
         TPhVpC3XqDO1lDJXGTYlPlTptkezU+WvJTus26oWErmgT4eBo9E0fC1JqR6/ic/Q+gD+
         JcFfmV855F03gdGIS+S4BSTa5fcn+2/hpxxGsTSFBFhXiFuZaRquW1x+DzLvFUNswWtH
         JbQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0dbH8wo68G1P+e+lAtwGcw6CeVHBhPqcl3R994ZLLUE=;
        b=HRHj2XMUMfZEcZhXRA6kmRXuRQain/oi4I4xGQiGBmRUWzv066TWH7/gjWQfUxZ2A0
         2T1eu7RQXVkGuBnwpagoZdyQWLGRu5CqSFxcg+SnIvLeV4VzKw9vh97a/9J8NVkq3RJC
         UHSTtbmusY2vHT6ImrvFZxg50vf+iy7WxN4Sk2DZHsjf7DY0DhUqFGXekLuU9KZ+ONLx
         Z6d7XAyzmtBFhfAapUvxYIL1VtXm6sp+NsR9XYt61rKkqvmepmyyftJ4hqNUe3h2rNvT
         vcw8D9j/rfIgutNp6fyoCCMokvbZs/q9HYZ3v6Rdbjg8f+9rF1r3wWWZy7LzZhWmdrF/
         ZqlA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id u4si3385701oig.17.2019.06.15.14.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 14:34:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x5FLXux2063615;
	Sun, 16 Jun 2019 06:33:56 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Sun, 16 Jun 2019 06:33:56 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x5FLXpms063601
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sun, 16 Jun 2019 06:33:56 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: general protection fault in oom_unkillable_task
To: Shakeel Butt <shakeelb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>,
        syzbot <syzbot+d0fc9d3c166bc5e4a94b@syzkaller.appspotmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
        syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
        yuzhoujian@didichuxing.com
References: <0000000000004143a5058b526503@google.com>
 <CALvZod72=KuBZkSd0ey5orJFGFpwx462XY=cZvO3NOXC0MogFw@mail.gmail.com>
 <20190615134955.GA28441@dhcp22.suse.cz>
 <CALvZod4hT39PfGt9Ohj+g77om5=G0coHK=+G1=GKcm-PowkXsw@mail.gmail.com>
 <5bb1fe5d-f0e1-678b-4f64-82c8d5d81f61@i-love.sakura.ne.jp>
 <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <791594c6-45a3-d78a-70b5-901aa580ed9f@i-love.sakura.ne.jp>
Date: Sun, 16 Jun 2019 06:33:51 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <CALvZod4etSv9Hv4UD=E6D7U4vyjCqhxQgq61AoTUCd+VubofFg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/06/16 3:50, Shakeel Butt wrote:
>> While dump_tasks() traverses only each thread group, mem_cgroup_scan_tasks()
>> traverses each thread.
> 
> I think mem_cgroup_scan_tasks() traversing threads is not intentional
> and css_task_iter_start in it should use CSS_TASK_ITER_PROCS as the
> oom killer only cares about the processes or more specifically
> mm_struct (though two different thread groups can have same mm_struct
> but that is fine).

We can't use CSS_TASK_ITER_PROCS from mem_cgroup_scan_tasks(). I've tried
CSS_TASK_ITER_PROCS in an attempt to evaluate only one thread from each
thread group, but I found that CSS_TASK_ITER_PROCS causes skipping whole
threads in a thread group (and trivially allowing "Out of memory and no
killable processes...\n" flood) if thread group leader has already exited.

If we can agree with using a flag in mm_struct in order to track whether 
each mm_struct was already evaluated for each out_of_memory() call, we can
printk() only one thread from all thread groups sharing that mm_struct...

