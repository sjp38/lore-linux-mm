Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5673C6B026E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:48:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g11-v6so2874278edi.8
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:48:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u18-v6si209353eda.251.2018.07.19.01.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 01:48:04 -0700 (PDT)
Date: Thu, 19 Jul 2018 10:48:02 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180719084802.GQ7193@dhcp22.suse.cz>
References: <1531336913.3260.18.camel@HansenPartnership.com>
 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
 <1531411494.18255.6.camel@HansenPartnership.com>
 <20180712164932.GA3475@bombadil.infradead.org>
 <1531416080.18255.8.camel@HansenPartnership.com>
 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
 <1531425435.18255.17.camel@HansenPartnership.com>
 <20180713003614.GW2234@dastard>
 <20180716090901.GG17280@dhcp22.suse.cz>
 <caf309f5-2844-6546-e545-6ae56ad7d022@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <caf309f5-2844-6546-e545-6ae56ad7d022@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>

On Wed 18-07-18 12:17:24, Waiman Long wrote:
> On 07/16/2018 05:09 AM, Michal Hocko wrote:
> > On Fri 13-07-18 10:36:14, Dave Chinner wrote:
> > [...]
> >> By limiting the number of negative dentries in this case, internal
> >> slab fragmentation is reduced such that reclaim cost never gets out
> >> of control. While it appears to "fix" the symptoms, it doesn't
> >> address the underlying problem. It is a partial solution at best but
> >> at worst it's another opaque knob that nobody knows how or when to
> >> tune.
> > Would it help to put all the negative dentries into its own slab cache?
> >
> >> Very few microbenchmarks expose this internal slab fragmentation
> >> problem because they either don't run long enough, don't create
> >> memory pressure, or don't have access patterns that mix long and
> >> short term slab objects together in a way that causes slab
> >> fragmentation. Run some cold cache directory traversals (git
> >> status?) at the same time you are creating negative dentries so you
> >> create pinned partial pages in the slab cache and see how the
> >> behaviour changes....
> > Agreed! Slab fragmentation is a real problem we are seeing for quite
> > some time. We should try to address it rather than paper over it with
> > weird knobs.
> 
> I am aware that you don't like the limit knob that control how many
> negative dentries are allowed as a percentage of total system memory. I
> got comments in the past about doing some kind of auto-tuning. How about
> consolidating the 2 knobs that I currently have in the patchset into a
> single one with 3 possible values, like:
> 
> 0 - no limiting
> 1 - set soft limit to "a constant + 4 x max # of positive dentries" and
> warn if exceeded
> 2 - same limit but kill excess negative dentries after use.
> 
> Does that kind of knob make more sense to you?

Not really. See the pagecache limit story in http://lkml.kernel.org/r/20180719084538.GP7193@dhcp22.suse.cz
I might be overly sensitive but I got burnt a lot in the past. We should
strive to make the reclaim seamless without asking admins to do our job.
-- 
Michal Hocko
SUSE Labs
