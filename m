Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 84A1F6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 07:12:58 -0500 (EST)
Date: Mon, 19 Dec 2011 13:12:55 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Android low memory killer vs. memory pressure notifications
Message-ID: <20111219121255.GA2086@tiehlicka.suse.cz>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111219025328.GA26249@oksana.dev.rtsoft.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

[Didn't get to the patch yet but a comment on memcg]

On Mon 19-12-11 06:53:28, Anton Vorontsov wrote:
[...]
> - Use memory controller cgroup (CGROUP_MEM_RES_CTLR) notifications from
>   the kernel side, plus userland "manager" that would kill applications.
> 
>   The main downside of this approach is that mem_cg needs 20 bytes per
>   page (on a 32 bit machine). So on a 32 bit machine with 4K pages
>   that's approx. 0.5% of RAM, or, in other words, 5MB on a 1GB machine.

page_cgroup is 16B per page and with the current Johannes' memcg
naturalization work (in the mmotm tree) we are down to 8B per page (we
got rid of lru). Kamezawa has some patches to get rid of the flags so we
will be down to 4B per page on 32b. Is this still too much?
I would be really careful about a yet another lowmem notification
mechanism.

>   0.5% doesn't sound too bad, but 5MB does, quite a little bit. So,
>   mem_cg feels like an overkill for this simple task (see the driver at
>   the very bottom).

Why is it an overkill? I think that having 2 groups (active and
inactive) and move tasks between then sounds quite elegant. You can
implement an user space oom handler in both groups (active will just
move a task to the inactive group which inactive will kill a task which
hasn't been used for the longest time).
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
