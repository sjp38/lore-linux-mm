Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92CD76B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 07:35:19 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id a4so52019334lfa.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:35:19 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id b19si446315wmf.40.2016.06.23.04.35.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 04:35:18 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id r201so45683322wme.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 04:35:18 -0700 (PDT)
Date: Thu, 23 Jun 2016 13:35:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Xfs lockdep warning with for-dave-for-4.6 branch
Message-ID: <20160623113516.GG30077@dhcp22.suse.cz>
References: <20160602145048.GS1995@dhcp22.suse.cz>
 <20160602151116.GD3190@twins.programming.kicks-ass.net>
 <20160602154619.GU1995@dhcp22.suse.cz>
 <20160602232254.GR12670@dastard>
 <20160606122022.GH11895@dhcp22.suse.cz>
 <20160615072154.GF26977@dastard>
 <20160621142628.GG30848@dhcp22.suse.cz>
 <20160622010320.GR12670@dastard>
 <20160622123822.GG9208@dhcp22.suse.cz>
 <20160622225816.GY12670@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160622225816.GY12670@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Dave Chinner <david@fromorbit.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Qu Wenruo <quwenruo@cn.fujitsu.com>, xfs@oss.sgi.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

On Thu 23-06-16 08:58:16, Dave Chinner wrote:
> On Wed, Jun 22, 2016 at 02:38:22PM +0200, Michal Hocko wrote:
> > On Wed 22-06-16 11:03:20, Dave Chinner wrote:
> > > On Tue, Jun 21, 2016 at 04:26:28PM +0200, Michal Hocko wrote:
> > > > On Wed 15-06-16 17:21:54, Dave Chinner wrote:
> > [...]
> > > > > There are allocations outside transaction context which need to be
> > > > > GFP_NOFS - this is what KM_NOFS was originally intended for.
> > > > 
> > > > Is it feasible to mark those by the scope NOFS api as well and drop
> > > > the direct KM_NOFS usage? This should help to identify those that are
> > > > lockdep only and use the annotation to prevent from the false positives.
> > > 
> > > I don't understand what you are suggesting here. This all started
> > > because we use GFP_NOFS in a handful of places to shut up lockdep
> > > and you didn't want us to use GFP_NOFS like that. Now it sounds to
> > > me like you are advocating setting unconditional GFP_NOFS allocation
> > > contexts for entire XFS code paths - whether it's necessary or
> > > not - to avoid problems with lockdep false positives.
> > 
> > No, I meant only those paths which need GFP_NOFS for other than lockdep
> > purposes would use the scope api.
> > 
> > Anyway, it seems that we are not getting closer to a desired solution
> > here. Or I am not following it at least...
> > 
> > It seems that we have effectively two possibilities (from the
> > MM/lockdep) POV. Either add an explicit API to disable the reclaim
> > lockdep machinery for all allocation in a certain scope or a GFP mask
> > to to achieve the same for a particular allocation. Which one would work
> > better for the xfs usecase?
> 
> As I've said - if we annotate the XFS call sites appropriately (e.g.
> KM_NOLOCKDEP rather than KM_NOFS), we don't care what lockdep
> mechanism is used to turn off warnings as it will be wholly
> encapsulated inside kmem_alloc() and friends.  This will end up
> similar to how we are currently encapsulate the memalloc_noio_save()
> wrappers in kmem_zalloc_large().

OK, I see. So which way do we go Peter? Are you going to send the GFP
one or is there a way to bribe you to go with a thread flag?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
