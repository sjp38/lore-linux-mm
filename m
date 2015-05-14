Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A56936B006C
	for <linux-mm@kvack.org>; Thu, 14 May 2015 04:08:15 -0400 (EDT)
Received: by wibt6 with SMTP id t6so5607966wib.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 01:08:15 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy10si37205961wjc.134.2015.05.14.01.08.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 01:08:14 -0700 (PDT)
Date: Thu, 14 May 2015 10:08:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 0/3] Allow user to request memory to be locked on page
 fault
Message-ID: <20150514080812.GC6433@dhcp22.suse.cz>
References: <1431113626-19153-1-git-send-email-emunson@akamai.com>
 <20150508124203.6679b1d35ad9555425003929@linux-foundation.org>
 <20150511180631.GA1227@akamai.com>
 <20150513150036.GG1227@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150513150036.GG1227@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Wed 13-05-15 11:00:36, Eric B Munson wrote:
> On Mon, 11 May 2015, Eric B Munson wrote:
> 
> > On Fri, 08 May 2015, Andrew Morton wrote:
> > 
> > > On Fri,  8 May 2015 15:33:43 -0400 Eric B Munson <emunson@akamai.com> wrote:
> > > 
> > > > mlock() allows a user to control page out of program memory, but this
> > > > comes at the cost of faulting in the entire mapping when it is
> > > > allocated.  For large mappings where the entire area is not necessary
> > > > this is not ideal.
> > > > 
> > > > This series introduces new flags for mmap() and mlockall() that allow a
> > > > user to specify that the covered are should not be paged out, but only
> > > > after the memory has been used the first time.
> > > 
> > > Please tell us much much more about the value of these changes: the use
> > > cases, the behavioural improvements and performance results which the
> > > patchset brings to those use cases, etc.
> > > 
> > 
> > To illustrate the proposed use case I wrote a quick program that mmaps
> > a 5GB file which is filled with random data and accesses 150,000 pages
> > from that mapping.  Setup and processing were timed separately to
> > illustrate the differences between the three tested approaches.  the
> > setup portion is simply the call to mmap, the processing is the
> > accessing of the various locations in  that mapping.  The following
> > values are in milliseconds and are the averages of 20 runs each with a
> > call to echo 3 > /proc/sys/vm/drop_caches between each run.
> > 
> > The first mapping was made with MAP_PRIVATE | MAP_LOCKED as a baseline:
> > Startup average:    9476.506
> > Processing average: 3.573
> > 
> > The second mapping was simply MAP_PRIVATE but each page was passed to
> > mlock() before being read:
> > Startup average:    0.051
> > Processing average: 721.859
> > 
> > The final mapping was MAP_PRIVATE | MAP_LOCKONFAULT:
> > Startup average:    0.084
> > Processing average: 42.125
> > 
> 
> Michal's suggestion of changing protections and locking in a signal
> handler was better than the locking as needed, but still significantly
> more work required than the LOCKONFAULT case.
> 
> Startup average:    0.047
> Processing average: 86.431

Have you played with batching? Has it helped? Anyway it is to be
expected that the overhead will be higher than a single mmap call. The
question is whether you can live with it because adding a new semantic
to mlock sounds trickier and MAP_LOCKED is tricky enough already...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
