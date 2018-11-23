Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5EB6B3183
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 10:25:08 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 75so2988293pfq.8
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:25:08 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v23-v6si51320987plo.182.2018.11.23.07.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 07:25:06 -0800 (PST)
Subject: Re: [RFC PATCH 2/3] mm, thp, proc: report THP eligibility for each
 vma
References: <20181120103515.25280-1-mhocko@kernel.org>
 <20181120103515.25280-3-mhocko@kernel.org>
 <73b55240-d36c-cf97-d7fd-85e2ae1e9309@suse.cz>
 <20181123152136.GA5827@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a5b54792-7ad8-6502-a588-892f63df01cd@suse.cz>
Date: Fri, 23 Nov 2018 16:24:57 +0100
MIME-Version: 1.0
In-Reply-To: <20181123152136.GA5827@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-api@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 11/23/18 4:21 PM, Michal Hocko wrote:
> On Fri 23-11-18 16:07:06, Vlastimil Babka wrote:
>> On 11/20/18 11:35 AM, Michal Hocko wrote:
>>> From: Michal Hocko <mhocko@suse.com>
>>>
>>> Userspace falls short when trying to find out whether a specific memory
>>> range is eligible for THP. There are usecases that would like to know
>>> that
>>> http://lkml.kernel.org/r/alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com
>>> : This is used to identify heap mappings that should be able to fault thp
>>> : but do not, and they normally point to a low-on-memory or fragmentation
>>> : issue.
>>>
>>> The only way to deduce this now is to query for hg resp. nh flags and
>>> confronting the state with the global setting. Except that there is
>>> also PR_SET_THP_DISABLE that might change the picture. So the final
>>> logic is not trivial. Moreover the eligibility of the vma depends on
>>> the type of VMA as well. In the past we have supported only anononymous
>>> memory VMAs but things have changed and shmem based vmas are supported
>>> as well these days and the query logic gets even more complicated
>>> because the eligibility depends on the mount option and another global
>>> configuration knob.
>>>
>>> Simplify the current state and report the THP eligibility in
>>> /proc/<pid>/smaps for each existing vma. Reuse transparent_hugepage_enabled
>>> for this purpose. The original implementation of this function assumes
>>> that the caller knows that the vma itself is supported for THP so make
>>> the core checks into __transparent_hugepage_enabled and use it for
>>> existing callers. __show_smap just use the new transparent_hugepage_enabled
>>> which also checks the vma support status (please note that this one has
>>> to be out of line due to include dependency issues).
>>>
>>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>>
>> Not thrilled by this,
> 
> Any specific concern?

The kitchen sink that smaps slowly becomes, with associated overhead
(i.e. one of reasons there's now smaps_rollup). Would be much nicer if
userspace had some way to say which fields it's interested in. But I
have no good ideas for that right now :/
