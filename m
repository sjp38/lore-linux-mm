Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5AF16B0290
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:30:47 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id o7so2414699pgc.23
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:30:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m15si610951pga.189.2017.11.07.00.30.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 00:30:46 -0800 (PST)
Date: Tue, 7 Nov 2017 09:30:42 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Guaranteed allocation of huge pages (1G) using movablecore=N
 doesn't seem to work at all
Message-ID: <20171107083042.5lnmsz237ccbituj@dhcp22.suse.cz>
References: <CACAwPwamD4RL9O8wujK_jCKGu=x0dBBmH9O-9078cUEEk4WsMA@mail.gmail.com>
 <CACAwPwYKjK5RT-ChQqqUnD7PrtpXg1WhTHGK3q60i6StvDMDRg@mail.gmail.com>
 <CACAwPwav-eY4_nt=Z7TQB8WMFg+1X5WY2Gkgxph74X7=Ovfvrw@mail.gmail.com>
 <CACAwPwaP05FgxTp=kavwgFZF+LEGO-OSspJ4jH+Y=_uRxiVZaA@mail.gmail.com>
 <CACAwPwY5ss_D9kj7XoLVVkQ9=KXDFCnyDzdoxkGxhJZBNFre3w@mail.gmail.com>
 <CACAwPwYp4TysdH_1w1F9L7BpwFAGR8dNg04F6QASyQeYYNErkg@mail.gmail.com>
 <20171106180406.diowlwanvucnwkbp@dhcp22.suse.cz>
 <CACAwPwaTejMB8yOrkOxpDj297B=Y6bTvw2nAyHsiJKC+aB=a2w@mail.gmail.com>
 <20171106183237.64b3hj25hbfw7v4l@dhcp22.suse.cz>
 <c6ab988b-f95f-3881-a35c-7727292fd44a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c6ab988b-f95f-3881-a35c-7727292fd44a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, linux-mm@kvack.org

On Tue 07-11-17 09:20:47, Vlastimil Babka wrote:
> On 11/06/2017 07:32 PM, Michal Hocko wrote:
> > On Mon 06-11-17 20:13:36, Maxim Levitsky wrote:
> >> Yes, I tested git head from mainline and few kernels from ubuntu repos
> >> since I was lazy to compile them too.
> > 
> > OK, so this hasn't worked realiably as I've suspected.
> > 
> >> Do you have an idea what can I do about this issue? Do you think its
> >> feasable to fix this?
> > 
> > Well, I think that giga pages need quite some love to be usable
> > reliably. The current implementation is more towards "make it work if
> > there is enough unused memory".
> > 
> >> And if not using moveable zone, how would it even be possible to have
> >> guaranreed allocation of 1g pages
> > 
> > Having a guaranteed giga pages is something the kernel is not yet ready
> > to offer.  Abusing zone movable might look like the right direction
> > but that is not really the case until we make sure those pages are
> > migratable.
> 
> Migratable where? It's very unlikely you will be able to migrate them
> away from a movable zone to a normal zone. So the use case is migration
> between hotplugable nodes, so one of them can be removed?

Yes, basically what we do for hugetlb pages normally. Smaller hugetlb
pages are more likely to succeed, though.

> That would
> probably be an improvement (even if you could not guarantee to offline
> all hotplugable nodes at once without admin intervention removing those
> giga pages). Right now the only scenario where giga pages are compatible
> with hot-remove is to put them on the already-limited non-removable node
> 0...

Yes, we will never be perfect, but I can see why people want to allocate
from movable zones so we definitely should work on making giga pages
more robust. The current state makes cry...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
