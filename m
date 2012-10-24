Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A994D6B0062
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 01:54:01 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so1071368pbb.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 22:54:00 -0700 (PDT)
Date: Tue, 23 Oct 2012 22:53:58 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Bug 49361] New: configuring TRANSPARENT_HUGEPAGE_ALWAYS can
 make system unresponsive and reboot
In-Reply-To: <20121023123613.1bcdf3ab.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1210232242590.22652@chino.kir.corp.google.com>
References: <bug-49361-27@https.bugzilla.kernel.org/> <20121023123613.1bcdf3ab.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: marc@offline.be
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Tue, 23 Oct 2012, Andrew Morton wrote:

> >  I run a bleeding edge gentoo with 2 6-core AMD CPUs. I daily updated
> > 3 gentoo systems on this computer all using -j13. Until recently, I
> > never experienced issues, CPUs may all go neer 100%, no problem.
> > 
> >  Now, when building icedtea-7, for example, regardless of -j13 or -j1,
> > about 10 javac instances run threaded (either spreaded on multiple or
> > one core) and go to about 1000% CPU together.
> > 
> >  Nothing else can be started. This can take 24 hours, no improvement.
> > 
> >  Only one way to recover: kill -9 javac.
> > 
> >  One time kernel rebooted, I could not find any relevant kernel logs
> > before reboot.
> > 
> > 
> >  I hd noticed khugepaged on top in top (just below 1000% CPU javac)
> > which made me look at HUGEPAGE settings.
> > 
> >  FWIW, an strace on javac PID showed it doing nothing in futex
> > 
> >  As said, MADVISE fixes issue.
> > 

We'll need to collect some information before we can figure out what the 
problem is with 3.5.2.

First, let's take a look at khugepaged.  By default, it's supposed to wake 
up rarely (10s at minimum) and only scan 4K pages before going back to 
sleep.  Having a consistent and very high cpu usage suggests the settings 
aren't the default.  Can you do

	cat /sys/kernel/mm/transparent_hugepage/khugepaged/{alloc,scan}_sleep_millisecs

The defaults should be 60000 and 10000, respectively.  Then can you do

	cat /sys/kernel/mm/transparent_hugepage/khugepaged/pages_to_scan

which should be 4096.  If those are your settings, then it seems like 
khugepaged in 3.5.2 is going crazy and we'll need to look into that.  Try 
collecting

	grep -e "thp|compact" /proc/vmstat

and

	cat /proc/$(pidof khugepaged)/stack

appended to a logfile at regular intervals after your start the build with 
transparent hugepages enabled always.  After the machine becomes 
unresponsive and reboots, post that log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
