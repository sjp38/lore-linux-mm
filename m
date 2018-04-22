Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B16AE6B0006
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 23:48:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 202-v6so7522512ion.2
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 20:48:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d145-v6si8271947iof.136.2018.04.21.20.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Apr 2018 20:48:20 -0700 (PDT)
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaperunmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180419063556.GK17484@dhcp22.suse.cz>
	<alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com>
	<20180420082349.GW17484@dhcp22.suse.cz>
	<20180420124044.GA17484@dhcp22.suse.cz>
	<alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
Message-Id: <201804221248.CHE35432.FtOMOLSHOFJFVQ@I-love.SAKURA.ne.jp>
Date: Sun, 22 Apr 2018 12:48:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

David Rientjes wrote:
> How have you tested this?
> 
> I'm wondering why you do not see oom killing of many processes if the 
> victim is a very large process that takes a long time to free memory in 
> exit_mmap() as I do because the oom reaper gives up trying to acquire 
> mm->mmap_sem and just sets MMF_OOM_SKIP itself.
> 

We can call __oom_reap_task_mm() from exit_mmap() (or __mmput()) before
exit_mmap() holds mmap_sem for write. Then, at least memory which could
have been reclaimed if exit_mmap() did not hold mmap_sem for write will
be guaranteed to be reclaimed before MMF_OOM_SKIP is set.
