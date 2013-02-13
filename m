Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 0CB7C6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 02:23:07 -0500 (EST)
Received: by mail-oa0-f54.google.com with SMTP id n12so995246oag.13
        for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:23:07 -0800 (PST)
Date: Tue, 12 Feb 2013 23:19:22 -0800
From: Anton Vorontsov <anton@enomsg.org>
Subject: Re: [PATCH] memcg: Add memory.pressure_level events
Message-ID: <20130213071922.GB20543@lizard.gateway.2wire.net>
References: <20130211000220.GA28247@lizard.gateway.2wire.net>
 <5118C522.3070905@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <5118C522.3070905@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

Hi Glauber,

On Mon, Feb 11, 2013 at 02:17:06PM +0400, Glauber Costa wrote:
[...]
> > +static struct vmpressure *vmpressure_parent(struct vmpressure *vmpr)
> > +{
> > +	struct cgroup *cg = vmpr_to_css(vmpr)->cgroup->parent;
> > +
> > +	if (!cg)
> > +		return NULL;
> > +	return cg_to_vmpr(cg);
> > +}
> 
> Unfortunately, "parent" in memcg have different meanings for information
> propagation purposes depending on the value of the flag "use_hierarchy".
> That is set for deprecation, but still...
> 
> I suggest you use the helper mem_cgroup_parent, that will already give
> you the right parent (either immediate parent or root) with all that
> taken into account.

Got it, will change.

[...]
> > +void __init enable_pressure_cgroup(void)
> > +{
> > +	WARN_ON(cgroup_add_cftypes(&mem_cgroup_subsys,
> > +				   vmpressure_cgroup_files));
> > +}
> 
> There is no functionality discovery going on here, and this is
> conditional on nothing. Isn't it better then to just add the register +
> read functions to memcontrol.c and add the files in the memcontrol cftype ?

I was trying to make the stuff similar to the existing CONFIG_MEMCG_SWAP
code, which does this kind of adding files to the cgroup. But I can surely
place files into memcontrol cftype as you suggest.

Thanks a lot for the comments!

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
