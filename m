Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 95E396B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 13:20:02 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id b85so189652qkc.12
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:20:02 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g41si2127660qtc.18.2017.11.17.10.20.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 10:20:01 -0800 (PST)
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id vAHIJwKU019541
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:19:59 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id vAHIJws9030119
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:19:58 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id vAHIJwow006478
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 18:19:58 GMT
Received: by mail-ot0-f175.google.com with SMTP id s4so2751424ote.4
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 10:19:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz> <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz> <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
 <20171115145716.w34jaez5ljb3fssn@dhcp22.suse.cz> <06a33f82-7f83-7721-50ec-87bf1370c3d4@gmail.com>
 <20171116085433.qmz4w3y3ra42j2ih@dhcp22.suse.cz> <20171116100633.moui6zu33ctzpjsf@techsingularity.net>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 17 Nov 2017 13:19:56 -0500
Message-ID: <CAOAebxt8ZjfCXND=1=UJQETbjVUGPJVcqKFuwGsrwyM2Mq1dhQ@mail.gmail.com>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Michal Hocko <mhocko@kernel.org>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, koki.sanagi@us.fujitsu.com, Steve Sistare <steven.sistare@oracle.com>

On Thu, Nov 16, 2017 at 5:06 AM, Mel Gorman <mgorman@techsingularity.net> wrote:
> 4. Put a check into the page allocator slowpath that triggers serialised
>    init if the system is booting and an allocation is about to fail. It
>    would be such a cold path that it would never be noticable although it
>    would leave dead code in the kernel image once boot had completed

Hi Mel,

The forth approach is the best as it is seamless for admins and
engineers, it will also work on any system configuration with any
parameters without any special involvement.

This approach will also address the following problem:
reset_deferred_meminit() has some assumptions about how much memory we
will need beforehand may break periodically as kernel requirements
change. For, instance, I recently reduced amount of memory system hash
tables take on large machines [1], so the comment in that function is
already outdated:
        /*
         * Initialise at least 2G of a node but also take into account that
         * two large system hashes that can take up 1GB for 0.25TB/node.
         */

With this approach we could always init a very small amount of struct
pages, and allow the rest to be initialized on demand as boot requires
until deferred struct pages are initialized. Since, having deferred
pages feature assumes that the machine is large, there is no drawback
of having some extra byte of dead code, especially that all the checks
can be permanently switched of via static branches once deferred init
is complete.

The second benefit that this approach may bring is the following: it
may enable to add a new feature which would initialize struct pages on
demand later, when needed by applications. This feature would be
configurable or enabled via kernel parameter (not sure which is
better).

if (allocation is failing)
  if (uninit struct pages available)
    init enought to finish alloc

Again, once all pages are initialized, the checks will be turned off
via static branching, so I think the code can be shared.

Here is the rationale for this feature:

Each physical machine may run a very large number of linux containers.
Steve Sistare (CCed), recently studied how much memory each instance
of clear container is taking, and it turns out to be about 125 MB,
when containers are booted with 2G of memory and 1 CPU. Out of those
125 MB, 32 MB is consumed by struct page array as we use 64-bytes per
page. Admins tend to be protective in the amount of memory that is
configured, therefore they may over-commit the amount of memory that
is actually required by the container. So, by allowing struct pages to
be initialized only on demand, we can save around 25% of the memory
that is consumed by fresh instance of container. Now, that struct
pages are not zeroed during boot [2], and if we will implement the
forth option, we can get closer to implementing a complete on demand
struct page initialization.

I can volunteer to work on these projects.

[1] https://patchwork.kernel.org/patch/9599545/
[2] https://lwn.net/Articles/734374

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
