Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 90F8A6B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 11:35:55 -0400 (EDT)
Received: by obbmp4 with SMTP id mp4so50417133obb.3
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:35:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w140si12464658oif.70.2015.09.21.08.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 08:35:54 -0700 (PDT)
Date: Mon, 21 Sep 2015 17:32:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150921153252.GA21988@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com> <20150919150316.GB31952@redhat.com> <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com> <20150920125642.GA2104@redhat.com> <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com> <20150921134414.GA15974@redhat.com> <20150921142423.GC19811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921142423.GC19811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/21, Michal Hocko wrote:
>
> On Mon 21-09-15 15:44:14, Oleg Nesterov wrote:
> [...]
> > So yes, in general oom_kill_process() can't call oom_unmap_func() directly.
> > That is why the patch uses queue_work(oom_unmap_func). The workqueue thread
> > takes mmap_sem and frees the memory allocated by user space.
>
> OK, this might have been a bit confusing. I didn't mean you cannot use
> mmap_sem directly from the workqueue context. You _can_ AFAICS. But I've
> mentioned that you _shouldn't_ use workqueue context in the first place
> because all the workers might be blocked on locks and new workers cannot
> be created due to memory pressure.

Yes, yes, and I already tried to comment this part. We probably need a
dedicated kernel thread, but I still think (although I am not sure) that
initial change can use workueue. In the likely case system_unbound_wq pool
should have an idle thread, if not - OK, this change won't help in this
case. This is minor.

> So I think we probably need to do this in the OOM killer context (with
> try_lock)

Yes we should try to do this in the OOM killer context, and in this case
(of course) we need trylock. Let me quote my previous email:

	And we want to avoid using workqueues when the caller can do this
	directly. And in this case we certainly need trylock. But this needs
	some refactoring: we do not want to do this under oom_lock, otoh it
	makes sense to do this from mark_oom_victim() if current && killed,
	and a lot more details.

and probably this is another reason why do we need MMF_MEMDIE. But again,
I think the initial change should be simple.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
