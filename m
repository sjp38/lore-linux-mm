Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3599C6B00EA
	for <linux-mm@kvack.org>; Thu, 17 May 2012 18:04:37 -0400 (EDT)
Message-ID: <1337292273.4281.101.camel@twins>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 18 May 2012 00:04:33 +0200
In-Reply-To: <1337096583-6049-3-git-send-email-jack@suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
	 <1337096583-6049-3-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 2012-05-15 at 17:43 +0200, Jan Kara wrote:
> +static struct timer_list writeout_period_timer =3D
> +               TIMER_DEFERRED_INITIALIZER(writeout_period, 0, 0);=20

So the problem with using a deferred timer is that it 'ignores' idle
time. So if a very busy period is followed by a real quiet period you'd
expect all the proportions to have aged to 0, but they won't have.

One way to solve that is to track a jiffies count of the last time the
timer triggered and compute the missed periods from that and extend
fprop_new_period() to deal with period increments of more than 1.

The other is of course to not use deferred timers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
