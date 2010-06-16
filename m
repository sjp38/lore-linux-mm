Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9D9B16B01B5
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 06:01:03 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5GA11u1019903
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Jun 2010 19:01:01 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F04E945DE4E
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:01:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C90AC45DE61
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:01:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 54F4F1DB8038
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:01:00 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EDD90E08001
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 19:00:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/1] signals: introduce send_sigkill() helper
In-Reply-To: <20100613152918.GA8024@redhat.com>
References: <20100610010023.GB4727@redhat.com> <20100613152918.GA8024@redhat.com>
Message-Id: <20100616185942.72D2.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Jun 2010 19:00:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Roland McGrath <roland@redhat.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> Andrew, please drop
> 
> 	signals-introduce-send_sigkill-helper.patch
> 
> I am stupid.
> 
> On 06/10, Oleg Nesterov wrote:
> >
> > Cleanup, no functional changes.
> >
> > There are a lot of buggy SIGKILL users in kernel. For example, almost
> > every force_sig(SIGKILL) is wrong. force_sig() is not safe, it assumes
> > that the task has the valid ->sighand, and in general it should be used
> > only for synchronous signals. send_sig(SIGKILL, p, 1) or
> > send_xxx(SEND_SIG_FORCED/SEND_SIG_PRIV) is not right too but this is not
> > immediately obvious.
> >
> > The only way to correctly send SIGKILL is send_sig_info(SEND_SIG_NOINFO)
> 
> No, SEND_SIG_NOINFO doesn't work too. Oh, can't understand what I was
> thinking about. current is the random task, but send_signal() checks
> if the caller is from-parent-ns.
> 
> > Note: we need more cleanups here, this is only the first change.
> 
> We need the cleanups first. Until then oom-killer has to use force_sig()
> if we want to kill the SIGNAL_UNKILLABLE tasks too.

This definitely needed. OOM-Killer is not racist ;)

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
