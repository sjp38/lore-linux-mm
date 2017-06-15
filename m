Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0874B6B02F3
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:42:28 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id e187so25412806pgc.7
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:42:28 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id t27si367423pfj.372.2017.06.15.15.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 15:42:24 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id v18so12516551pgb.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:42:24 -0700 (PDT)
Date: Thu, 15 Jun 2017 15:42:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
In-Reply-To: <20170615221236.GB22341@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706151534170.140219@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com> <20170615103909.GG1486@dhcp22.suse.cz> <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com> <20170615214133.GB20321@dhcp22.suse.cz> <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
 <20170615221236.GB22341@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 16 Jun 2017, Michal Hocko wrote:

> I am sorry but I have really hard to make the oom reaper a reliable way
> to stop all the potential oom lockups go away. I do not want to
> reintroduce another potential lockup now.

Please show where this "potential lockup" ever existed in a bug report or 
a testcase?  I have never seen __mmput() block when trying to free the 
memory it maps.

> I also do not see why any
> solution should be rushed into. I have proposed a way to go and unless
> it is clear that this is not a way forward then I simply do not agree
> with any partial workarounds or shortcuts.

This is not a shortcut, it is a bug fix.  4.12 kills 1-4 processes 
unnecessarily as a result of setting MMF_OOM_SKIP incorrectly before the 
mm's memory can be freed.  If you have not seen this issue before, which 
is why you asked if I ever observed it in practice, then you have not 
stress tested oom reaping.  It is very observable and reproducible.  I do 
not agree that adding additional and obscure locking into __mmput() is the 
solution to what is plainly and obviously fixed with this simple patch.

4.12 needs to stop killing 2-5 processes on every oom condition instead of 
1.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
