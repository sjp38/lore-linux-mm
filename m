Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A99A48D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 09:59:48 -0500 (EST)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2AEsNiM014998
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 07:54:23 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2AExafC060920
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 07:59:36 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2AExYGk016069
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 07:59:36 -0700
Subject: Re: [PATCH R4 7/7] xen/balloon: Memory hotplug support for Xen
 balloon driver
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110310090207.GB13978@router-fw-old.local.net-space.pl>
References: <20110308215049.GH27331@router-fw-old.local.net-space.pl>
	 <1299628939.9014.3499.camel@nimitz>
	 <20110310090207.GB13978@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Thu, 10 Mar 2011 06:59:25 -0800
Message-ID: <1299769165.8937.2435.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2011-03-10 at 10:02 +0100, Daniel Kiper wrote:
> On Tue, Mar 08, 2011 at 04:02:19PM -0800, Dave Hansen wrote:
> > > +	mutex_lock(&balloon_mutex);
> > > +
> > > +	__balloon_append(page);
> > > +
> > > +	if (balloon_stats.hotplug_pages)
> > > +		--balloon_stats.hotplug_pages;
> > > +	else
> > > +		--balloon_stats.balloon_hotplug;
> > > +
> > > +	mutex_unlock(&balloon_mutex);
> > > +
> > > +	return NOTIFY_STOP;
> > > +}
> >
> > I'm not a _huge_ fan of these notifier chains, but I guess it works.
> 
> Could you tell me why ??? I think that in that case new
> (faster, simpler, etc.) mechanism is an overkill. I prefer
> to use something which is writen, tested and ready for usage.

Personally, I find it much harder to figure out what's going on there
than if we had some #ifdefs or plain old function calls.  

It would be one thing if we really had a large or undefined set of
things that needs to interact here, but we really just need to
conditionally free the page either in to the buddy allocator or back to
Xen.  I think that calls for a simpler mechanism than notifier_blocks.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
