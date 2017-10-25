Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CC8BE6B0253
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 13:54:34 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r202so722716wmd.17
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 10:54:34 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e12si1994701edk.459.2017.10.25.10.54.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Oct 2017 10:54:32 -0700 (PDT)
Date: Wed, 25 Oct 2017 13:54:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Detecting page cache trashing state
Message-ID: <20171025175424.GA14039@cmpxchg.org>
References: <150543458765.3781.10192373650821598320@takondra-t460s>
 <20170915143619.2ifgex2jxck2xt5u@dhcp22.suse.cz>
 <150549651001.4512.15084374619358055097@takondra-t460s>
 <20170918163434.GA11236@cmpxchg.org>
 <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0F1p//8PRICkK4MW"
Content-Disposition: inline
In-Reply-To: <acbf4417-4ded-fa03-7b8d-34dc0803027c@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco)" <rruslich@cisco.com>
Cc: Taras Kondratiuk <takondra@cisco.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, xe-linux-external@cisco.com, linux-kernel@vger.kernel.org


--0F1p//8PRICkK4MW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Ruslan,

sorry about the delayed response, I missed the new activity in this
older thread.

On Thu, Sep 28, 2017 at 06:49:07PM +0300, Ruslan Ruslichenko -X (rruslich - GLOBALLOGIC INC at Cisco) wrote:
> Hi Johannes,
> 
> Hopefully I was able to rebase the patch on top v4.9.26 (latest supported
> version by us right now)
> and test a bit.
> The overall idea definitely looks promising, although I have one question on
> usage.
> Will it be able to account the time which processes spend on handling major
> page faults
> (including fs and iowait time) of refaulting page?

That's the main thing it should measure! :)

The lock_page() and wait_on_page_locked() calls are where iowaits
happen on a cache miss. If those are refaults, they'll be counted.

> As we have one big application which code space occupies big amount of place
> in page cache,
> when the system under heavy memory usage will reclaim some of it, the
> application will
> start constantly thrashing. Since it code is placed on squashfs it spends
> whole CPU time
> decompressing the pages and seem memdelay counters are not detecting this
> situation.
> Here are some counters to indicate this:
> 
> 19:02:44        CPU     %user     %nice   %system   %iowait %steal     %idle
> 19:02:45        all      0.00      0.00    100.00      0.00 0.00      0.00
> 
> 19:02:44     pgpgin/s pgpgout/s   fault/s  majflt/s  pgfree/s pgscank/s
> pgscand/s pgsteal/s    %vmeff
> 19:02:45     15284.00      0.00    428.00    352.00  19990.00 0.00      0.00
> 15802.00      0.00
> 
> And as nobody actively allocating memory anymore looks like memdelay
> counters are not
> actively incremented:
> 
> [:~]$ cat /proc/memdelay
> 268035776
> 6.13 5.43 3.58
> 1.90 1.89 1.26

How does it correlate with /proc/vmstat::workingset_activate during
that time? It only counts thrashing time of refaults it can actively
detect.

Btw, how many CPUs does this system have? There is a bug in this
version on how idle time is aggregated across multiple CPUs. The error
compounds with the number of CPUs in the system.

I'm attaching 3 bugfixes that go on top of what you have. There might
be some conflicts, but they should be minor variable naming issues.


--0F1p//8PRICkK4MW
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-memdelay-fix-task-flags-race-condition.patch"


--0F1p//8PRICkK4MW--
