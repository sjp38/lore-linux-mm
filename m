Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id A0A386B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 19:42:46 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so129806159pad.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:42:46 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id b1si24211085pat.4.2015.09.21.16.42.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 16:42:45 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so130024668pac.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 16:42:45 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:42:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <20150921153252.GA21988@redhat.com>
Message-ID: <alpine.DEB.2.10.1509211638580.27715@chino.kir.corp.google.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz> <20150921153252.GA21988@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Mon, 21 Sep 2015, Oleg Nesterov wrote:

> Yes we should try to do this in the OOM killer context, and in this case
> (of course) we need trylock. Let me quote my previous email:
> 
> 	And we want to avoid using workqueues when the caller can do this
> 	directly. And in this case we certainly need trylock. But this needs
> 	some refactoring: we do not want to do this under oom_lock, otoh it
> 	makes sense to do this from mark_oom_victim() if current && killed,
> 	and a lot more details.
> 
> and probably this is another reason why do we need MMF_MEMDIE. But again,
> I think the initial change should be simple.
> 

I agree with the direction and I don't think it would be too complex to 
have a dedicated kthread that is kicked when we queue an mm to do 
MADV_DONTNEED behavior, and have that happen only if a trylock in 
oom_kill_process() fails to do it itself for anonymous mappings.  We may 
have different opinions of simplicity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
