Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48B626B0279
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 00:00:22 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id f20so26208071itb.4
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 21:00:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d82si2016290itg.18.2017.06.15.21.00.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 21:00:21 -0700 (PDT)
Message-Id: <201706160400.v5G40ADv033862@www262.sakura.ne.jp>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 16 Jun 2017 13:00:10 +0900
References: <20170615221236.GB22341@dhcp22.suse.cz> <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
In-Reply-To: <201706160054.v5G0sY7c064781@www262.sakura.ne.jp>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> and clarify in your patch that there is no possibility
> of waiting for direct/indirect memory allocation inside free_pgtables(),
> in addition to fixing the bug above.

Oops, this part was wrong, for __oom_reap_task_mm() will give up after
waiting for one second because down_read_trylock(&mm->mmap_sem) continues
failing due to down_write(&mm->mmap_sem) by exit_mmap().
# This is after all moving the location of "give up by timeout", isn't it? ;-)

Thus, clarify in your patch that there is no possibility of waiting for
direct/indirect memory allocation outside down_write()/up_write() (e.g.
i_mmap_lock_write() inside unmap_vmas(&tlb, vma, 0, -1) just before
down_write()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
