Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1EB736B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:57:05 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so12365pdi.5
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:57:04 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so165887pab.11
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:57:00 -0700 (PDT)
Date: Wed, 25 Sep 2013 10:56:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: avoid killing init if it assume the oom killed
 thread's mm
In-Reply-To: <52427970.8010905@windriver.com>
Message-ID: <alpine.DEB.2.02.1309251056020.17676@chino.kir.corp.google.com>
References: <1379929528-19179-1-git-send-email-ming.liu@windriver.com> <alpine.DEB.2.02.1309241933590.26187@chino.kir.corp.google.com> <52427970.8010905@windriver.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Liu <ming.liu@windriver.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rusty@rustcorp.com.au, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 25 Sep 2013, Ming Liu wrote:

> > We shouldn't be selecting a process where mm == init_mm in the first
> > place, so this wouldn't fix the issue entirely.
> 
> But if we add a control point for "mm == init_mm" in the first place(ie. in
> oom_unkillable_task), that would forbid the processes sharing mm with init to
> be selected, is that reasonable? Actually my fix is just to protect init
> process to be killed for its vfork child being selected and I think it's the
> only place where there is the risk. If my understanding is wrong, pls correct
> me.
> 

We never want to select a process where task->mm == init_mm because if we 
kill it we won't free any memory, regardless of vfork().  The goal of the 
oom killer is solely to free memory, so it always tries to avoid needless 
killing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
