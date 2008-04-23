Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3NIUVQa007073
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 14:30:31 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3NIX2qq196782
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 12:33:02 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3NIX0fr030754
	for <linux-mm@kvack.org>; Wed, 23 Apr 2008 12:33:02 -0600
Date: Wed, 23 Apr 2008 11:32:52 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080423183252.GA10548@us.ibm.com>
References: <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de> <20080422165602.GA29570@us.ibm.com> <20080423010259.GA17572@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423010259.GA17572@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [03:03:00 +0200], Nick Piggin wrote:
> On Tue, Apr 22, 2008 at 09:56:02AM -0700, Nishanth Aravamudan wrote:
> > On 22.04.2008 [07:14:47 +0200], Nick Piggin wrote:
> > 
> > > So anyway, underneath that directory, we should have more
> > > subdirectories grouping subsystems or sumilar functionality. We aren't
> > > tuning node, but hugepages subsystem.
> > > 
> > > /sys/kernel/huge{tlb|pages}/
> > > 
> > > Under that directory could be global settings as well as per node
> > > settings or subdirectories and so on. The layout should be similar to
> > > /proc/sys/* IMO. Actually it should be much neater since we have some
> > > hindsight, but unfortunately it is looking like it is actually messier
> > > ;)
> > 
> > Well, that's where I start to get a little stymied. It seems odd to me
> > to have some per-node information in one place and some in another,
> > where the two are not even rooted at the same location, beyond both
> > being in sysfs.
> 
> Why are nodes special? Why wouldn't you also group per-CPU information
> in one place, for example?
> 
> Anyway, I'd argue that you wouldn't group either of those things
> primarily.  You would group by functionality first.
> 
> If you wanted to tweak or view your hugepages parameters, where do you
> start? /sys/kernel/node is unintuitive; /sys/kernel/hugepages is easy.

Let's be clear, here. I do *not* agree with Christoph's /sys/kernel/node
proposal. I was referring simply to how things were laid out now, and
that we'd have per-node control of hugepages in /sys/kernel/hugepages
and per-node memory information in /sys/devices/system/node.

I have been convinced that /sys/kernel/hugepages to control all hugepage
functionality is reasonable. My primary concern is making sure the code
is clean to move the per-node patches to that location; however, I am
going to focus on moving nr_{,overcommit}_hugepages to sysfs first.

> > Perhaps, as I've mentioned elsewhere, we simply have symlinks
> > underneath /sys/kernel/hugepages into /sys/devices/system/node/nodeX
> > ... but the immediate ugliness I see there is either we duplicate
> > the directories, or we symlink the
> 
> I don't like the idea of putting kernel implementation parameters in
> /sys/devices/ (grey area for device drivers, perhaps).

Ack.

> > directories and there are now to paths into all the NUMA information,
> > where one (/sys/kernel/hugepages/nodeX) seems like it should only have
> > hugepage information.
> 
> But the idea of getting "all NUMA information" from one place just
> seems wrong to me. Getting all *hardware* NUMA information from one
> place is fine. But kernel implementation wise I think you are really
> interested in subsystems *first*.

Ok.

> Just to demonstrate how badly "all NUMA information in one place"
> generalises: you also then need a completely different place to store
> global information for that subsystem, and a different place again to
> store per-CPU information.
> 
> 
> > I'd prefer hugepages to hugetlb, I think, but don't necessarily care
> > one way or the other.
> 
> I'm fine with that. 

Ok, thanks.

> > > Let's really try to put some thought into new sysfs locations. Not
> > > just will it work, but is it logical and will it work tomorrow...
> > 
> > I agree and that's why I keep sending out e-mails about it :) Perhaps I
> > should prototype /sys/kernel/hugepages so we can see how it would look
> > as a first step, and then decide given that layout how we want the
> > per-node information to be presented?
> 
> Sure.

So, I think, we pretty much agree on how things should be:

Direct translation of the current sysctl:

/sys/kernel/hugepages/nr_hugepages
                      nr_overcommit_hugepages

Adding multiple pools:

/sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
                      nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
                      nr_hugepages_${default_size}
                      nr_overcommit_hugepages_${default_size}
                      nr_hugepages_${other_size1}
                      nr_overcommit_hugepages_${other_size2}

Adding per-node control:

/sys/kernel/hugepages/nr_hugepages -> nr_hugepages_${default_size}
                      nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
                      nr_hugepages_${default_size}
                      nr_overcommit_hugepages_${default_size}
                      nr_hugepages_${other_size1}
                      nr_overcommit_hugepages_${other_size2}
                      nodeX/nr_hugepages -> nr_hugepages_${default_size}
                            nr_overcommit_hugepages -> nr_overcommit_hugepages_${default_size}
                            nr_hugepages_${default_size}
                            nr_overcommit_hugepages_${default_size}
                            nr_hugepages_${other_size1}
                            nr_overcommit_hugepages_${other_size2}

How does that look? Does anyone have any problems with such an
arrangement?

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
