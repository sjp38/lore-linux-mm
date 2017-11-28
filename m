Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 411876B0253
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 16:56:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id f132so484435wmf.6
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 13:56:58 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b25si110865wrc.383.2017.11.28.13.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Nov 2017 13:56:57 -0800 (PST)
Date: Tue, 28 Nov 2017 13:56:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Message-Id: <20171128135653.608f4350f4245a633823f5e9@linux-foundation.org>
In-Reply-To: <87o9nmjlfv.fsf@linux.intel.com>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
	<9b4d5612-24eb-4bea-7164-49e42dc76f30@suse.cz>
	<87o9nmjlfv.fsf@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Kemi Wang <kemi.wang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, Andi Kleen <andi.kleen@intel.com>, Tim Chen <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Aubrey Li <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Tue, 28 Nov 2017 10:40:52 -0800 Andi Kleen <ak@linux.intel.com> wrote:

> Vlastimil Babka <vbabka@suse.cz> writes:
> >
> > I'm worried about the "for_each_possible..." approach here and elsewhere
> > in the patch as it can be rather excessive compared to the online number
> > of cpus (we've seen BIOSes report large numbers of possible CPU's). IIRC
> 
> Even if they report a few hundred extra reading some more shared cache lines
> is very cheap. The prefetcher usually quickly figures out such a pattern
> and reads it all in parallel.
> 
> I doubt it will be noticeable, especially not in a slow path
> like reading something from proc/sys.

We say that, then a few years it comes back and bites us on our
trailing edges.

> > the general approach with vmstat is to query just online cpu's / nodes,
> > and if they go offline, transfer their accumulated stats to some other
> > "victim"?
> 
> That's very complicated, and unlikely to be worth it.

for_each_online_cpu() and a few-line hotplug handler?  I'd like to see
an implementation before deciding that it's too complex...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
