Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 42CC16B000A
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 08:06:45 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p7-v6so4562770eds.19
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 05:06:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6-v6si9333934edm.391.2018.07.16.05.06.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 05:06:44 -0700 (PDT)
Date: Mon, 16 Jul 2018 14:06:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Instability in current -git tree
Message-ID: <20180716120642.GN17280@dhcp22.suse.cz>
References: <20180713164804.fc2c27ccbac4c02ca2c8b984@linux-foundation.org>
 <CA+55aFxAZr8PHo-raTihr8TKK_D-fVL+k6_tw_UyDLychowFNw@mail.gmail.com>
 <20180713165812.ec391548ffeead96725d044c@linux-foundation.org>
 <9b93d48c-b997-01f7-2fd6-6e35301ef263@oracle.com>
 <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com>
 <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
 <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com>
 <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
 <CAGM2reb2Zk6t=QJtJZPRGwovKKR9bdm+fzgmA_7CDVfDTjSgKA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reb2Zk6t=QJtJZPRGwovKKR9bdm+fzgmA_7CDVfDTjSgKA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Theodore Tso <tytso@google.com>, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

On Sat 14-07-18 09:39:29, Pavel Tatashin wrote:
[...]
> From 95259841ef79cc17c734a994affa3714479753e3 Mon Sep 17 00:00:00 2001
> From: Pavel Tatashin <pasha.tatashin@oracle.com>
> Date: Sat, 14 Jul 2018 09:15:07 -0400
> Subject: [PATCH] mm: zero unavailable pages before memmap init
> 
> We must zero struct pages for memory that is not backed by physical memory,
> or kernel does not have access to.
> 
> Recently, there was a change which zeroed all memmap for all holes in e820.
> Unfortunately, it introduced a bug that is discussed here:
> 
> https://www.spinics.net/lists/linux-mm/msg156764.html
> 
> Linus, also saw this bug on his machine, and confirmed that pulling
> commit 124049decbb1 ("x86/e820: put !E820_TYPE_RAM regions into memblock.reserved")
> fixes the issue.
> 
> The problem is that we incorrectly zero some struct pages after they were
> setup.

I am sorry but I simply do not see it. zero_resv_unavail should be
touching only reserved memory ranges and those are not initialized
anywhere. So who has reused them and put them to normal available
memory to be initialized by free_area_init_node[s]?

The patch itself should be safe because reserved and available memory
ranges should be disjoint so the ordering shouldn't matter. The fact
that it matters is the crux thing to understand and document. So the
change looks good to me but I do not understand _why_ it makes any
difference. There must be somebody to put (memblock) reserved memory
available to the page allocator behind our backs.
-- 
Michal Hocko
SUSE Labs
