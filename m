Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 030406B00EA
	for <linux-mm@kvack.org>; Tue,  8 May 2012 11:24:34 -0400 (EDT)
Date: Tue, 8 May 2012 10:24:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v1 5/6] mm: make vmstat_update periodic run conditional
In-Reply-To: <CAOtvUMeF6Xi-sOYZkJuAF0=jzqUHBNEMZU4BD=K3-yqQbdQxUw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1205081020340.27713@router.home>
References: <1336056962-10465-1-git-send-email-gilad@benyossef.com> <1336056962-10465-6-git-send-email-gilad@benyossef.com> <alpine.DEB.2.00.1205071024550.1060@router.home> <CAOtvUMeF6Xi-sOYZkJuAF0=jzqUHBNEMZU4BD=K3-yqQbdQxUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Tejun Heo <tj@kernel.org>, John Stultz <johnstul@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Mike Frysinger <vapier@gentoo.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Chris Metcalf <cmetcalf@tilera.com>, Hakan Akkan <hakanakkan@gmail.com>, Max Krasnyansky <maxk@qualcomm.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Tue, 8 May 2012, Gilad Ben-Yossef wrote:

> My line of thought was that if we explicitly choose a scapegoat cpu we
> and the user need to manage this - such as worry about what happens if
> the scapegoats is offlines and let the user explicitly designate the
> scapegoat cpu thus creating another knob, and worrying about what
> happens if the user designate such a cpu but then it goes offlines...

The scapegoat can be chosen on boot. One can f.e. create a file in

/sys/device/syste/cpu called "scapegoat" which contains the number of the
processor chosen. Then one can even write a userspace daemon to automatize
the moving of the processing elsewhere. Could be integrated into something
horrible like irqbalance f.e.

> I figured the user needs to worry about other unbounded work items
> anyway if he cares about where such things are run in the general case,
> but using isolcpus for example.

True. So the scapegoat heuristic could be to pick the first
unisolated cpu.

> The same should be doable with cpusets, except that right now we mark
> unbounded workqueue worker threads as pinned even though they aren't. If
> I understood the discussion, the idea is exactly to stop users from
> putting these threads in non root cpusets. I am not 100% sure why..

Not sure that cpusets is a good thing to bring in here because that is an
optional feature of the kernel and tying basic functionality like this
to cpuset support does not sound right to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
