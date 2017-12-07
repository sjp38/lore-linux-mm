Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id D36076B025E
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 10:44:20 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id w70so3356805oie.15
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 07:44:20 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t79si1701891oih.160.2017.12.07.07.44.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 07:44:18 -0800 (PST)
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
	<20171207113548.GG20234@dhcp22.suse.cz>
In-Reply-To: <20171207113548.GG20234@dhcp22.suse.cz>
Message-Id: <201712080044.BID56711.FFVOLMStJOQHOF@I-love.SAKURA.ne.jp>
Date: Fri, 8 Dec 2017 00:44:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, rientjes@google.com
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> David, could you test with this patch please?

Even if this patch solved David's case, you need to update

	 * tsk_is_oom_victim() cannot be set from under us
	 * either because current->mm is already set to NULL
	 * under task_lock before calling mmput and oom_mm is
	 * set not NULL by the OOM killer only if current->mm
	 * is found not NULL while holding the task_lock.

part as well, for it is the explanation of why
tsk_is_oom_victim() test was expected to work.

Also, do we need to do

  set_bit(MMF_OOM_SKIP, &mm->flags);

if mm_is_oom_victim(mm) == false?

exit_mmap() is called means that nobody can reach this mm
except ->signal->oom_mm, and mm_is_oom_victim(mm) == false
means that this mm cannot be reached by ->signal->oom_mm .

Then, I think we do not need to set MMF_OOM_SKIP on this mm
at exit_mmap() if mm_is_oom_victim(mm) == false.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
