Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18A496B007E
	for <linux-mm@kvack.org>; Thu, 26 May 2016 12:14:46 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so115876532pad.1
        for <linux-mm@kvack.org>; Thu, 26 May 2016 09:14:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g82si7506420pfj.143.2016.05.26.09.14.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 09:14:44 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no external tasks sharing mm
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464266415-15558-2-git-send-email-mhocko@kernel.org>
	<201605262330.EEB52182.OtMFOJHFLOSFVQ@I-love.SAKURA.ne.jp>
	<20160526145930.GF23675@dhcp22.suse.cz>
	<201605270025.IAC48454.QSHOOMFOLtFJFV@I-love.SAKURA.ne.jp>
	<20160526153532.GG23675@dhcp22.suse.cz>
In-Reply-To: <20160526153532.GG23675@dhcp22.suse.cz>
Message-Id: <201605270114.IEI48969.MFFtFOJLQOOHSV@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 01:14:35 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Fri 27-05-16 00:25:23, Tetsuo Handa wrote:
> > I think that remembering whether this mm might be shared between
> > multiple thread groups at clone() time (i.e. whether
> > clone(CLONE_VM without CLONE_SIGHAND) was ever requested on this mm)
> > is safe (given that that thread already got SIGKILL or is exiting).
> 
> I was already playing with that idea but I didn't want to add anything
> to the fork path which is really hot. This patch is not really needed
> for the rest. It just felt like a nice optimization. I do not think it
> is worth deeper changes in the fast paths.

"[PATCH 6/6] mm, oom: fortify task_will_free_mem" depends on [PATCH 1/6].
You will need to update [PATCH 6/6].

It seems to me that [PATCH 6/6] resembles
http://lkml.kernel.org/r/201605250005.GHH26082.JOtQOSLMFFOFVH@I-love.SAKURA.ne.jp .
I think we will be happy if we can speed up mm_is_reapable() test using
"whether this mm might be shared between multiple thread groups" flag.
I don't think updating such flag at clone() is too heavy operation to add.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
