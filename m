Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 5E6086B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 10:34:42 -0400 (EDT)
Message-ID: <1337351677.573.44.camel@twins>
Subject: Re: [PATCH 2/2] block: Convert BDI proportion calculations to
 flexible proportions
From: Peter Zijlstra <peterz@infradead.org>
Date: Fri, 18 May 2012 16:34:37 +0200
In-Reply-To: <20120518142443.GA6875@quack.suse.cz>
References: <1337096583-6049-1-git-send-email-jack@suse.cz>
	 <1337096583-6049-3-git-send-email-jack@suse.cz>
	 <1337292273.4281.101.camel@twins> <20120518142443.GA6875@quack.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Wu Fengguang <fengguang.wu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 2012-05-18 at 16:24 +0200, Jan Kara wrote:
>   Yeah, that should be easy enough so I'll try it that way since I presum=
e
> it's nicer to power usage to use deferred timers if it's reasonably
> possible.=20

Btw, your current scheme also drifts. Since you do jiffes + 3*HZ you
period might actually be longer if the timer got delayed.

If you keep an external jiffies count like:

unsigned long period_jiffies =3D jiffies;

void my_timer_func()
{
	unsigned long delta =3D jiffies - period_jiffies;
	unsigned long periods =3D delta / 3*HZ;

	age(periods);

	period_jiffies +=3D 3*HZ * periods;
	mod_timer(&my_timer, period_jiffies);
}


it all works without drift (+- bugs of course).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
