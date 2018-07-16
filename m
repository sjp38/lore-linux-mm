Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CFC8C6B0008
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:12:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d30-v6so10022895edd.0
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:12:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3-v6si398737edc.284.2018.07.16.07.12.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 07:12:21 -0700 (PDT)
Date: Mon, 16 Jul 2018 16:12:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Instability in current -git tree
Message-ID: <20180716141218.GR17280@dhcp22.suse.cz>
References: <CA+55aFxFw2-1BD2UBf_QJ2=faQES_8q==yUjwj4mGJ6Ub4uX7w@mail.gmail.com>
 <5edf2d71-f548-98f9-16dd-b7fed29f4869@oracle.com>
 <CA+55aFwPAwczHS3XKkEnjY02PaDf2mWrcqx_hket4Ce3nScsSg@mail.gmail.com>
 <CAGM2rebeo3UUo2bL6kXCMGhuM36wjF5CfvqGG_3rpCfBs5S2wA@mail.gmail.com>
 <CA+55aFxetyCqX2EzFBDdHtriwt6UDYcm0chHGQUdPX20qNHb4Q@mail.gmail.com>
 <CAGM2reb2Zk6t=QJtJZPRGwovKKR9bdm+fzgmA_7CDVfDTjSgKA@mail.gmail.com>
 <20180716120642.GN17280@dhcp22.suse.cz>
 <fc5cfff3-0000-41da-e4d9-3e91ef9d0792@oracle.com>
 <20180716122918.GO17280@dhcp22.suse.cz>
 <CAGM2reaM1sCCj8QjkfSrKhTXrj=__DXAFgQkBV2ZN5chKgjzTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reaM1sCCj8QjkfSrKhTXrj=__DXAFgQkBV2ZN5chKgjzTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, tglx@linutronix.de, willy@infradead.org, mingo@redhat.com, axboe@kernel.dk, gregkh@linuxfoundation.org, davem@davemloft.net, viro@zeniv.linux.org.uk, Dave Airlie <airlied@gmail.com>, Tejun Heo <tj@kernel.org>, Theodore Tso <tytso@google.com>, snitzer@redhat.com, Linux Memory Management List <linux-mm@kvack.org>, neelx@redhat.com, mgorman@techsingularity.net

On Mon 16-07-18 09:26:41, Pavel Tatashin wrote:
> > Maybe a stupid question, but I do not see it from the code (this init
> > code is just to complex to keep it cached in head so I always have to
> > study the code again and again, sigh). So what exactly prevents
> > memmap_init_zone to stumble over reserved regions? We do play some ugly
> > games to find a first !reserved pfn in the node but I do not really see
> > anything in the init path to properly skip over reserved holes inside
> > the node.
> 
> Hi Michal,
> 
> This is not a stupid question. I figured out how this whole thing
> became broken:  Revert "mm: page_alloc: skip over regions of invalid
> pfns where possible" caused that.
> 
> Because, before that was reverted, memmap_init_zone() would use
> memblock.memory to check that only pages that have physical backing
> are initialized. But, now after that was reverted zer_resv_unavail()
> scheme became totally broken.
>
> The concept is quite easy: zero all the allocated memmap memory that
> has not been initialized by memmap_init_zone(). So, I think I will
> modify memmap_init_zone() to zero the skipped pfns that have memmap
> backing. But, that requires more thinking.

I would just go with iterating over valid (unreserved) memory ranges in
memmap_init_zone.

-- 
Michal Hocko
SUSE Labs
