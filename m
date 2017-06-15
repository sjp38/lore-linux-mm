Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 51DD56B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 17:26:29 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id d13so24039352pgf.12
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:26:29 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id z184si242670pfb.427.2017.06.15.14.26.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 14:26:28 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id v18so11840575pgb.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 14:26:28 -0700 (PDT)
Date: Thu, 15 Jun 2017 14:26:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
In-Reply-To: <20170615103909.GG1486@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com> <20170615103909.GG1486@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Jun 2017, Michal Hocko wrote:

> > If mm->mm_users is not incremented because it is already zero by the oom
> > reaper, meaning the final refcount has been dropped, do not set
> > MMF_OOM_SKIP prematurely.
> > 
> > __mmput() may not have had a chance to do exit_mmap() yet, so memory from
> > a previous oom victim is still mapped.
> 
> true and do we have a _guarantee_ it will do it? E.g. can somebody block
> exit_aio from completing? Or can somebody hold mmap_sem and thus block
> ksm_exit resp. khugepaged_exit from completing? The reason why I was
> conservative and set such a mm as MMF_OOM_SKIP was because I couldn't
> give a definitive answer to those questions. And we really _want_ to
> have a guarantee of a forward progress here. Killing an additional
> proecess is a price to pay and if that doesn't trigger normall it sounds
> like a reasonable compromise to me.
> 

I have not seen any issues where __mmput() stalls and exit_mmap() fails to 
free its mapped memory once mm->mm_users has dropped to 0.

> > __mput() naturally requires no
> > references on mm->mm_users to do exit_mmap().
> > 
> > Without this, several processes can be oom killed unnecessarily and the
> > oom log can show an abundance of memory available if exit_mmap() is in
> > progress at the time the process is skipped.
> 
> Have you seen this happening in the real life?
> 

Yes, quite a bit in testing.

One oom kill shows the system to be oom:

[22999.488705] Node 0 Normal free:90484kB min:90500kB ...
[22999.488711] Node 1 Normal free:91536kB min:91948kB ...

followed up by one or more unnecessary oom kills showing the oom killer 
racing with memory freeing of the victim:

[22999.510329] Node 0 Normal free:229588kB min:90500kB ...
[22999.510334] Node 1 Normal free:600036kB min:91948kB ...

The patch is absolutely required for us to prevent continuous oom killing 
of processes after a single process has been oom killed and its memory is 
in the process of being freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
