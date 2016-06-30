Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 313A5828E1
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 04:16:03 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so70792936wme.1
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:16:03 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id fh6si2986291wjb.152.2016.06.30.01.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 01:16:02 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id r190so2752696wmr.0
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:16:01 -0700 (PDT)
Date: Thu, 30 Jun 2016 10:16:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160630081600.GE18783@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627204016.GA31239@redhat.com>
 <20160628102959.GC510@dhcp22.suse.cz>
 <20160629202424.GC19253@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629202424.GC19253@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Wed 29-06-16 22:24:24, Oleg Nesterov wrote:
> On 06/28, Michal Hocko wrote:
> >
> > On Mon 27-06-16 22:40:17, Oleg Nesterov wrote:
> > >
> > > Ah, but this is clear, note the "Ignoring the obvious races" above.
> > > Can't we fix this race? I am a bit lost, but iirc we want this anyway
> > > to ensure that we do not set TIF_MEMDIE if ->mm == NULL ?
> >
> > This is not about a race it is about not reaching exit_oom_victim and
> > unblock the oom killer from selecting another victim.
> 
> I understand. What I do not understand why we can't rely on MMF_OOM_REAPED
> if we ensure that TIF_MEMDIE can only be set if the victim did not call
> exit_oom_victim() yet.
> 
> OK, please forget, I already got lost and right now I don't even have the
> uptodate -mm tree sources.
> 
> > > Hmm. Although I am not sure I really understand the "may block for
> > > unbounded period ..." above. Do you mean khugepaged_exit?
> >
> > __mmput->exit_aio can wait for IO to complete and who knows what that
> > might depend on.
> 
> Yes, but I was confused by "waiting for somebody else's memory allocation",
> I do not this this apllies to exit_aio.

To be honest I really don't know. I am just assuming the worst. And IO
sometimes need to allocate to move on.

> Nevermind,
> 
> > Who knows how many others are lurking there.
> 
> Yes, yes, I agree. Just I wrongly thought Tetsuo meant something particular.

I guess we just want to be conservative here and make sure we do not
want to depend on the particular implementation details.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
