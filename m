Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 16D436B02B4
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 02:39:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v62so121870502pfd.10
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 23:39:25 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id q6si6523479pgn.509.2017.07.23.23.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jul 2017 23:39:24 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id g14so4225943pgu.0
        for <linux-mm@kvack.org>; Sun, 23 Jul 2017 23:39:24 -0700 (PDT)
Date: Sun, 23 Jul 2017 23:39:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
In-Reply-To: <20170720130541.GH9058@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1707232331250.2154@eggly.anvils>
References: <20170626130346.26314-1-mhocko@kernel.org> <20170629084621.GE31603@dhcp22.suse.cz> <20170719055542.GA22162@dhcp22.suse.cz> <alpine.LSU.2.11.1707191716030.2055@eggly.anvils> <20170720130541.GH9058@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <andrea@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 20 Jul 2017, Michal Hocko wrote:
> On Wed 19-07-17 18:18:27, Hugh Dickins wrote:
> > 
> > But I haven't looked at the oom_kill or oom_reaper end of it at all,
> > perhaps you have an overriding argument on the placement from that end.
> 
> Well, the main problem here is that the oom_reaper tries to
> MADV_DONTNEED the oom victim and then hide it from the oom killer (by
> setting MMF_OOM_SKIP) to guarantee a forward progress. In order to do
> that it needs mmap_sem for read. Currently we try to avoid races with
> the eixt path by checking mm->mm_users and that can lead to premature
> MMF_OOM_SKIP and that in turn to additional oom victim(s) selection
> while the current one is still tearing the address space down.
> 
> One way around that is to allow final unmap race with the oom_reaper
> tear down.
> 
> I hope this clarify the motivation

Thanks, yes, if you have a good reason of that kind, then I agree that
it's appropriate to leave the down_write(mmap_sem) until reaching the
free_pgtables() stage.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
