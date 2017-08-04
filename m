Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2F16B0749
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 12:49:27 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id k62so1630983oia.6
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 09:49:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id y11si1488103oia.202.2017.08.04.09.49.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 04 Aug 2017 09:49:20 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: fix potential data corruption when oom_reaper races with writer
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201708040825.v748Pkul053862@www262.sakura.ne.jp>
	<20170804091629.GI26029@dhcp22.suse.cz>
	<201708041941.JFH26516.HOMtSQFFFOLVJO@I-love.SAKURA.ne.jp>
	<20170804110047.GK26029@dhcp22.suse.cz>
	<20170804145631.GP26029@dhcp22.suse.cz>
In-Reply-To: <20170804145631.GP26029@dhcp22.suse.cz>
Message-Id: <201708050149.JEC09861.MOLFtQFFVJOSOH@I-love.SAKURA.ne.jp>
Date: Sat, 5 Aug 2017 01:49:17 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, wenwei.tww@alibaba-inc.com, oleg@redhat.com, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> And that's why we still see the corruption. That, however, means that
> the MMF_UNSTABLE implementation has to be more complex and we have to
> hook into all anonymous memory fault paths which I hoped I could avoid
> previously.

I don't understand mm internals including pte/ptl etc. , but I guess that
the direction is correct. Since the OOM reaper basically does

  Set MMF_UNSTABLE flag on mm_struct.
  For each reapable page in mm_struct {
    Take ptl lock.
    Remove pte.
    Release ptl lock.
  }

the page fault handler will need to check MMF_UNSTABLE with lock held.

  For each faulted page in mm_struct {
    Take ptl lock.
    Add pte only if MMF_UNSTABLE flag is not set.
    Release ptl lock.
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
