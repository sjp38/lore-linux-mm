Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26C746B000A
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 13:21:25 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id az8-v6so17377637plb.15
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 10:21:25 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id q11-v6si21234500pll.10.2018.07.12.10.21.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 12 Jul 2018 10:21:23 -0700 (PDT)
Message-ID: <1531416080.18255.8.camel@HansenPartnership.com>
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 12 Jul 2018 10:21:20 -0700
In-Reply-To: <20180712164932.GA3475@bombadil.infradead.org>
References: <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
	 <20180710142740.GQ14284@dhcp22.suse.cz>
	 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
	 <20180711102139.GG20050@dhcp22.suse.cz>
	 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
	 <1531330947.3260.13.camel@HansenPartnership.com>
	 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
	 <1531336913.3260.18.camel@HansenPartnership.com>
	 <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
	 <1531411494.18255.6.camel@HansenPartnership.com>
	 <20180712164932.GA3475@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Waiman Long <longman@redhat.com>, Michal Hocko <mhocko@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin
 C)" <wangkai86@huawei.com>

On Thu, 2018-07-12 at 09:49 -0700, Matthew Wilcox wrote:
> On Thu, Jul 12, 2018 at 09:04:54AM -0700, James Bottomley wrote:
[...]
> > The question I'm trying to get an answer to is why does the dentry
> > cache need special limits when the mm handling of the page cache
> > (and other mm caches) just works?
> 
> I don't know that it does work.A A Or that it works well.

I'm not claiming the general heuristics are perfect (in fact I know we
still have a lot of problems with dirty reclaim and writeback).  I am
willing to bet that any discussion of the heuristics will get a lot of
opposition if we try to introduce per-object limits for every object.

Our clean cache heuristics are simple: clean caches are easy to reclaim
and are thus treated like free memory (there's little cost to filling
them or reclaiming them again).  There is speculation that this
equivalence is problematic because the shrinkers reclaim objects but mm
is looking to reclaim pages and thus you can end up with a few objects
pinning many pages even if the shrinker freed a lot of them.

However, we haven't even reached that level yet ... I'm still
struggling to establish that we have a problem with the behaviour of
the dentry cache under current mm heuristics.  

James
