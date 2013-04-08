Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 6F1C06B00F9
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:37:04 -0400 (EDT)
Message-ID: <1365431076.2186.1.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/3] resource: Add release_mem_region_adjustable()
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 08 Apr 2013 08:24:36 -0600
In-Reply-To: <20130407040136.GA13533@ram.oc3035372033.ibm.com>
References: <1364919450-8741-1-git-send-email-toshi.kani@hp.com>
	 <1364919450-8741-3-git-send-email-toshi.kani@hp.com>
	 <20130403053720.GA26398@ram.oc3035372033.ibm.com>
	 <1365018905.11159.113.camel@misato.fc.hp.com>
	 <20130404064849.GA5709@ram.oc3035372033.ibm.com>
	 <1365084464.11159.118.camel@misato.fc.hp.com>
	 <20130407040136.GA13533@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Sun, 2013-04-07 at 12:01 +0800, Ram Pai wrote:
> On Thu, Apr 04, 2013 at 08:07:44AM -0600, Toshi Kani wrote:
> > On Thu, 2013-04-04 at 14:48 +0800, Ram Pai wrote:
> > > On Wed, Apr 03, 2013 at 01:55:05PM -0600, Toshi Kani wrote:
> > > > On Wed, 2013-04-03 at 13:37 +0800, Ram Pai wrote:
> > > > > On Tue, Apr 02, 2013 at 10:17:29AM -0600, Toshi Kani wrote:
> > > > > > +	while ((res = *p)) {
> > > 
> > > ...snip...
> > > 
> > > > > > +		if (res->start > start || res->end < end) {
> > > > > 
> > > > > This check looks sub-optimal; possbily wrong, to me.  if the res->start
> > > > > is greater than 'start', then obviously its sibling's start will
> > > > > also be greater than 'start'. So it will loop through all the
> > > > > resources unnecesarily.
> > > > 
> > > > I think this check is necessary to check if the requested range fits
> > > > into a resource.  It needs to check both sides to verify this.  I will
> > > > add some comment on this check.
> > > > 
> > > > >   you might want something like
> > > > > 
> > > > > 		if (start >= res->end) {
> > > > 
> > > > I agree that this list is sorted, so we can optimize an error case (i.e.
> > > > no matching entry is found) with an additional check.  I will add the
> > > > following check at the beginning of the while loop.  
> > > > 
> > > >                 if (res->start >= end)
> > > >                         break;
> > > > 
> > > > I also realized that the function returns 0 when no matching entry is
> > > > found.  I will change it to return -EINVAL as well.  
> > > 
> > > ok. this will take care of it.
> > > 
> > > > 
> > > > > 		
> > > > > > +			p = &res->sibling;
> > > > > > +			continue;
> > > > > > +		}
> > > > > > +
> > > > > > +		if (!(res->flags & IORESOURCE_MEM)) {
> > > > > > +			ret = -EINVAL;
> > > > > > +			break;
> > > > > > +		}
> > > > > > +
> > > > > > +		if (!(res->flags & IORESOURCE_BUSY)) {
> > > > > > +			p = &res->child;
> > > > > > +			continue;
> > > > > > +		}
> > > > > > +
> > > > > > +		if (res->start == start && res->end == end) {
> > > > > > +			/* free the whole entry */
> > > > > > +			*p = res->sibling;
> > > > > > +			kfree(res);
> > > > > 
> > > > > This is incomplete. the prev resource's sibling should now point to
> > > > > this resource's sibling. The parent's child has to be updated if
> > > > > this resource is the first child resource. no?
> > > > 
> > > > If this resource is the first child, *p is set to &parent->child.  So,
> > > > it will update the parents' child.
> > > 
> > > But if the resource is not the parent's first child? will it update the
> > > previous siblings ->sibling ?
> > 
> > Yes.  When it continues in the while loop, p is set to &res->sibling.
> > So, it will update the previous sibling's ->sibling.
> 
> You are right. It does update the pointers correctly. I mis-read the
> code.

No problem.  Thanks for reviewing it!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
