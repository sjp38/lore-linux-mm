Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 3655A6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 02:18:52 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id ta14so961351obb.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:18:51 -0800 (PST)
Date: Tue, 12 Feb 2013 23:15:03 -0800
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH] memcg: Add memory.pressure_level events
Message-ID: <20130213071503.GA20543@lizard.gateway.2wire.net>
References: <20130211000220.GA28247@lizard.gateway.2wire.net>
 <xr9338x01zpw.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <xr9338x01zpw.fsf@gthelen.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi Greg,

Thanks for taking a look!

On Tue, Feb 12, 2013 at 10:42:51PM -0800, Greg Thelen wrote:
[...]
> > +static unsigned long vmpressure_calc_level(unsigned int win,
> > +					   unsigned int s, unsigned int r)
> 
> Should seems like the return type of this function should be enum
> vmpressure_levels?  If yes, then the 'return 0' below should be
> VMPRESSURE_LOW.  And it would be nice if there was a little comment
> describing the meaning of the win, s, and r parameters.  The "We
> calculate ..." comment below makes me think that win is the number of
> pages scanned, which makes me wonder what the s param is.

Got it, will make it clearer.

[...]
> > +static bool vmpressure_event(struct vmpressure *vmpr,
> > +			     unsigned long s, unsigned long r)
> > +{
> > +	struct vmpressure_event *ev;
> > +	int level = vmpressure_calc_level(vmpressure_win, s, r);
> > +	bool signalled = 0;
> s/bool/int/

Um... I surely can do this, but why do you think it is a good idea?

> > +
> > +	mutex_lock(&vmpr->events_lock);
> > +
> > +	list_for_each_entry(ev, &vmpr->events, node) {
> > +		if (level >= ev->level) {
> > +			eventfd_signal(ev->efd, 1);
> > +			signalled++;
> > +		}
> > +	}
> > +
> > +	mutex_unlock(&vmpr->events_lock);
> > +
> > +	return signalled;

[...]
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1982,6 +1982,10 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  			}
> >  			memcg = mem_cgroup_iter(root, memcg, &reclaim);
> >  		} while (memcg);
> > +
> > +		vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> > +			   sc->nr_scanned - nr_scanned, nr_reclaimed);
> 
> (sc->nr_scanned - nr_scanned) is the number of pages scanned in above
> while loop but nr_reclaimed is the starting position of the reclaim
> counter before the loop.  It seems like you want:
> 	vmpressure(sc->gfp_mask, sc->target_mem_cgroup,
> 		   sc->nr_scanned - nr_scanned, 
> 		   sc->nr_reclaimed - nr_reclaimed);

Yeah, right you are. There actually was a merge conflict when I rebased my
patch onto linux-next, and it seems that I overlooked that the logic has
changed. So we might get a bit distorted pressure because of that.

Thanks for catching this!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
