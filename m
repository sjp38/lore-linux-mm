Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B29AB6B0005
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:03:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k21-v6so3333154ede.12
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:03:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3-v6si4654909edv.437.2018.10.15.08.03.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Oct 2018 08:03:27 -0700 (PDT)
Date: Mon, 15 Oct 2018 17:03:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181015150325.GN18839@dhcp22.suse.cz>
References: <20180926060624.GA18685@dhcp22.suse.cz>
 <20181002112851.GP18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
 <20181003073640.GF18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com>
 <20181004055842.GA22173@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
 <20181004094637.GG22173@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com>
 <20181009083326.GG8528@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009083326.GG8528@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue 09-10-18 10:33:26, Michal Hocko wrote:
> On Thu 04-10-18 11:34:11, David Rientjes wrote:
> > On Thu, 4 Oct 2018, Michal Hocko wrote:
> > 
> > > > And prior to the offending commit, there were three ways to control thp 
> > > > but two ways to determine if a mapping was eligible for thp based on the 
> > > > implementation detail of one of those ways.
> > > 
> > > Yes, it is really unfortunate that we have ever allowed to leak such an
> > > internal stuff like VMA flags to userspace.
> > > 
> > 
> > Right, I don't like userspace dependencies on VmFlags in smaps myself, but 
> > it's the only way we have available that shows whether a single mapping is 
> > eligible to be backed by thp :/
> 
> Which is not the case due to reasons mentioned earlier. It only speaks
> about madvise status on the VMA.
> 
> > > > If there are three ways to 
> > > > control thp, userspace is still in the dark wrt which takes precedence 
> > > > over the other: we have PR_SET_THP_DISABLE but globally sysfs has it set 
> > > > to "always", or we have MADV_HUGEPAGE set per smaps but PR_SET_THP_DISABLE 
> > > > shown in /proc/pid/status, etc.
> > > > 
> > > > Which one is the ultimate authority?
> > > 
> > > Isn't our documentation good enough? If not then we should document it
> > > properly.
> > > 
> > 
> > No, because the offending commit actually changed the precedence itself: 
> > PR_SET_THP_DISABLE used to be honored for future mappings and the commit 
> > changed that for all current mappings.
> 
> Which is the actual and the full point of the fix as described in the
> changelog. The original implementation was poor and inconsistent.
> 
> > So as a result of the commit 
> > itself we would have had to change the documentation and userspace can't 
> > be expected to keep up with yet a fourth variable: kernel version.  It 
> > really needs to be simpler, just a per-mapping specifier.
> 
> As I've said, if you really need a per-vma granularity then make it a
> dedicated line in the output with a clear semantic. Do not make VMA
> flags even more confusing.

Can we settle with something please?
-- 
Michal Hocko
SUSE Labs
