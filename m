Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCBB6B039F
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:56:23 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id h188so54413wma.4
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 07:56:23 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id q52si8483548wrb.280.2017.03.31.07.56.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 07:56:22 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:56:17 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 1/9] mm, swap: Make swap cluster size same of THP
 size on x86_64
Message-ID: <20170331145617.GB6408@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-2-ying.huang@intel.com>
 <20170329165522.GA31821@cmpxchg.org>
 <87o9wjtwvv.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87o9wjtwvv.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Thu, Mar 30, 2017 at 08:45:56AM +0800, Huang, Ying wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
> 
> > On Tue, Mar 28, 2017 at 01:32:01PM +0800, Huang, Ying wrote:
> >> @@ -499,6 +499,19 @@ config FRONTSWAP
> >>  
> >>  	  If unsure, say Y to enable frontswap.
> >>  
> >> +config ARCH_USES_THP_SWAP_CLUSTER
> >> +	bool
> >> +	default n
> >
> > This is fine.
> >
> >> +config THP_SWAP_CLUSTER
> >> +	bool
> >> +	depends on SWAP && TRANSPARENT_HUGEPAGE && ARCH_USES_THP_SWAP_CLUSTER
> >> +	default y
> >> +	help
> >> +	  Use one swap cluster to hold the contents of the THP
> >> +	  (Transparent Huge Page) swapped out.  The size of the swap
> >> +	  cluster will be same as that of THP.
> >
> > But this is a super weird thing to ask the user. How would they know
> > what to say, if we don't know? I don't think this should be a config
> > knob at all. Merge the two config items into a simple
> 
> The user will not see this, because there is no string after "bool" to
> let user to select it.  The help here is for document only, so that
> architecture developers could know what this is for.

Oh, I missed that. My bad!

> > config THP_SWAP_CLUSTER
> >      bool
> >      default n
> >
> > and let the archs with reasonable THP sizes select it.
> 
> This will have same effect as the original solution except the document
> is removed.

Then I still don't understand why we need two config symbols. Can't
archs select the documented THP_SWAP_CLUSTER directly?

The #ifdef in swapfile.c could check THP && THP_SWAP_CLUSTER.

Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
