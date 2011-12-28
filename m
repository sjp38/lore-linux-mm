Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id BDAB46B004D
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 19:08:16 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EA94E3EE081
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 09:08:14 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D35C345DE52
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 09:08:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B27DE45DE50
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 09:08:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6F9C1DB802F
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 09:08:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59B2D1DB803B
	for <linux-mm@kvack.org>; Wed, 28 Dec 2011 09:08:14 +0900 (JST)
Date: Wed, 28 Dec 2011 09:06:56 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Kswapd in 3.2.0-rc5 is a CPU hog
Message-Id: <20111228090656.4b24f36d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBBVKqwiDRgpQnVEzB6kQc2X0rCyMpNUzJb0-akJ9OTv0g@mail.gmail.com>
References: <1324437036.4677.5.camel@hakkenden.homenet>
	<20111221095249.GA28474@tiehlicka.suse.cz>
	<20111221225512.GG23662@dastard>
	<1324630880.562.6.camel@rybalov.eng.ttk.net>
	<20111223102027.GB12731@dastard>
	<1324638242.562.15.camel@rybalov.eng.ttk.net>
	<20111223204503.GC12731@dastard>
	<CAJd=RBDa4LT1gbh6zPx+bzoOtSUeX=puJe6DVC-WyKoF4nw-dg@mail.gmail.com>
	<1324808519.29243.8.camel@hakkenden.homenet>
	<CAJd=RBAyw2rapPPhYFYKxyjEQ-EAG2j_UCP-4A6Uk5GSP5LE6A@mail.gmail.com>
	<20111227092052.f2b02637.kamezawa.hiroyu@jp.fujitsu.com>
	<CAJd=RBBVKqwiDRgpQnVEzB6kQc2X0rCyMpNUzJb0-akJ9OTv0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Nikolay S." <nowhere@hakkenden.ath.cx>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Dec 2011 21:33:04 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Tue, Dec 27, 2011 at 8:20 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 26 Dec 2011 20:35:46 +0800
> > Hillf Danton <dhillf@gmail.com> wrote:
> >
> >> On Sun, Dec 25, 2011 at 6:21 PM, Nikolay S. <nowhere@hakkenden.ath.cx> wrote:
> >> >
> >> > Uhm.., is this patch against 3.2-rc4? I can not apply it. There's no
> >> > mem_cgroup_lru_del_list(), but void mem_cgroup_del_lru_list(). Should I
> >> > place changes there?
> >> >
> >> > And also, -rc7 is here. May the problem be addressed as part of some
> >> > ongoing work? Is there any reason to try -rc7 (the problem requires
> >> > several days of uptime to become obvious)?
> >> >
> >>
> >> Sorry, Nikolay, it is not based on the -next, nor on the -rc5(I assumed it was).
> >> The following is based on -next, and if you want to test -rc5, please
> >> grep MEM_CGROUP_ZSTAT mm/memcontrol.c and change it.
> >>
> >> Best regard
> >>
> >
> > Hmm ? memcg is used ? Why do you consider this will be a help ?
> >
> 
> Hi Kame
> 
> Please see the livelock at
>         https://lkml.org/lkml/2011/12/23/222
> 
> and if it is related to the hog here, please check if the following is
> in right direction.
> 

But linux-next and his 3.2-rc5 has totally different LRU design.
3.2-rc doesn't have unified memcg/global LRU and memcg doesn't affect
kswapd behavior if not used.

Thanks,
-Kame

> Thanks
> Hillf
> ---
> 
> --- a/mm/memcontrol.c	Mon Dec 26 20:34:38 2011
> +++ b/mm/memcontrol.c	Tue Dec 27 20:05:12 2011
> @@ -3637,6 +3637,7 @@ static int mem_cgroup_force_empty_list(s
>  	list = &mz->lruvec.lists[lru];
> 
>  	loop = MEM_CGROUP_ZSTAT(mz, lru);
> +	WARN_ON((long)loop < 0);
>  	/* give some margin against EBUSY etc...*/
>  	loop += 256;
>  	busy = NULL;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
