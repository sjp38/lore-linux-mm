Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 74FD56B0035
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 16:52:04 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id y13so1202738pdi.23
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 13:52:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h5si2344178pdm.8.2014.08.29.13.52.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 13:52:03 -0700 (PDT)
Date: Fri, 29 Aug 2014 13:52:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] x86: Speed up ioremap operations
Message-Id: <20140829135200.636dec4a64e2668c2072d787@linux-foundation.org>
In-Reply-To: <5400E62F.8000405@sgi.com>
References: <20140829195328.511550688@asylum.americas.sgi.com>
	<20140829131602.72c422ebd2fd3fba426379e8@linux-foundation.org>
	<5400E62F.8000405@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>, Cliff Wickman <cpw@sgi.com>, Russ Anderson <rja@sgi.com>, Greg KH <greg@kroah.com>

On Fri, 29 Aug 2014 13:44:31 -0700 Mike Travis <travis@sgi.com> wrote:

> 
> 
> On 8/29/2014 1:16 PM, Andrew Morton wrote:
> > On Fri, 29 Aug 2014 14:53:28 -0500 Mike Travis <travis@sgi.com> wrote:
> > 
> >>
> >> We have a large university system in the UK that is experiencing
> >> very long delays modprobing the driver for a specific I/O device.
> >> The delay is from 8-10 minutes per device and there are 31 devices
> >> in the system.  This 4 to 5 hour delay in starting up those I/O
> >> devices is very much a burden on the customer.
> >>
> >> There are two causes for requiring a restart/reload of the drivers.
> >> First is periodic preventive maintenance (PM) and the second is if
> >> any of the devices experience a fatal error.  Both of these trigger
> >> this excessively long delay in bringing the system back up to full
> >> capability.
> >>
> >> The problem was tracked down to a very slow IOREMAP operation and
> >> the excessively long ioresource lookup to insure that the user is
> >> not attempting to ioremap RAM.  These patches provide a speed up
> >> to that function.
> >>
> > 
> > Really would prefer to have some quantitative testing results in here,
> > as that is the entire point of the patchset.  And it leaves the reader
> > wondering "how much of this severe problem remains?".
> 
> Okay, I have some results from testing.  The modprobe time appears to
> be affected quite a bit by previous activity on the ioresource list,
> which I suspect is due to cache preloading.  While the overall
> improvement is impacted by other overhead of starting the devices,
> this drastically improves the modprobe time.
> 
> Also our system is considerably smaller so the percentages gained
> will not be the same.  Best case improvement with the modprobe
> on our 20 device smallish system was from 'real    5m51.913s' to
> 'real    0m18.275s'.

Thanks, I slurped that into the changelog.

> > Also, the -stable backport is a big ask, isn't it?  It's arguably
> > notabug and the affected number of machines is small.
> > 
> 
> Ingo had suggested this.  We are definitely pushing it to our distro
> suppliers for our customers.  Whether it's a big deal for smaller
> systems is up in the air.  Note that the customer system has 31 devices
> on an SSI that includes a large number of other IB and SAS devices
> as well as a number of nodes which all which have discontiguous memory
> segments.  I'm envisioning an ioresource list that numbers at least
> several hundred entries.  While that's somewhat indicative of typical
> UV systems it is generally not that common otherwise.
> 
> So I guess the -stable is merely a suggestion, not a request.

Cc Greg for his thoughts!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
