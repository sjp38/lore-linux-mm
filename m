Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 047FA6B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 17:20:44 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t10-v6so13716946plr.12
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 14:20:43 -0700 (PDT)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id v13-v6si16524486plk.153.2018.03.26.14.20.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 14:20:42 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
 <0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <def25632-b983-950b-d2e6-b7c6478024ed@linux.alibaba.com>
Date: Mon, 26 Mar 2018 17:20:33 -0400
MIME-Version: 1.0
In-Reply-To: <0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Cyrill Gorcunov <gorcunov@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/26/18 5:10 PM, Tetsuo Handa wrote:
> On 2018/03/27 4:21, Cyrill Gorcunov wrote:
>> That said I think using read-lock here would be a bug.
> If I understand correctly, the caller can't set both fields atomically, for
> prctl() does not receive both fields at one call.
>
>    prctl(PR_SET_MM, PR_SET_MM_ARG_START xor PR_SET_MM_ARG_END xor PR_SET_MM_ENV_START xor PR_SET_MM_ENV_END, new value, 0, 0);
>
> Then, I wonder whether reading arg_start|end and env_start|end atomically makes
> sense. Just retry reading if arg_start > env_end or env_start > env_end is fine?

It might trap into dead loop if those are set to wrong values, right?
