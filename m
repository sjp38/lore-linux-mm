Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0FDE682F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 15:04:54 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id jw2so65284736igc.1
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:04:54 -0800 (PST)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id in8si8519613igb.32.2015.12.22.12.04.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 12:04:53 -0800 (PST)
Message-ID: <1450814672.10450.83.camel@hpe.com>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
From: Toshi Kani <toshi.kani@hpe.com>
Date: Tue, 22 Dec 2015 13:04:32 -0700
In-Reply-To: <20151222113422.GE3728@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
	 <20151216122642.GE29775@pd.tnic> <1450280642.29051.76.camel@hpe.com>
	 <20151216154916.GF29775@pd.tnic> <1450283759.20148.11.camel@hpe.com>
	 <20151216174523.GH29775@pd.tnic>
	 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
	 <20151216181712.GJ29775@pd.tnic> <1450302758.20148.75.camel@hpe.com>
	 <20151222113422.GE3728@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Tue, 2015-12-22 at 12:34 +0100, Borislav Petkov wrote:
> On Wed, Dec 16, 2015 at 02:52:38PM -0700, Toshi Kani wrote:
> > This scheme may have a problem, though.  For instance, when someone 
> > writes a loadable module that searches for "foo", but the "foo" entry 
> > may be initialized in a distro kernel/driver that cannot be modified. 
> >  Since this search is only necessary to obtain a range initialized by 
> > other module, this scenario is likely to happen.  We no longer have 
> > ability to search for a new entry unless we modify the code that
> > initializes the entry first.
> 
> Since when do we pay attention to out-of-tree modules which cannot be
> changed?

The above example referred the case with distros, not with the upstream. 
 That is, one writes a new loadable module and makes it available in the
upstream.  Then s/he makes it work on a distro used by the customers, but
may or may not be able to change the distro kernel/drivers used by the
customers.

> Regardless, we don't necessarily need to change the callers - we could
> add new ones of the form walk_iomem_resource_by_type() or whatever its
> name is going to be which uses the ->type attribute of the resource and
> phase out the old ones slowly. New code will call the better interfaces,
> we should probably even add a checkpatch rule to check for that.

I agree that we can add new interfaces with the type check.  This 'type'
may need some clarification since it is an assigned type, which is
different from I/O resource type.  That is, "System RAM" is an I/O resource
type (i.e. IORESOURCE_SYSTEM_RAM), but "Crash kernel" is an assigned type
to a particular range of System RAM.  A range may be associated with
multiple names, so as multiple assigned types.  For lack of a better idea,
I may call it 'assign_type'.  I am open for a better name.

> > Even if we avoid strcmp() with @name in the kernel, user applications
> > will continue to use @name since that is the only type available in
> > /proc/iomem.  For instance, kexec has its own search function with a
> > string name.
> 
> See above.
> 
> > When a new commonly-used search name comes up, we can define it as a 
> > new extended I/O resource type similar to IORESOURCE_SYSTEM_RAM.  For 
> > the current remaining cases, i.e. crash, kexec, and einj, they have no
> > impact to performance.  Leaving these special cases aside will keep the
> > ability to search for any entry without changing the kernel, and save 
> > some memory space from adding the new 'type'.
> 
> Again, we can leave the old interfaces at peace but going forward, we
> should make the searching for resources saner and stop using silly
> strings.

OK, I will try to convert the existing callers with the new interfaces.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
