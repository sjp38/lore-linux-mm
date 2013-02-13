Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 9D6116B0008
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 10:41:07 -0500 (EST)
Received: by mail-qa0-f73.google.com with SMTP id g10so139628qah.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2013 07:41:06 -0800 (PST)
From: Greg Thelen <gthelen@google.com>
Subject: Re: [PATCH] memcg: Add memory.pressure_level events
References: <20130211000220.GA28247@lizard.gateway.2wire.net>
	<xr9338x01zpw.fsf@gthelen.mtv.corp.google.com>
	<20130213071503.GA20543@lizard.gateway.2wire.net>
Date: Wed, 13 Feb 2013 07:41:04 -0800
In-Reply-To: <20130213071503.GA20543@lizard.gateway.2wire.net> (Anton
	Vorontsov's message of "Tue, 12 Feb 2013 23:15:03 -0800")
Message-ID: <xr93sj50z0fj.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Tue, Feb 12 2013, Anton Vorontsov wrote:

> Hi Greg,
>
> Thanks for taking a look!
>
> On Tue, Feb 12, 2013 at 10:42:51PM -0800, Greg Thelen wrote:
> [...]
>> > +static bool vmpressure_event(struct vmpressure *vmpr,
>> > +			     unsigned long s, unsigned long r)
>> > +{
>> > +	struct vmpressure_event *ev;
>> > +	int level = vmpressure_calc_level(vmpressure_win, s, r);
>> > +	bool signalled = 0;
>> s/bool/int/
>
> Um... I surely can do this, but why do you think it is a good idea?

Because you incremented signalled below.  Incrementing a bool seems
strange.  A better fix would be to leave this a bool and
s/signaled++/signaled = true/ below.

>> > +
>> > +	mutex_lock(&vmpr->events_lock);
>> > +
>> > +	list_for_each_entry(ev, &vmpr->events, node) {
>> > +		if (level >= ev->level) {
>> > +			eventfd_signal(ev->efd, 1);
>> > +			signalled++;
>> > +		}
>> > +	}
>> > +
>> > +	mutex_unlock(&vmpr->events_lock);
>> > +
>> > +	return signalled;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
