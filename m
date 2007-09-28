Subject: Re: [PATCH 5/6] Filter based on a nodemask as well as a gfp_mask
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070928182825.GA9779@skynet.ie>
References: <20070928142326.16783.98817.sendpatchset@skynet.skynet.ie>
	 <20070928142506.16783.99266.sendpatchset@skynet.skynet.ie>
	 <1190993823.5513.10.camel@localhost>  <20070928182825.GA9779@skynet.ie>
Content-Type: text/plain
Date: Fri, 28 Sep 2007 17:03:48 -0400
Message-Id: <1191013429.5513.45.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-28 at 19:28 +0100, Mel Gorman wrote:
> On (28/09/07 11:37), Lee Schermerhorn didst pronounce:
> > Still need to fix 'nodes_intersect' -> 'nodes_intersects'.  See below.
> > 
<snip>
> > > diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c linux-2.6.23-rc8-mm2-030_filter_nodemask/kernel/cpuset.c
> > > --- linux-2.6.23-rc8-mm2-020_zoneid_zonelist/kernel/cpuset.c	2007-09-28 15:49:39.000000000 +0100
> > > +++ linux-2.6.23-rc8-mm2-030_filter_nodemask/kernel/cpuset.c	2007-09-28 15:49:57.000000000 +0100
> > > @@ -1516,22 +1516,14 @@ nodemask_t cpuset_mems_allowed(struct ta
> > >  }
> > >  
> > >  /**
> > > - * cpuset_zonelist_valid_mems_allowed - check zonelist vs. curremt mems_allowed
> > > - * @zl: the zonelist to be checked
> > > + * cpuset_nodemask_valid_mems_allowed - check nodemask vs. curremt mems_allowed
> > > + * @nodemask: the nodemask to be checked
> > >   *
> > > - * Are any of the nodes on zonelist zl allowed in current->mems_allowed?
> > > + * Are any of the nodes in the nodemask allowed in current->mems_allowed?
> > >   */
> > > -int cpuset_zonelist_valid_mems_allowed(struct zonelist *zl)
> > > +int cpuset_nodemask_valid_mems_allowed(nodemask_t *nodemask)
> > >  {
> > > -	int i;
> > > -
> > > -	for (i = 0; zl->_zonerefs[i].zone; i++) {
> > > -		int nid = zonelist_node_idx(zl->_zonerefs[i]);
> > > -
> > > -		if (node_isset(nid, current->mems_allowed))
> > > -			return 1;
> > > -	}
> > > -	return 0;
> > > +	return nodes_intersect(nodemask, current->mems_allowed);
> >                  ^^^^^^^^^^^^^^^ -- should be nodes_intersects, I think.
> 
> Crap, you're right, I missed the warning about implicit declarations. I
> apologise. This is the corrected version

Mel:  

When I'm rebasing a patch series, I use a little script [shell function,
actually] to make just the sources modified by each patch, before moving
on to the next.  That way, I have fewer log messages to look at, and
warnings and such jump out so I can fix them while I'm at the patch that
causes them.  That's how I caught this one.  Here's the script, in case
you're interested:

--------------------------

#qm - quilt make -- attempt to compile all .c's in patch
# Note:  some files might not compile if they wouldn't build in 
# the current config.
qm()
{
#	__in_ktree qm || return

	make silentoldconfig; # in case patch changes a Kconfig*

	quilt files | \
	while read file xxx
	do
		ftype=${file##*.}
		if [[ "$ftype" != "c" ]]
		then
			# echo "Skipping $file" >&2
			continue
		fi
		f=${file%.*}
		echo "make $f.o" >&2
		make $f.o
	done
}

---------------------------

This is part of a larger set of quilt wrappers that, being basically
lazy, I use to reduce typing.   I've commented out one dependency on
other parts of the "environment".  To use this, I build an unpatched
kernel before starting the rebase, so that the .config and all of the
pieces are in place for the incremental makes.  

Works for me...

Later,
Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
