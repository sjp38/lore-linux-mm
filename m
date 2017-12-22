Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 424246B0038
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 07:31:07 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v184so8072621wmf.1
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:31:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r134si2839269wmd.183.2017.12.22.04.31.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 04:31:05 -0800 (PST)
Date: Fri, 22 Dec 2017 13:31:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/5] mm: enlarge NUMA counters threshold size
Message-ID: <20171222123103.GP4831@dhcp22.suse.cz>
References: <1513665566-4465-1-git-send-email-kemi.wang@intel.com>
 <1513665566-4465-4-git-send-email-kemi.wang@intel.com>
 <20171219124045.GO2787@dhcp22.suse.cz>
 <439918f7-e8a3-c007-496c-99535cbc4582@intel.com>
 <20171220101229.GJ4831@dhcp22.suse.cz>
 <268b1b6e-ff7a-8f1a-f97c-f94e14591975@intel.com>
 <20171221081706.GA4831@dhcp22.suse.cz>
 <1fb66dfd-b64c-f705-ea27-a9f2e11729a4@intel.com>
 <20171221085952.GB4831@dhcp22.suse.cz>
 <10bf5ed1-77f0-281b-dde5-282879e87c39@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <10bf5ed1-77f0-281b-dde5-282879e87c39@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Thu 21-12-17 18:31:19, kemi wrote:
> 
> 
> On 2017a1'12ae??21ae?JPY 16:59, Michal Hocko wrote:
> > On Thu 21-12-17 16:23:23, kemi wrote:
> >>
> >>
> >> On 2017a1'12ae??21ae?JPY 16:17, Michal Hocko wrote:
> > [...]
> >>> Can you see any difference with a more generic workload?
> >>>
> >>
> >> I didn't see obvious improvement for will-it-scale.page_fault1
> >> Two reasons for that:
> >> 1) too long code path
> >> 2) server zone lock and lru lock contention (access to buddy system frequently) 
> > 
> > OK. So does the patch helps for anything other than a microbenchmark?
> > 
> >>>> Some thinking about that:
> >>>> a) the overhead due to cache bouncing caused by NUMA counter update in fast path 
> >>>> severely increase with more and more CPUs cores
> >>>
> >>> What is an effect on a smaller system with fewer CPUs?
> >>>
> >>
> >> Several CPU cycles can be saved using single thread for that.
> >>
> >>>> b) AFAIK, the typical usage scenario (similar at least)for which this optimization can 
> >>>> benefit is 10/40G NIC used in high-speed data center network of cloud service providers.
> >>>
> >>> I would expect those would disable the numa accounting altogether.
> >>>
> >>
> >> Yes, but it is still worthy to do some optimization, isn't?
> > 
> > Ohh, I am not opposing optimizations but you should make sure that they
> > are worth the additional code and special casing. As I've said I am not
> > convinced special casing numa counters is good. You can play with the
> > threshold scaling for larger CPU count but let's make sure that the
> > benefit is really measurable for normal workloads. Special ones will
> > disable the numa accounting anyway.
> > 
> 
> I understood. Could you give me some suggestion for those normal workloads, Thanks.
> I will have a try and post the data ASAP. 

Well, to be honest, I am really confused what is your objective for
these optimizations then. I hope we have agreed that workloads which
really need to squeeze every single CPU cycle in the allocation path
will simply disable the whole numa stat thing. I haven't yet heard about
any use case which would really required numa stats and suffer from the
numa stats overhead.

I can see some arguments for a better threshold scaling but that
requires to check wider range of tests to show there are no unintended
changes. I am not really confident you understand that when you are
asking for "those normal workloads".

So please, try to step back, rethink who you are optimizing for and act
accordingly. If I were you I would repost the first patch which only
integrates numa stats because that removes a lot of pointless code and
that is a win of its own.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
