Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id C8C588D0001
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:43:54 -0400 (EDT)
Date: Thu, 8 Aug 2013 16:43:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] memcg: limit the number of thresholds per-memcg
Message-ID: <20130808144351.GD3189@dhcp22.suse.cz>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <20130807132210.GD27006@htj.dyndns.org>
 <20130807134654.GJ8184@dhcp22.suse.cz>
 <20130807135818.GG27006@htj.dyndns.org>
 <20130807143727.GA13279@dhcp22.suse.cz>
 <20130807220513.GA8068@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807220513.GA8068@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Thu 08-08-13 01:05:13, Kirill A. Shutemov wrote:
> On Wed, Aug 07, 2013 at 04:37:27PM +0200, Michal Hocko wrote:
> > On Wed 07-08-13 09:58:18, Tejun Heo wrote:
> > > Hello,
> > > 
> > > On Wed, Aug 07, 2013 at 03:46:54PM +0200, Michal Hocko wrote:
> > > > OK, I have obviously misunderstood your concern mentioned in the other
> > > > email. Could you be more specific what is the DoS scenario which was
> > > > your concern, then?
> > > 
> > > So, let's say the file is write-accessible to !priv user which is
> > > under reasonable resource limits.  Normally this shouldn't affect priv
> > > system tools which are monitoring the same event as it shouldn't be
> > > able to deplete resources as long as the resource control mechanisms
> > > are configured and functioning properly; however, the memory usage
> > > event puts all event listeners into a single contiguous table which a
> > > !priv user can easily expand to a size where the table can no longer
> > > be enlarged and if a priv system tool or another user tries to
> > > register event afterwards, it'll fail.  IOW, it creates a shared
> > > resource which isn't properly provisioned and can be trivially filled
> > > up making it an easy DoS target.
> > 
> > OK, got your point. You are right and I haven't considered the size of
> > the table and the size restrictions of kmalloc. Thanks for pointing this
> > out!
> > ---
> > From cde8a3333296eddd288780e78803610127401b6a Mon Sep 17 00:00:00 2001
> > From: Michal Hocko <mhocko@suse.cz>
> > Date: Wed, 7 Aug 2013 11:11:22 +0200
> > Subject: [PATCH] memcg: limit the number of thresholds per-memcg
> > 
> > There is no limit for the maximum number of threshold events registered
> > per memcg. It is even worse that all the events are stored in a
> > per-memcg table which is enlarged when a new event is registered. This
> > can lead to the following issue mentioned by Tejun:
> > "
> > So, let's say the file is write-accessible to !priv user which is
> > under reasonable resource limits.  Normally this shouldn't affect priv
> > system tools which are monitoring the same event as it shouldn't be
> > able to deplete resources as long as the resource control mechanisms
> > are configured and functioning properly; however, the memory usage
> > event puts all event listeners into a single contiguous table which a
> > !priv user can easily expand to a size where the table can no longer
> > be enlarged and if a priv system tool or another user tries to
> > register event afterwards, it'll fail.  IOW, it creates a shared
> > resource which isn't properly provisioned and can be trivially filled
> > up making it an easy DoS target.
> > "
> > 
> > Let's be more strict and cap the number of events that might be
> > registered. MAX_THRESHOLD_EVENTS value is more or less random. The
> > expectation is that it should be high enough to cover reasonable
> > usecases while not too high to allow excessive resources consumption.
> > 1024 events consume something like 16KB which shouldn't be a big deal
> > and it should be good enough.
> 
> Is it correct that you fix one local DoS by introducing a new one?
> With the page the !priv user can block root from registering a threshold.
> Is it really the way we want to fix it?

OK, I will think about it some more.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
