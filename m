Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 89ACD6B0031
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 23:41:19 -0400 (EDT)
Date: Thu, 6 Jun 2013 13:41:16 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v10 22/35] shrinker: convert remaining shrinkers to
 count/scan API
Message-ID: <20130606034116.GT29338@dastard>
References: <1370287804-3481-1-git-send-email-glommer@openvz.org>
 <1370287804-3481-23-git-send-email-glommer@openvz.org>
 <20130605160821.59adf9ad4efe48144fd9e237@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605160821.59adf9ad4efe48144fd9e237@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Chuck Lever <chuck.lever@oracle.com>, "J. Bruce Fields" <bfields@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>

On Wed, Jun 05, 2013 at 04:08:21PM -0700, Andrew Morton wrote:
> On Mon,  3 Jun 2013 23:29:51 +0400 Glauber Costa <glommer@openvz.org> wrote:
> 
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Convert the remaining couple of random shrinkers in the tree to the
> > new API.
> 
> Gee we have a lot of shrinkers.

And a large number of them are busted in some way, too :/

> > --- a/arch/x86/kvm/mmu.c
> > +++ b/arch/x86/kvm/mmu.c
> > @@ -4213,13 +4213,14 @@ restart:
> >  	spin_unlock(&kvm->mmu_lock);
> >  }
> >  
> > -static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
> > +static long
> > +mmu_shrink_scan(
> > +	struct shrinker		*shrink,
> > +	struct shrink_control	*sc)
> >
> > ...
> >
> > --- a/net/sunrpc/auth.c
> > +++ b/net/sunrpc/auth.c
> > -static int
> > -rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
> > +static long
> > +rpcauth_cache_shrink_scan(
> > +	struct shrinker		*shrink,
> > +	struct shrink_control	*sc)
> > +
> 
> It is pretty poor form to switch other people's code into this very
> non-standard XFSish coding style.  The maintainers are just going to
> have to go wtf and switch it back one day.

My bad.  That's left over from when I was originally developing the
the patch set passed a couple more parameters to the shrinkers
pushing every single declaration to well over the line length
limits. I never converted them back as I removed the extra
parameters, because it's far easier to just have delete a line that
delete a variable and reformat the entire function declaration....

> Really, it would be best if you were to go through the entire patchset
> and undo all this.

Sure, that can be done.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
