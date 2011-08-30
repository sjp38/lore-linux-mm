Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 19103900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 12:00:38 -0400 (EDT)
Date: Tue, 30 Aug 2011 17:57:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch 2/2] oom: fix race while temporarily setting current's
	oom_score_adj
Message-ID: <20110830155733.GB22754@redhat.com>
References: <20110728154324.GA22864@redhat.com> <alpine.DEB.2.00.1107281341060.16093@chino.kir.corp.google.com> <20110729141431.GA3501@redhat.com> <20110730143426.GA6061@redhat.com> <20110730152238.GA17424@redhat.com> <4E369372.80105@jp.fujitsu.com> <20110829183743.GA15216@redhat.com> <alpine.DEB.2.00.1108291611070.32495@chino.kir.corp.google.com> <alpine.DEB.2.00.1108300040490.21066@chino.kir.corp.google.com> <alpine.DEB.2.00.1108300041330.21066@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1108300041330.21066@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/30, David Rientjes wrote:
>
> Using that function to both set oom_score_adj to OOM_SCORE_ADJ_MAX and
> then reinstate the previous value is racy since it's possible that
> userspace can set the value to something else itself before the old value
> is reinstated.  That results in userspace setting current's oom_score_adj
> to a different value and then the kernel immediately setting it back to
> its previous value without notification.

Sure,

> To fix this, a new compare_swap_oom_score_adj() function is introduced
> with the same semantics as the compare and swap CAS instruction, or
> CMPXCHG on x86.  It is used to reinstate the previous value of
> oom_score_adj if and only if the present value is the same as the old
> value.

But this can't fix the race completely ?

> +void compare_swap_oom_score_adj(int old_val, int new_val)
> +{
> +	struct sighand_struct *sighand = current->sighand;
> +
> +	spin_lock_irq(&sighand->siglock);
> +	if (current->signal->oom_score_adj == old_val)
> +		current->signal->oom_score_adj = new_val;
> +	spin_unlock_irq(&sighand->siglock);
> +}

So. This is used this way:

	old_val = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);

	do_something();

	compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, old_val);

What if userspace sets oom_score_adj = OOM_SCORE_ADJ_MAX in between?
May be the callers should use OOM_SCORE_ADJ_MAX + 1 instead, this way
we can't confuse old_val with the value from the userspace...




But in fact I am writing this email because I have the question.
Do we really need 2 helpers, and do we really need to allow to set
the arbitrary value?

I mean, perhaps we can do something like

	void set_oom_victim(bool on)
	{
		if (on) {
			oom_score_adj += ADJ_MAX - ADJ_MIN + 1;
		} else if (oom_score_adj > ADJ_MAX) {
			oom_score_adj -= ADJ_MAX - ADJ_MIN + 1;
		}
	}

Not sure this really makes sense, just curious.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
