Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5F66B7907
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 09:40:44 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u6-v6so5552865pgn.10
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 06:40:44 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id f29-v6si5351253pgl.570.2018.09.06.06.40.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 06:40:43 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm, oom: Fix unnecessary killing of additional
 processes.
References: <1533389386-3501-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1533389386-3501-4-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180806134550.GO19540@dhcp22.suse.cz>
 <alpine.DEB.2.21.1808061315220.43071@chino.kir.corp.google.com>
 <20180806205121.GM10003@dhcp22.suse.cz>
 <0aeb76e1-558f-e38e-4c66-77be3ce56b34@I-love.SAKURA.ne.jp>
 <20180906113553.GR14951@dhcp22.suse.cz>
 <87b76eea-9881-724a-442a-c6079cbf1016@i-love.sakura.ne.jp>
 <20180906120508.GT14951@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <37b763c1-b83e-1632-3187-55fb360a914e@i-love.sakura.ne.jp>
Date: Thu, 6 Sep 2018 22:40:24 +0900
MIME-Version: 1.0
In-Reply-To: <20180906120508.GT14951@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Roman Gushchin <guro@fb.com>

On 2018/09/06 21:05, Michal Hocko wrote:
>> If you are too busy, please show "the point of no-blocking" using source code
>> instead. If such "the point of no-blocking" really exists, it can be executed
>> by allocating threads.
> 
> I would have to study this much deeper but I _suspect_ that we are not
> taking any blocking locks right after we return from unmap_vmas. In
> other words the place we used to have synchronization with the
> oom_reaper in the past.

See commit 97b1255cb27c551d ("mm,oom_reaper: check for MMF_OOM_SKIP before
complaining"). Since this dependency is inode-based (i.e. irrelevant with
OOM victims), waiting for this lock can livelock.

So, where is safe "the point of no-blocking" ?
