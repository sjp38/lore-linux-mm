Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B71656B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:42:31 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a20-v6so25375660pfi.1
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:42:31 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id q145-v6si11496881pfq.315.2018.07.16.07.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 16 Jul 2018 07:42:30 -0700 (PDT)
Message-ID: <1531752146.3171.2.camel@HansenPartnership.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 16 Jul 2018 07:42:26 -0700
In-Reply-To: <20180716091040.GH17280@dhcp22.suse.cz>
References: <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	 <1531336913.3260.18.camel@HansenPartnership.com>
	 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
	 <1531411494.18255.6.camel@HansenPartnership.com>
	 <20180712164932.GA3475@bombadil.infradead.org>
	 <1531416080.18255.8.camel@HansenPartnership.com>
	 <CA+55aFzfQz7c8pcMfLDaRNReNF2HaKJGoWpgB6caQjNAyjg-hA@mail.gmail.com>
	 <1531425435.18255.17.camel@HansenPartnership.com>
	 <20180713003614.GW2234@dastard>
	 <1531496812.3361.9.camel@HansenPartnership.com>
	 <20180716091040.GH17280@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Chinner <david@fromorbit.com>, Linus Torvalds <torvalds@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai
 (Kevin,C)" <wangkai86@huawei.com>

On Mon, 2018-07-16 at 11:10 +0200, Michal Hocko wrote:
> On Fri 13-07-18 08:46:52, James Bottomley wrote:
> > On Fri, 2018-07-13 at 10:36 +1000, Dave Chinner wrote:
> > > On Thu, Jul 12, 2018 at 12:57:15PM -0700, James Bottomley wrote:
> > > > What surprises me most about this behaviour is the steadiness
> > > > of the page cache ... I would have thought we'd have shrunk it
> > > > somewhat given the intense call on the dcache.
> > > 
> > > Oh, good, the page cache vs superblock shrinker balancing still
> > > protects the working set of each cache the way it's supposed to
> > > under heavy single cache pressure. :)
> > 
> > Well, yes, but my expectation is most of the page cache is clean,
> > so easily reclaimable.A A I suppose part of my surprise is that I
> > expected us to reclaim the clean caches first before we started
> > pushing out the dirty stuff and reclaiming it.A A I'm not saying it's
> > a bad thing, just saying I didn't expect us to make such good
> > decisions under the parameters of this test.
> 
> This is indeed unepxected. Especially when the current LRU reclaim
> balancing logic is highly pagecache biased. Are you sure you were not
> running in a memcg with a small amount of the pagecache?

Yes, absolutely: I just compiled and ran the programme on my laptop
with no type of containment (I trust Linus, right ...)

To be clear, the dirty anon push out was quite slow, so I don't think
mm was using it as a serious source of reclaim, it was probably just
being caught up in some other page clearing process.

James
