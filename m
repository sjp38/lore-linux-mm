Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0630E90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 11:32:02 -0400 (EDT)
Received: by mail-lb0-f181.google.com with SMTP id w7so4590019lbi.12
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 08:32:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si12578088laj.61.2014.10.30.08.32.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 08:32:00 -0700 (PDT)
Date: Thu, 30 Oct 2014 16:31:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
Message-ID: <20141030153159.GA3639@dhcp22.suse.cz>
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
Cc: Johannes Weiner <hannes@cmpxchg.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, peterz@infradead.org, linux-mm@kvack.org

On Thu 30-10-14 10:24:47, Sasha Levin wrote:
> On 10/30/2014 10:14 AM, Johannes Weiner wrote:
> >> The problem is that you are attempting to read 'locked' when you call
> >> > mem_cgroup_end_page_stat(), so it gets used even before you enter the
> >> > function - and using uninitialized variables is undefined.
> > We are not using that value anywhere if !memcg.  What path are you
> > referring to?
> 
> You're using that value as soon as you are passing it to a function, it
> doesn't matter what happens inside that function.

I have discussed that with our gcc guys and you are right. Strictly
speaking the compiler is free to do
if (!memcg) abort();
mem_cgroup_end_page_stat(...);

but it is highly unlikely that this will ever happen. Anyway better be
safe than sorry. I guess the following should be sufficient and even
more symmetric:
---
