Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id EB9C96B0037
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 18:55:08 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id hw13so2108715qab.20
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 15:55:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si6743928qai.57.2014.06.25.15.55.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jun 2014 15:55:08 -0700 (PDT)
Date: Wed, 25 Jun 2014 18:54:52 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
 interfaces
Message-ID: <20140625225451.GB1534@t510.redhat.com>
References: <4b46c5b21263c446923caf3da3f0dca6febc7b55.1403709665.git.aquini@redhat.com>
 <6B2BA408B38BA1478B473C31C3D2074E341D585464@SV-EXCHANGE1.Corp.FC.LOCAL>
 <20140625201603.GA1534@t510.redhat.com>
 <6B2BA408B38BA1478B473C31C3D2074E341D585503@SV-EXCHANGE1.Corp.FC.LOCAL>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6B2BA408B38BA1478B473C31C3D2074E341D585503@SV-EXCHANGE1.Corp.FC.LOCAL>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Motohiro Kosaki <Motohiro.Kosaki@us.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Motohiro Kosaki JP <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 25, 2014 at 01:27:53PM -0700, Motohiro Kosaki wrote:
> 
> 
> > -----Original Message-----
> > From: Rafael Aquini [mailto:aquini@redhat.com]
> > Sent: Wednesday, June 25, 2014 4:16 PM
> > To: Motohiro Kosaki
> > Cc: linux-mm@kvack.org; Andrew Morton; Rik van Riel; Mel Gorman; Johannes Weiner; Motohiro Kosaki JP; linux-
> > kernel@vger.kernel.org
> > Subject: Re: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo() interfaces
> > 
> > On Wed, Jun 25, 2014 at 12:41:17PM -0700, Motohiro Kosaki wrote:
> > >
> > >
> > > > -----Original Message-----
> > > > From: Rafael Aquini [mailto:aquini@redhat.com]
> > > > Sent: Wednesday, June 25, 2014 2:40 PM
> > > > To: linux-mm@kvack.org
> > > > Cc: Andrew Morton; Rik van Riel; Mel Gorman; Johannes Weiner;
> > > > Motohiro Kosaki JP; linux-kernel@vger.kernel.org
> > > > Subject: [PATCH] mm: export NR_SHMEM via sysinfo(2) / si_meminfo()
> > > > interfaces
> > > >
> > > > This patch leverages the addition of explicit accounting for pages
> > > > used by shmem/tmpfs -- "4b02108 mm: oom analysis: add shmem vmstat"
> > > > -- in order to make the users of sysinfo(2) and si_meminfo*() friends aware of that vmstat entry consistently across the interfaces.
> > >
> > > Why?
> > 
> > Because we do not report consistently across the interfaces we declare exporting that data. Check sysinfo(2) manpage, for instance:
> > [...]
> >            struct sysinfo {
> >                long uptime;             /* Seconds since boot */
> >                unsigned long loads[3];  /* 1, 5, and 15 minute load averages */
> >                unsigned long totalram;  /* Total usable main memory size */
> >                unsigned long freeram;   /* Available memory size */
> >                unsigned long sharedram; /* Amount of shared memory */ <<<<< [...]
> > 
> > userspace tools resorting to sysinfo() syscall will get a hardcoded 0 for shared memory which is reported differently from
> > /proc/meminfo.
> > 
> > Also, si_meminfo() & si_meminfo_node() are utilized within the kernel to gather statistics for /proc/meminfo & friends, and so we
> > can leverage collecting sharedmem from those calls as well, just as we do for totalram, freeram & bufferram.
> 
> But "Amount of shared memory"  didn't mean amout of shmem. It actually meant amout of page of page-count>=2.
> Again, there is a possibility to change the semantics. But I don't have enough userland knowledge to do. Please investigate
> and explain why your change don't break any userland. 

I agree that reporting the amount of shared pages in that historically fashion 
might not be interesting for userspace tools resorting to sysinfo(2),
nowadays.

OTOH, our documentation implies we do return shared memory there, and FWIW,
considering the other places we do export the "shared memory" concept to 
userspace nowadays, we are suggesting it's the amount of tmpfs/shmem, and not the
amount of shared mapped pages it historiacally represented once. What is really
confusing is having a field that supposedely/expectedely would return the amount
of shmem to userspace queries, but instead returns a hard-coded zero (0).

I could easily find out that there were some user complaint/confusion on this 
semantic inconsistency in the past, as in:
https://groups.google.com/forum/#!topic/comp.os.linux.development.system/ogWVn6XdvGA

or in:
http://marc.info/?l=net-snmp-cvs&m=132148788500667

which suggests users seem to always have understood it as being shmem/tmpfs
usage, as the /proc/meminfo field "MemShared" was tied direclty to
sysinfo.sharedram. Historically we reported shared memory that way, and
when it wasn't accurately meaning that anymore a 0 was hardcoded there to
potentially not break compatibility with older tools (older than 2.4).
In 2.6 we got rid of meminfo's "MemShared" until 2009, when you sort of
re-introduced it re-branded as Shmem. IMO, we should leverage what we 
have in kernel now and take this change to make the exposed data consistent 
across the interfaces that export it today -- sysinfo(2) & /proc/meminfo.

This is not a hard requirement, though, but rather a simple maintenance
nitpick from code review. 

Regards,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
