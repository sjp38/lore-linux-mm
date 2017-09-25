Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ABDF16B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 11:09:31 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id d8so16672994pgt.1
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:09:31 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id r59si1415524plb.541.2017.09.25.08.09.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 08:09:30 -0700 (PDT)
Subject: Re: [PATCH] [PATCH v3] mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for once.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1506070646-4549-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
In-Reply-To: <20170925143052.a57bqoiw6yuckwee@dhcp22.suse.cz>
Message-Id: <201709260009.DIJ57392.HFSJOMOFQOLVtF@I-love.SAKURA.ne.jp>
Date: Tue, 26 Sep 2017 00:09:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, mjaggi@caviumnetworks.com, oleg@redhat.com, vdavydov@virtuozzo.com

Michal Hocko wrote:
> On Fri 22-09-17 17:57:26, Tetsuo Handa wrote:
> [...]
> > Michal Hocko has nacked this patch [3], and he suggested an alternative
> > patch [4]. But he himself is not ready to clarify all the concerns with
> > the alternative patch [5]. In addition to that, nobody is interested in
> > either patch; we can not make progress here. Let's choose this patch for
> > now, for this patch has smaller impact than the alternative patch.
> 
> My Nack stands and it is really annoying you are sending a patch for
> inclusion regardless of that fact. An alternative approach has been
> proposed and the mere fact that I do not have time to pursue this
> direction is not reason to go with a incomplete solution. This is not an
> issue many people would be facing to scream for a quick and dirty
> workarounds AFAIK (there have been 0 reports from non-artificial
> workloads).
> 
But the alternative approach is also an incomplete solution because of below
limitations.

  (1) Since we cannot use direct reclaim for this allocation attempt due to
      oom_lock already held, an OOM victim will be prematurely killed which
      could have been avoided if direct reclaim with oom_lock released was
      used.

  (2) Since we call panic() before calling oom_kill_process() when there is
      no killable process, panic() will be prematurely called which could
      have been avoided if this patch is used. For example, if a multithreaded
      application running with a dedicated CPUs/memory was OOM-killed, we
      can wait until ALLOC_OOM allocation fails to solve OOM situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
