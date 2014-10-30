Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 51E7D90008B
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 09:32:48 -0400 (EDT)
Received: by mail-yk0-f180.google.com with SMTP id 9so2254975ykp.25
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 06:32:48 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h69si7254442yhd.36.2014.10.30.06.32.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 06:32:47 -0700 (PDT)
Message-ID: <54523DDE.9000904@oracle.com>
Date: Thu, 30 Oct 2014 09:32:14 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: initialize variable for mem_cgroup_end_page_stat
References: <1414633464-19419-1-git-send-email-sasha.levin@oracle.com> <20141030082712.GB4664@dhcp22.suse.cz>
In-Reply-To: <20141030082712.GB4664@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, peterz@infradead.org, linux-mm@kvack.org

On 10/30/2014 04:27 AM, Michal Hocko wrote:
> On Wed 29-10-14 21:44:24, Sasha Levin wrote:
>> > Commit "mm: memcontrol: fix missed end-writeback page accounting" has changed
>> > the behaviour of mem_cgroup_begin_page_stat() to not always set the "locked"
>> > parameter.
>> > 
>> > We should initialize it at the callers to prevent garbage being used in a
>> > later call to mem_cgroup_end_page_stat().
> The contract is that if the returned memcg is non-NULL then the locked
> is always initialized. Nobody but mem_cgroup_end_page_stat should touch
> this variable and this function makes sure it uses it properly. Similar
> applies to flags which is initialized only if we really take the slow
> path (has a meaning only if locked == true).
> 
> So this is not really needed. Was this triggered by a compiler warning?

The problem is that you are attempting to read 'locked' when you call
mem_cgroup_end_page_stat(), so it gets used even before you enter the
function - and using uninitialized variables is undefined.

Yes, it's a compiler warning.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
