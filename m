Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 225D26B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 08:40:36 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w95so3321075wrc.20
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 05:40:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x1si8982260edc.447.2017.11.06.05.40.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 06 Nov 2017 05:40:34 -0800 (PST)
Date: Mon, 6 Nov 2017 14:40:31 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm: do not rely on preempt_count in print_vma_addr (was: Re:
 [PATCH] mm: use in_atomic() in print_vma_addr())
Message-ID: <20171106134031.g6dbelg55mrbyc6i@dhcp22.suse.cz>
References: <1509572313-102989-1-git-send-email-yang.s@alibaba-inc.com>
 <20171102075744.whhxjmqbdkfaxghd@dhcp22.suse.cz>
 <ace5b078-652b-cbc0-176a-25f69612f7fa@alibaba-inc.com>
 <20171103110245.7049460a05cc18c7e8a9feb2@linux-foundation.org>
 <1509739786.2473.33.camel@wdc.com>
 <20171105081946.yr2pvalbegxygcky@dhcp22.suse.cz>
 <20171106100558.GD3165@worktop.lehotels.local>
 <20171106104354.2jlgd2m4j4gxx4qo@dhcp22.suse.cz>
 <20171106120025.GH3165@worktop.lehotels.local>
 <20171106121222.nnzrr4cb7s7y5h74@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171106121222.nnzrr4cb7s7y5h74@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Bart Van Assche <Bart.VanAssche@wdc.com>, "yang.s@alibaba-inc.com" <yang.s@alibaba-inc.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "joe@perches.com" <joe@perches.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mingo@redhat.com" <mingo@redhat.com>

On Mon 06-11-17 13:12:22, Michal Hocko wrote:
> On Mon 06-11-17 13:00:25, Peter Zijlstra wrote:
> > On Mon, Nov 06, 2017 at 11:43:54AM +0100, Michal Hocko wrote:
> > > > Yes the comment is very much accurate.
> > > 
> > > Which suggests that print_vma_addr might be problematic, right?
> > > Shouldn't we do trylock on mmap_sem instead?
> > 
> > Yes that's complete rubbish. trylock will get spurious failures to print
> > when the lock is contended.
> 
> Yes, but I guess that it is acceptable to to not print the state under
> that condition.

So what do you think about this? I think this is more robust than
playing tricks with the explicit preempt count checks and less tedious
than checking to make it conditional on the context. This is on top of
Linus tree and if accepted it should replace the patch discussed here.
---
