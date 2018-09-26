Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3C90B8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:43:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x20-v6so896097eda.22
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 01:43:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60-v6si6756038edy.200.2018.09.26.01.43.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 01:43:21 -0700 (PDT)
Subject: Re: [patch v3] mm, thp: always specify disabled vmas as nh in smaps
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
 <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
 <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809251449060.96762@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <74154099-1dff-e821-8220-356402a5644f@suse.cz>
Date: Wed, 26 Sep 2018 10:40:42 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1809251449060.96762@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 9/25/18 11:50 PM, David Rientjes wrote:
> Commit 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> introduced a regression in that userspace cannot always determine the set
> of vmas where thp is disabled.
> 
> Userspace relies on the "nh" flag being emitted as part of /proc/pid/smaps
> to determine if a vma has been disabled from being backed by hugepages.
> 
> Previous to this commit, prctl(PR_SET_THP_DISABLE, 1) would cause thp to
> be disabled and emit "nh" as a flag for the corresponding vmas as part of
> /proc/pid/smaps.  After the commit, thp is disabled by means of an mm
> flag and "nh" is not emitted.
> 
> This causes smaps parsing libraries to assume a vma is enabled for thp
> and ends up puzzling the user on why its memory is not backed by thp.
> 
> This also clears the "hg" flag to make the behavior of MADV_HUGEPAGE and
> PR_SET_THP_DISABLE definitive.
> 
> Fixes: 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active")
> Signed-off-by: David Rientjes <rientjes@google.com>

Well, as Andrew said, we had the opportunity to provide a more complete
info to userspace e.g. with Michal's suggested /proc/pid/status
enhancement. If this is good enough for you (and nobody else cares) then
I won't block it either. It would be unfortunate though if we could not
revert this in case the MMF_DISABLE_THP querying is implemented later.
Hopefully the only consumers are internal tools such as yours, which can
be easily adapted...

Vlastimil
