Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BEF39831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 09:21:05 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p74so32009539pfd.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 06:21:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id b20si3712900pge.49.2017.05.18.06.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 06:21:04 -0700 (PDT)
Date: Thu, 18 May 2017 14:20:33 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm,oom: fix oom invocation issues
Message-ID: <20170518132033.GA12219@castle>
References: <1495034780-9520-1-git-send-email-guro@fb.com>
 <20170517161446.GB20660@dhcp22.suse.cz>
 <20170517194316.GA30517@castle>
 <201705180703.JGH95344.SOHJtFFMOQFLOV@I-love.SAKURA.ne.jp>
 <20170518084729.GB25462@dhcp22.suse.cz>
 <20170518090039.GC25462@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170518090039.GC25462@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 18, 2017 at 11:00:39AM +0200, Michal Hocko wrote:
> On Thu 18-05-17 10:47:29, Michal Hocko wrote:
> > 
> > Hmm, I guess you are right. I haven't realized that pagefault_out_of_memory
> > can race and pick up another victim. For some reason I thought that the
> > page fault would break out on fatal signal pending but we don't do that (we
> > used to in the past). Now that I think about that more we should
> > probably remove out_of_memory out of pagefault_out_of_memory completely.
> > It is racy and it basically doesn't have any allocation context so we
> > might kill a task from a different domain. So can we do this instead?
> > There is a slight risk that somebody might have returned VM_FAULT_OOM
> > without doing an allocation but from my quick look nobody does that
> > currently.
> 
> If this is considered too risky then we can do what Roman was proposing
> and check tsk_is_oom_victim in pagefault_out_of_memory and bail out.

Hi, Michal!

If we consider this approach, I've prepared a separate patch for this problem
(stripped all oom reaper list stuff).

Thanks!
