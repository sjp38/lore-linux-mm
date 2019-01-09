Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8F98E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 06:34:55 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id c4so6148333ioh.16
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 03:34:55 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z190si4786928iof.110.2019.01.09.03.34.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 03:34:53 -0800 (PST)
Subject: Re: [PATCH 0/2] oom, memcg: do not report racy no-eligible OOM
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190109110328.GS31793@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <e55fb27c-f23b-0ac5-acfd-7265c0a3b8dc@i-love.sakura.ne.jp>
Date: Wed, 9 Jan 2019 20:34:46 +0900
MIME-Version: 1.0
In-Reply-To: <20190109110328.GS31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 2019/01/09 20:03, Michal Hocko wrote:
> Tetsuo,
> can you confirm that these two patches are fixing the issue you have
> reported please?
> 

My patch fixes the issue better than your "[PATCH 2/2] memcg: do not report racy no-eligible OOM tasks" does.

You can post "[PATCH 1/2] mm, oom: marks all killed tasks as oom victims"
based on a report that we needlessly select more OOM victims because
MMF_OOM_SKIP is quickly set by the OOM reaper. In fact, updating
oom_reap_task() / exit_mmap() to use

  mutex_lock(&oom_lock);
  set_bit(MMF_OOM_SKIP, &mm->flags);
  mutex_unlock(&oom_lock);

will mostly close the race as well.
