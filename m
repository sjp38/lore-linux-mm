Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF0A6B0275
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 19:52:47 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id d25-v6so31199583qtp.10
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 16:52:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id r1-v6si16165880qkd.113.2018.07.12.16.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 16:52:46 -0700 (PDT)
Date: Fri, 13 Jul 2018 07:52:40 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180712235240.GH2070@MiWiFi-R3L-srv>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
 <20180711104944.GG1969@MiWiFi-R3L-srv>
 <20180711124008.GF2070@MiWiFi-R3L-srv>
 <72721138-ba6a-32c9-3489-f2060f40a4c9@cn.fujitsu.com>
 <20180712060115.GD6742@localhost.localdomain>
 <20180712123228.GK32648@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712123228.GK32648@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>, Dou Liyang <douly.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, vbabka@suse.cz, mgorman@techsingularity.net

Hi Michal,

On 07/12/18 at 02:32pm, Michal Hocko wrote:
> On Thu 12-07-18 14:01:15, Chao Fan wrote:
> > On Thu, Jul 12, 2018 at 01:49:49PM +0800, Dou Liyang wrote:
> > >Hi Baoquan,
> > >
> > >At 07/11/2018 08:40 PM, Baoquan He wrote:
> > >> Please try this v3 patch:
> > >> >>From 9850d3de9c02e570dc7572069a9749a8add4c4c7 Mon Sep 17 00:00:00 2001
> > >> From: Baoquan He <bhe@redhat.com>
> > >> Date: Wed, 11 Jul 2018 20:31:51 +0800
> > >> Subject: [PATCH v3] mm, page_alloc: find movable zone after kernel text
> > >> 
> > >> In find_zone_movable_pfns_for_nodes(), when try to find the starting
> > >> PFN movable zone begins in each node, kernel text position is not
> > >> considered. KASLR may put kernel after which movable zone begins.
> > >> 
> > >> Fix it by finding movable zone after kernel text on that node.
> > >> 
> > >> Signed-off-by: Baoquan He <bhe@redhat.com>
> > >
> > >
> > >You fix this in the _zone_init side_. This may make the 'kernelcore=' or
> > >'movablecore=' failed if the KASLR puts the kernel back the tail of the
> > >last node, or more.
> > 
> > I think it may not fail.
> > There is a 'restart' to do another pass.
> > 
> > >
> > >Due to we have fix the mirror memory in KASLR side, and Chao is trying
> > >to fix the 'movable_node' in KASLR side. Have you had a chance to fix
> > >this in the KASLR side.
> > >
> > 
> > I think it's better to fix here, but not KASLR side.
> > Cause much more code will be change if doing it in KASLR side.
> > Since we didn't parse 'kernelcore' in compressed code, and you can see
> > the distribution of ZONE_MOVABLE need so much code, so we do not need
> > to do so much job in KASLR side. But here, several lines will be OK.
> 
> I am not able to find the beginning of the email thread right now. Could
> you summarize what is the actual problem please?

The bug is found on x86 now. 

When added "kernelcore=" or "movablecore=" into kernel command line,
kernel memory is spread evenly among nodes. However, this is right when
KASLR is not enabled, then kernel will be at 16M of place in x86 arch.
If KASLR enabled, it could be put any place from 16M to 64T randomly.
 
Consider a scenario, we have 10 nodes, and each node has 20G memory, and
we specify "kernelcore=50%", means each node will take 10G for
kernelcore, 10G for movable area. But this doesn't take kernel position
into consideration. E.g if kernel is put at 15G of 2nd node, namely
node1. Then we think on node1 there's 10G for kernelcore, 10G for
movable, in fact there's only 5G available for movable, just after
kernel.

I made a v4 patch which possibly can fix it.
