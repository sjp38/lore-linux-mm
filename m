Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 702E26B0253
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 10:12:30 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id i127so42417942ita.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 07:12:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f67si27390122otf.70.2016.06.01.07.12.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 07:12:29 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
	<1464613556-16708-5-git-send-email-mhocko@kernel.org>
In-Reply-To: <1464613556-16708-5-git-send-email-mhocko@kernel.org>
Message-Id: <201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
Date: Wed, 1 Jun 2016 23:12:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, mhocko@suse.com

Michal Hocko wrote:
> vforked tasks are not really sitting on any memory. They are sharing
> the mm with parent until they exec into a new code. Until then it is
> just pinning the address space. OOM killer will kill the vforked task
> along with its parent but we still can end up selecting vforked task
> when the parent wouldn't be selected. E.g. init doing vfork to launch
> a task or vforked being a child of oom unkillable task with an updated
> oom_score_adj to be killable.
> 
> Make sure to not select vforked task as an oom victim by checking
> vfork_done in oom_badness.

While vfork()ed task cannot modify userspace memory, can't such task
allocate significant amount of kernel memory inside execve() operation
(as demonstrated by CVE-2010-4243 64bit_dos.c )?

It is possible that killing vfork()ed task releases a lot of memory,
isn't it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
