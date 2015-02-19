Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 82CAE6B0032
	for <linux-mm@kvack.org>; Thu, 19 Feb 2015 17:11:08 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id va2so20149653obc.6
        for <linux-mm@kvack.org>; Thu, 19 Feb 2015 14:11:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id pm6si1341943oec.22.2015.02.19.14.11.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Feb 2015 14:11:07 -0800 (PST)
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	<1424304641-28965-4-git-send-email-dbueso@suse.de>
	<1424324307.18191.5.camel@stgolabs.net>
	<201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
	<1424370153.18191.12.camel@stgolabs.net>
In-Reply-To: <1424370153.18191.12.camel@stgolabs.net>
Message-Id: <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
Date: Fri, 20 Feb 2015 07:11:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@stgolabs.net
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org

Davidlohr Bueso wrote:
> On Thu, 2015-02-19 at 20:07 +0900, Tetsuo Handa wrote:
> > Why do we need to let the caller call path_put() ?
> > There is no need to do like proc_exe_link() does, for
> > tomoyo_get_exe() returns pathname as "char *".
> 
> Having the pathname doesn't guarantee anything later, and thus doesn't
> seem very robust in the manager call if it can be dropped during the
> call... or can this never occur in this context?
> 
tomoyo_get_exe() returns the pathname of executable of current thread.
The executable of current thread cannot be changed while current thread
is inside the manager call. Although the pathname of executable of
current thread could be changed by other threads via namespace manipulation
like pivot_root(), holding a reference guarantees nothing. Your patch helps
for avoiding memory allocation with mmap_sem held, but does not robustify
handling of mm->exe_file for tomoyo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
