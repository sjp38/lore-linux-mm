Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5B856B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:46:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u16-v6so20966385pfm.15
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 08:46:56 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id v6-v6si23715404plp.60.2018.07.13.08.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Jul 2018 08:46:55 -0700 (PDT)
Message-ID: <1531496812.3361.9.camel@HansenPartnership.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 13 Jul 2018 08:46:52 -0700
In-Reply-To: <20180713003614.GW2234@dastard>
References: <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
	 <1531330947.3260.13.camel@HansenPartnership.com>
	 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	 <1531336913.3260.18.camel@HansenPartnership.com>
	 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
	 <1531411494.18255.6.camel@HansenPartnership.com>
	 <20180712164932.GA3475@bombadil.infradead.org>
	 <1531416080.18255.8.camel@HansenPartnership.com>
	 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
	 <1531425435.18255.17.camel@HansenPartnership.com>
	 <20180713003614.GW2234@dastard>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai
 (Kevin,C)" <wangkai86@huawei.com>

On Fri, 2018-07-13 at 10:36 +1000, Dave Chinner wrote:
> On Thu, Jul 12, 2018 at 12:57:15PM -0700, James Bottomley wrote:
> > What surprises me most about this behaviour is the steadiness of
> > the page cache ... I would have thought we'd have shrunk it
> > somewhat given the intense call on the dcache.
> 
> Oh, good, the page cache vs superblock shrinker balancing still
> protects the working set of each cache the way it's supposed to
> under heavy single cache pressure. :)

Well, yes, but my expectation is most of the page cache is clean, so
easily reclaimable.  I suppose part of my surprise is that I expected
us to reclaim the clean caches first before we started pushing out the
dirty stuff and reclaiming it.  I'm not saying it's a bad thing, just
saying I didn't expect us to make such good decisions under the
parameters of this test.

> Keep in mind that the amount of work slab cache shrinkers perform is
> directly proportional to the amount of page cache reclaim that is
> performed and the size of the slab cache being reclaimed.A A IOWs,
> under a "single cache pressure" workload we should be directing
> reclaim work to the huge cache creating the pressure and do very
> little reclaim from other caches....

That definitely seems to happen.  The thing I was most surprised about
is the steady pushing of anonymous objects to swap.  I agree the dentry
cache doesn't seem to be growing hugely after the initial jump, so it
seems to be the largest source of reclaim.

> [ What follows from here is conjecture, but is based on what I've
> seen in the past 10+ years on systems with large numbers of negative
> dentries and fragmented dentry/inode caches. ]

OK, so I fully agree with the concern about pathological object vs page
freeing problems (I referred to it previously).  However, I did think
the compaction work that's been ongoing in mm was supposed to help
here?

James
