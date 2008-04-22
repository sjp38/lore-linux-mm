Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3MGuEFe031201
	for <linux-mm@kvack.org>; Tue, 22 Apr 2008 12:56:14 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3MGu831129400
	for <linux-mm@kvack.org>; Tue, 22 Apr 2008 10:56:10 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3MGu66k010744
	for <linux-mm@kvack.org>; Tue, 22 Apr 2008 10:56:06 -0600
Date: Tue, 22 Apr 2008 09:56:02 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080422165602.GA29570@us.ibm.com>
References: <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com> <20080422051447.GI21993@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080422051447.GI21993@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Greg KH <gregkh@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.04.2008 [07:14:47 +0200], Nick Piggin wrote:
> On Thu, Apr 17, 2008 at 04:22:17PM -0700, Christoph Lameter wrote:
> > On Thu, 17 Apr 2008, Nishanth Aravamudan wrote:
> > 
> > > > Do you see a particular more-sysfs-way here, Greg?
> > > 
> > > So I've received no comments yet? Perhaps I should leave things the way
> > > they are (per-node files in /sys/devices/system/node) and add
> > > nr_hugepages to /sys/kernel?
> > 
> > The strange location of the node directories has always irked me.
> > > 
> > > Do we want to put it in a subdirectory of /sys/kernel? What should the
> > > subdir be called? "hugetlb" (refers to the implementation?) or
> > > "hugepages"?
> > 
> > How about:
> > 
> > /sys/kernel/node<nr>/<node specific setting/status files> ?
> 
> I don't like /sys/kernel/node :P

Neither do I. My reasoning is that it duplicates information available
elsewhere -- what Christoph was suggesting, I think, was moving all of
the node files there. That seems like it might be outside the scope of
our discussion given the files we have now (but becomes intertwined once
we start talking about the intersection of hugetlb + NUMA in per-node
control).

> Under /sys/kernel, we should have parameters to set and query various
> kernel functionality. Control of the kernel software implementation. I
> think this is pretty well agreed (although there are maybe grey areas
> I guess)

I am fine with this claim.

> So anyway, underneath that directory, we should have more
> subdirectories grouping subsystems or sumilar functionality. We aren't
> tuning node, but hugepages subsystem.
> 
> /sys/kernel/huge{tlb|pages}/
> 
> Under that directory could be global settings as well as per node
> settings or subdirectories and so on. The layout should be similar to
> /proc/sys/* IMO. Actually it should be much neater since we have some
> hindsight, but unfortunately it is looking like it is actually messier
> ;)

Well, that's where I start to get a little stymied. It seems odd to me
to have some per-node information in one place and some in another,
where the two are not even rooted at the same location, beyond both
being in sysfs. Perhaps, as I've mentioned elsewhere, we simply have
symlinks underneath /sys/kernel/hugepages into
/sys/devices/system/node/nodeX ... but the immediate ugliness I see
there is either we duplicate the directories, or we symlink the
directories and there are now to paths into all the NUMA information,
where one (/sys/kernel/hugepages/nodeX) seems like it should only have
hugepage information.

I'd prefer hugepages to hugetlb, I think, but don't necessarily care one
way or the other.

> Let's really try to put some thought into new sysfs locations. Not
> just will it work, but is it logical and will it work tomorrow...

I agree and that's why I keep sending out e-mails about it :) Perhaps I
should prototype /sys/kernel/hugepages so we can see how it would look
as a first step, and then decide given that layout how we want the
per-node information to be presented?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
