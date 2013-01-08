Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 0036B6B005D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 02:33:09 -0500 (EST)
Received: by mail-gg0-f178.google.com with SMTP id u1so10707ggl.37
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 23:33:09 -0800 (PST)
Date: Mon, 7 Jan 2013 23:29:35 -0800
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 1/2] Add mempressure cgroup
Message-ID: <20130108072935.GA15431@lizard.gateway.2wire.net>
References: <20130104082751.GA22227@lizard.gateway.2wire.net>
 <1357288152-23625-1-git-send-email-anton.vorontsov@linaro.org>
 <50EA8CA2.7020608@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <50EA8CA2.7020608@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, Jan 07, 2013 at 05:51:46PM +0900, Kamezawa Hiroyuki wrote:
[...]
> I'm just curious..

Thanks for taking a look! :)

[...]
> > +/*
> > + * The window size is the number of scanned pages before we try to analyze
> > + * the scanned/reclaimed ratio (or difference).
> > + *
> > + * It is used as a rate-limit tunable for the "low" level notification,
> > + * and for averaging medium/oom levels. Using small window sizes can cause
> > + * lot of false positives, but too big window size will delay the
> > + * notifications.
> > + */
> > +static const uint vmpressure_win = SWAP_CLUSTER_MAX * 16;
> > +static const uint vmpressure_level_med = 60;
> > +static const uint vmpressure_level_oom = 99;
> > +static const uint vmpressure_level_oom_prio = 4;
> > +
> 
> Hmm... isn't this window size too small ?
> If vmscan cannot find a reclaimable page while scanning 2M of pages in a zone,
> oom notify will be returned. Right ?

Yup, you are right, if we were not able to find anything within the window
size (which is 2M, but see below), then it is effectively the "OOM level".
The thing is, the vmpressure reports... the pressure. :) Or, the
allocation cost, and if the cost becomes high, it is no good.

The 2M is, of course, not ideal. And the "ideal" depends on many factors,
alike to vmstat. And, actually I dream about deriving the window size from
zone->stat_threshold, which would make the window automatically adjustable
for different "machine sizes" (as we do in calculate_normal_threshold(),
in vmstat.c).

But again, this is all "implementation details"; tunable stuff that we can
either adjust ourselves as needed, or try to be smart, i.e. apply some
heuristics, again, as in vmstat.

Thanks,
Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
