Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5791C6B0008
	for <linux-mm@kvack.org>; Tue, 22 May 2018 09:51:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id q13-v6so10484352wrj.15
        for <linux-mm@kvack.org>; Tue, 22 May 2018 06:51:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c34-v6si371107eda.167.2018.05.22.06.51.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 22 May 2018 06:51:56 -0700 (PDT)
Date: Tue, 22 May 2018 15:51:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/7] mm: pages for hugetlb's overcommit may be able to
 charge to memcg
Message-ID: <20180522135148.GA20441@dhcp22.suse.cz>
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Punit Agrawal <punit.agrawal@arm.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Fri 18-05-18 13:27:27, TSUKADA Koutaro wrote:
> Thanks to Mike Kravetz for comment on the previous version patch.

I am sorry that I didn't join the discussion for the previous version
but time just didn't allow that. So sorry if I am repeating something
already sorted out.

> The purpose of this patch-set is to make it possible to control whether or
> not to charge surplus hugetlb pages obtained by overcommitting to memory
> cgroup. In the future, I am trying to accomplish limiting the memory usage
> of applications that use both normal pages and hugetlb pages by the memory
> cgroup(not use the hugetlb cgroup).

There was a deliberate decision to keep hugetlb and "normal" memory
cgroup controllers separate. Mostly because hugetlb memory is an
artificial memory subsystem on its own and it doesn't fit into the rest
of memcg accounted memory very well. I believe we want to keep that
status quo.

> Applications that use shared libraries like libhugetlbfs.so use both normal
> pages and hugetlb pages, but we do not know how much to use each. Please
> suppose you want to manage the memory usage of such applications by cgroup
> How do you set the memory cgroup and hugetlb cgroup limit when you want to
> limit memory usage to 10GB?

Well such a usecase requires an explicit configuration already. Either
by using special wrappers or modifying the code. So I would argue that
you have quite a good knowlege of the setup. If you need a greater
flexibility then just do not use hugetlb at all and rely on THP.
[...]

> In this patch-set, introduce the charge_surplus_huge_pages(boolean) to
> struct hstate. If it is true, it charges to the memory cgroup to which the
> task that obtained surplus hugepages belongs. If it is false, do nothing as
> before, and the default value is false. The charge_surplus_huge_pages can
> be controlled procfs or sysfs interfaces.

I do not really think this is a good idea. We really do not want to make
the current hugetlb code more complex than it is already. The current
hugetlb cgroup controller is simple and works at least somehow. I would
not add more on top unless there is a _really_ strong usecase behind.
Please make sure to describe such a usecase in details before we even
start considering the code.

> Since THP is very effective in environments with kernel page size of 4KB,
> such as x86, there is no reason to positively use HugeTLBfs, so I think
> that there is no situation to enable charge_surplus_huge_pages. However, in
> some distributions such as arm64, the page size of the kernel is 64KB, and
> the size of THP is too huge as 512MB, making it difficult to use. HugeTLBfs
> may support multiple huge page sizes, and in such a special environment
> there is a desire to use HugeTLBfs.

Well, then I would argue that you shouldn't use 64kB pages for your
setup or allow THP for smaller sizes. Really hugetlb pages are by no
means a substitute here.
-- 
Michal Hocko
SUSE Labs
