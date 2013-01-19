Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 4F42F6B0005
	for <linux-mm@kvack.org>; Fri, 18 Jan 2013 19:10:47 -0500 (EST)
Date: Sat, 19 Jan 2013 11:10:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
Message-ID: <20130119001042.GR2498@dastard>
References: <1354058086-27937-10-git-send-email-david@fromorbit.com>
 <50F6FDC8.5020909@parallels.com>
 <20130116225521.GF2498@dastard>
 <50F7475F.90609@parallels.com>
 <20130117042245.GG2498@dastard>
 <50F84118.7030608@parallels.com>
 <20130118001029.GK2498@dastard>
 <50F893D2.7080103@parallels.com>
 <20130118081133.GQ2498@dastard>
 <50F99E08.4060107@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F99E08.4060107@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On Fri, Jan 18, 2013 at 11:10:00AM -0800, Glauber Costa wrote:
> On 01/18/2013 12:11 AM, Dave Chinner wrote:
> > On Thu, Jan 17, 2013 at 04:14:10PM -0800, Glauber Costa wrote:
> >> On 01/17/2013 04:10 PM, Dave Chinner wrote:
> >>> And then each object uses:
> >>>
> >>> struct lru_item {
> >>> 	struct list_head global_list;
> >>> 	struct list_head memcg_list;
> >>> }
> >> by objects you mean dentries, inodes, and the such, right?
> > 
> > Yup.
> > 
> >> Would it be acceptable to you?
> > 
> > If it works the way I think it should, then yes.
> > 
> >> We've been of course doing our best to avoid increasing the size of the
> >> objects, therefore this is something we've never mentioned. However, if
> >> it would be acceptable from the fs POV, this would undoubtedly make our
> >> life extremely easier.
> > 
> > I've been trying hard to work out how to avoid increasing the size
> > of structures as well. But if we can't work out how to implement
> > something sanely with only a single list head per object to work
> > from, then increasing the size of objects is something that we need
> > to consider if it solves all the problems we are trying to solve.
> > 
> > i.e. if adding a second list head makes the code dumb, simple,
> > obviously correct and hard to break then IMO it's a no-brainer.
> > But we have to tick all the right boxes first...
> > 
> 
> One of our main efforts recently has been trying to reduce memcg impact
> when it is not in use, even if its compiled in. So what really bothers
> me here is the fact that we are increasing the size of dentries and
> inodes no matter what.
> 
> Still within the idea of exploring the playing field, would an
> indirection be worth it ?
> We would increase the total per-object memory usage by 8 bytes instead
> of 16: the dentry gets a pointer, and a separate allocation for the
> list_lru.

A separate allocation is really not an option. We can't do an
allocation in where dentries/inodes/other objects are added to the
LRU because they are under object state spinlocks, and adding a
potential memory allocation failure to the "add to lru" case is
pretty nasty, IMO.

> Embedding the lru is certainly easier from my PoV, the main question is
> how much do you, as a fs representative, value those 8 bytes?

Some things are worth using a few extra bytes, and thats my point.
The question of whether memcg enabled kernels need to grow objects
for sane memory management behaviour is what I'm trying to explore
here. We might end up deciding that a single list head is all that
is needed, but lets not constrain our thinking to "we must only use
elements existing in the current structures" and hence rule out
solutions that may work far better than any single list algorithm
possibly can without having first explored them....

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
