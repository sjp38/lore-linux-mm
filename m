Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id B378C6B006C
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 20:54:12 -0500 (EST)
Date: Fri, 21 Dec 2012 12:54:10 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20121221015410.GB15182@dastard>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50D2F4B6.9040108@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50D2F4B6.9040108@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com

On Thu, Dec 20, 2012 at 03:21:26PM +0400, Glauber Costa wrote:
> On 11/28/2012 03:14 AM, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > Now that we have an LRU list API, we can start to enhance the
> > implementation.  This splits the single LRU list into per-node lists
> > and locks to enhance scalability. Items are placed on lists
> > according to the node the memory belongs to. To make scanning the
> > lists efficient, also track whether the per-node lists have entries
> > in them in a active nodemask.
> > 
> 
> I think it is safe to assume that these functions could benefit from
> having more metadata available for them when they run.
> 
> Let's say for instance that a hypothetical person, for some unknown
> reasons, comes with the idea of replicating those lists transparently
> per memcg.
> 
> In this case, it is very useful to know which memcg drives the current
> call. In general, the struct shrink_control already contains a lot of
> data that we use to drive the process. Wouldn't it make sense to also
> pass shrink_control as data to those lists as well?

I considered it, but:

> The only drawback of this, is that it would tie it to the shrinking
> process.

and that's exactly what I didn't want to do. Yes, the shrinkers need
to walk the list, but they will not be/are not the only reason we
need to walk lists and isolate items....

> I am not sure if this is a concern, but it if is, maybe we
> could replace things like :
> 
> +static long
> +list_lru_walk_node(
> +	struct list_lru		*lru,
> +	int			nid,
> +	list_lru_walk_cb	isolate,
> +	void			*cb_arg,
> +	long			*nr_to_walk)
> +{
> 
> with
> 
> +static long
> +list_lru_walk_node(
> +	struct list_lru		*lru,
> +       struct something_like_shrink_control_not_shrink_control *a)
> +{
> 
> This way we can augment the data available for the interface, for
> instance, passing the memcg context, without going patching all the callers.

Yes, that is also something I considered. I just never got around to
doing it as I wasn't sure whether the walking interface woul dbe
acceptible in the first place. If we do use the list walk interface
list this, then we shoul definitely encapsulate all the parameters
in a struct something_like_shrink_control_not_shrink_control. :)

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
