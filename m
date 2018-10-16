Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 984686B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 17:24:23 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h76-v6so25009482pfd.10
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 14:24:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 137-v6sor5868449pge.87.2018.10.16.14.24.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 14:24:22 -0700 (PDT)
Date: Tue, 16 Oct 2018 14:24:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
In-Reply-To: <20181016104855.GQ18839@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com> <20181003073640.GF18290@dhcp22.suse.cz> <alpine.DEB.2.21.1810031547150.202532@chino.kir.corp.google.com> <20181004055842.GA22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810040209130.113459@chino.kir.corp.google.com>
 <20181004094637.GG22173@dhcp22.suse.cz> <alpine.DEB.2.21.1810041130380.12951@chino.kir.corp.google.com> <20181009083326.GG8528@dhcp22.suse.cz> <20181015150325.GN18839@dhcp22.suse.cz> <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
 <20181016104855.GQ18839@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, 16 Oct 2018, Michal Hocko wrote:

> > I don't understand the point of extending smaps with yet another line.  
> 
> Because abusing a vma flag part is just wrong. What are you going to do
> when a next bug report states that the flag is set even though no
> userspace has set it and that leads to some malfunctioning? Can you rule
> that out? Even your abuse of the flag is surprising so why others
> wouldn't be?
> 

The flag has taken on the meaning of "thp disabled for this vma", how it 
is set is not the scope of the flag.  If a thp is explicitly disabled from 
being eligible for thp, whether by madvise, prctl, or any future 
mechanism, it should use VM_NOHUGEPAGE or show_smap_vma_flags() needs to 
be modified.

I agree with you that this could have been done better if an interface was 
defined earlier that userspace could have used.  PR_SET_THP_DISABLE was 
merged long after thp had already been merged so this can be a reminder 
that defining clean, robust, and extensible APIs is important, but I'm 
afraid we can't go back in time and change how userspace queries 
information, especially in cases where there was only one way to do it.

> > The only way for a different process to determine if a single vma from 
> > another process is thp disabled is by the "nh" flag, so it is reasonable 
> > that userspace reads this.  My patch fixes that.  If smaps is extended 
> > with another line per your patch, it doesn't change the fact that previous 
> > binaries are built to check for "nh" so it does not deprecate that.  
> > ("THP_Enabled" is also ambiguous since it only refers to prctl and not the 
> > default thp setting or madvise.)
> 
> As I've said there are two things. Exporting PR_SET_THP_DISABLE to
> userspace so that a 3rd party process can query it. I've already
> explained why that might be useful. If you really insist on having
> a per-vma field then let's do it properly now. Are you going to agree on
> that? If yes, I am willing to spend my time on that but I am not going
> to bother if this will lead to "I want my vma field abuse anyway".

I think what you and I want is largely irrelevant :)  What's important is 
that there are userspace implementations that query this today so 
continuing to support it as the way to determine if a vma has been thp 
disabled doesn't seem problematic and guarantees that userspace doesn't 
break.
