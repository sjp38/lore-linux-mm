Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2009B6B0032
	for <linux-mm@kvack.org>; Wed, 11 Feb 2015 14:48:59 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id l18so2595762wgh.7
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 11:48:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ga15si6311498wic.7.2015.02.11.11.48.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Feb 2015 11:48:56 -0800 (PST)
Date: Wed, 11 Feb 2015 19:50:15 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150211185015.GA2792@redhat.com>
References: <20141230112158.GA15546@dhcp22.suse.cz> <201502092044.JDG39081.LVFOOtFHQFOMSJ@I-love.SAKURA.ne.jp> <201502102258.IFE09888.OVQFJOMSFtOLFH@I-love.SAKURA.ne.jp> <20150210151934.GA11212@phnom.home.cmpxchg.org> <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp> <201502112237.CDD87547.tJOFFVHLOOQSMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502112237.CDD87547.tJOFFVHLOOQSMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, hannes@cmpxchg.org, david@fromorbit.com, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org

On 02/11, Tetsuo Handa wrote:
>
> (Asking Oleg this time.)

Well, sorry, I ignored the previous discussion, not sure I understand you
correctly.

> > Though, more serious behavior with this reproducer is (B) where the system
> > stalls forever without kernel messages being saved to /var/log/messages .
> > out_of_memory() does not select victims until the coredump to pipe can make
> > progress whereas the coredump to pipe can't make progress until memory
> > allocation succeeds or fails.
>
> This behavior is related to commit d003f371b2701635 ("oom: don't assume
> that a coredumping thread will exit soon"). That commit tried to take
> SIGNAL_GROUP_COREDUMP into account, but actually it is failing to do so.

Heh. Please see the changelog. This "fix" is obviously very limited, it does
not even try to solve all problems (even with coredump in particular).

Note also that SIGNAL_GROUP_COREDUMP is not even set if the process (not a
sub-thread) shares the memory with the coredumping task. It would be better
to check mm->core_state != NULL instead, but this needs the locking. Plus
that process likely sleeps in D state in exit_mm(), so this can't help.

And that is why we set SIGNAL_GROUP_COREDUMP in zap_threads(), not in
zap_process(). We probably want to make that "wait for coredump_finish()"
sleep in exit_mm() killable, but this is not simple.

Sorry for noise if the above is not relevant.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
