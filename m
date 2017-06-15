Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 949816B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:37:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id d5so21654457pfe.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:37:47 -0700 (PDT)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id f8si285252pln.560.2017.06.15.14.37.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 14:37:46 -0700 (PDT)
Received: by mail-pf0-x230.google.com with SMTP id l89so13078714pfi.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:37:46 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:37:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
In-Reply-To: <201706152201.CAB48456.FtHOJMFOVLSFQO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1706151430280.95906@chino.kir.corp.google.com>
References: <201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp> <20170615110119.GI1486@dhcp22.suse.cz> <201706152032.BFE21313.MSHQOtLVFFJOOF@I-love.SAKURA.ne.jp> <20170615120335.GJ1486@dhcp22.suse.cz> <20170615121315.GK1486@dhcp22.suse.cz>
 <201706152201.CAB48456.FtHOJMFOVLSFQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Jun 2017, Tetsuo Handa wrote:

> David is trying to avoid setting MMF_OOM_SKIP when the OOM reaper found that
> mm->users == 0.

Yes, because MMF_OOM_SKIP enables the oom killer to select another process 
to kill and will do so without the original victim's mm being able to 
undergo exit_mmap().  So now we kill two or more processes when one would 
have sufficied; I have seen up to four processes killed unnecessarily 
without this patch.

> But we must not wait forever because __mmput() might fail to
> release some memory immediately. If __mmput() did not release some memory within
> schedule_timeout_idle(HZ/10) * MAX_OOM_REAP_RETRIES sleep, let the OOM killer
> invoke again. So, this is the case we want to address here, isn't it?
> 

It is obviously a function of the number of threads that share the mm with 
the oom victim to determine how long would be a sensible amount of time to 
wait for __mmput() to even get a chance to be called, along with 
potentially allowing a non-zero number of those threads to allocate from 
memory reserves to allow them to eventually drop mm->mmap_sem to make 
forward progress.

I have not witnessed any thread stalling in __mmput() that prevents the 
mm's memory to be freed.  I have witnessed several processes oom killed 
unnecessarily for a single oom condition where before MMF_OOM_SKIP was 
introduced, a single oom kill would have sufficed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
