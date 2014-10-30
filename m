Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5E47390008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 11:06:39 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id n3so4812433wiv.6
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:06:38 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id le10si10585565wjb.17.2014.10.30.08.06.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Oct 2014 08:06:38 -0700 (PDT)
Date: Thu, 30 Oct 2014 11:06:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141030150624.GA24818@phnom.home.cmpxchg.org>
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com>
 <20141030082712.GB4664@dhcp22.suse.cz>
 <54523DDE.9000904@oracle.com>
 <20141030141401.GA24520@phnom.home.cmpxchg.org>
 <54524A2F.5050907@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54524A2F.5050907@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On Thu, Oct 30, 2014 at 10:24:47AM -0400, Sasha Levin wrote:
> On 10/30/2014 10:14 AM, Johannes Weiner wrote:
> >> The problem is that you are attempting to read 'locked' when you call
> >> > mem_cgroup_end_page_stat(), so it gets used even before you enter the
> >> > function - and using uninitialized variables is undefined.
> > We are not using that value anywhere if !memcg.  What path are you
> > referring to?
> 
> You're using that value as soon as you are passing it to a function, it
> doesn't matter what happens inside that function.

It's copied as part of the pass-by-value protocol, but we really don't
do anything with it.  So why does it matter?

> >> > Yes, it's a compiler warning.
> > Could you provide that please, including arch, and gcc version?
> 
> On x86,
> 
> $ gcc --version
> gcc (GCC) 5.0.0 20141029 (experimental)
> 
> [   26.868116] ================================================================================
> [   26.870376] UBSan: Undefined behaviour in mm/rmap.c:1084:2

Well, "compiler warning" is misleading at best, this is some
out-of-tree runtime debugging tool.

As per above, there isn't a practical problem here, but your patch
worsens the code by making callsites ignorant of how the interface
works.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
