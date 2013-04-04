Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 671896B00AB
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 02:49:08 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 4 Apr 2013 00:49:07 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 770EF19D8045
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 00:48:57 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r346n1Ro122238
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 00:49:01 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r346piCZ016591
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 00:51:45 -0600
Date: Thu, 4 Apr 2013 14:48:49 +0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 2/3] resource: Add release_mem_region_adjustable()
Message-ID: <20130404064849.GA5709@ram.oc3035372033.ibm.com>
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1364919450-8741-1-git-send-email-toshi.kani@hp.com>
 <1364919450-8741-3-git-send-email-toshi.kani@hp.com>
 <20130403053720.GA26398@ram.oc3035372033.ibm.com>
 <1365018905.11159.113.camel@misato.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365018905.11159.113.camel@misato.fc.hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tmac@hp.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, jiang.liu@huawei.com

On Wed, Apr 03, 2013 at 01:55:05PM -0600, Toshi Kani wrote:
> On Wed, 2013-04-03 at 13:37 +0800, Ram Pai wrote:
> > On Tue, Apr 02, 2013 at 10:17:29AM -0600, Toshi Kani wrote:
> > > +	while ((res = *p)) {

...snip...

> > > +		if (res->start > start || res->end < end) {
> > 
> > This check looks sub-optimal; possbily wrong, to me.  if the res->start
> > is greater than 'start', then obviously its sibling's start will
> > also be greater than 'start'. So it will loop through all the
> > resources unnecesarily.
> 
> I think this check is necessary to check if the requested range fits
> into a resource.  It needs to check both sides to verify this.  I will
> add some comment on this check.
> 
> >   you might want something like
> > 
> > 		if (start >= res->end) {
> 
> I agree that this list is sorted, so we can optimize an error case (i.e.
> no matching entry is found) with an additional check.  I will add the
> following check at the beginning of the while loop.  
> 
>                 if (res->start >= end)
>                         break;
> 
> I also realized that the function returns 0 when no matching entry is
> found.  I will change it to return -EINVAL as well.  

ok. this will take care of it.

> 
> > 		
> > > +			p = &res->sibling;
> > > +			continue;
> > > +		}
> > > +
> > > +		if (!(res->flags & IORESOURCE_MEM)) {
> > > +			ret = -EINVAL;
> > > +			break;
> > > +		}
> > > +
> > > +		if (!(res->flags & IORESOURCE_BUSY)) {
> > > +			p = &res->child;
> > > +			continue;
> > > +		}
> > > +
> > > +		if (res->start == start && res->end == end) {
> > > +			/* free the whole entry */
> > > +			*p = res->sibling;
> > > +			kfree(res);
> > 
> > This is incomplete. the prev resource's sibling should now point to
> > this resource's sibling. The parent's child has to be updated if
> > this resource is the first child resource. no?
> 
> If this resource is the first child, *p is set to &parent->child.  So,
> it will update the parents' child.

But if the resource is not the parent's first child? will it update the
previous siblings ->sibling ?

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
