Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C11E6B01AC
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 11:30:57 -0400 (EDT)
Date: Sun, 13 Jun 2010 17:29:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/1] signals: introduce send_sigkill() helper
Message-ID: <20100613152918.GA8024@redhat.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608210000.7692.A69D9226@jp.fujitsu.com> <20100608184144.GA5914@redhat.com> <20100610005937.GA4727@redhat.com> <20100610010023.GB4727@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100610010023.GB4727@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Andrew, please drop

	signals-introduce-send_sigkill-helper.patch

I am stupid.

On 06/10, Oleg Nesterov wrote:
>
> Cleanup, no functional changes.
>
> There are a lot of buggy SIGKILL users in kernel. For example, almost
> every force_sig(SIGKILL) is wrong. force_sig() is not safe, it assumes
> that the task has the valid ->sighand, and in general it should be used
> only for synchronous signals. send_sig(SIGKILL, p, 1) or
> send_xxx(SEND_SIG_FORCED/SEND_SIG_PRIV) is not right too but this is not
> immediately obvious.
>
> The only way to correctly send SIGKILL is send_sig_info(SEND_SIG_NOINFO)

No, SEND_SIG_NOINFO doesn't work too. Oh, can't understand what I was
thinking about. current is the random task, but send_signal() checks
if the caller is from-parent-ns.

> Note: we need more cleanups here, this is only the first change.

We need the cleanups first. Until then oom-killer has to use force_sig()
if we want to kill the SIGNAL_UNKILLABLE tasks too.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
