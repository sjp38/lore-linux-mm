Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F263A6B7D96
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 05:19:36 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w12-v6so16009735oie.12
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 02:19:36 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e132-v6si4808375oig.406.2018.09.07.02.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Sep 2018 02:19:35 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w879It3i121082
	for <linux-mm@kvack.org>; Fri, 7 Sep 2018 05:19:35 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mbmyx40aj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 07 Sep 2018 05:19:35 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 7 Sep 2018 10:19:33 +0100
Date: Fri, 7 Sep 2018 12:19:22 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 07/29] memblock: remove _virt from APIs returning
 virtual address
References: <1536163184-26356-8-git-send-email-rppt@linux.vnet.ibm.com>
 <CABGGiswdb1x-=vqrgxZ9i2dnLdsgtXq4+5H9Y1JRd90YVMW69A@mail.gmail.com>
 <20180905172017.GA2203@rapoport-lnx>
 <20180906072800.GN14951@dhcp22.suse.cz>
 <20180906124321.GD27492@rapoport-lnx>
 <20180906130102.GY14951@dhcp22.suse.cz>
 <20180906133958.GM27492@rapoport-lnx>
 <20180906134627.GZ14951@dhcp22.suse.cz>
 <20180907084211.GA19153@rapoport-lnx>
 <20180907084756.GD19621@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907084756.GD19621@dhcp22.suse.cz>
Message-Id: <20180907091922.GB19153@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rob Herring <robh@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, mingo@redhat.com, Michael Ellerman <mpe@ellerman.id.au>, paul.burton@mips.com, Thomas Gleixner <tglx@linutronix.de>, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Sep 07, 2018 at 10:47:56AM +0200, Michal Hocko wrote:
> On Fri 07-09-18 11:42:12, Mike Rapoport wrote:
> > On Thu, Sep 06, 2018 at 03:46:27PM +0200, Michal Hocko wrote:
> > > On Thu 06-09-18 16:39:58, Mike Rapoport wrote:
> > > > On Thu, Sep 06, 2018 at 03:01:02PM +0200, Michal Hocko wrote:
> > > > > On Thu 06-09-18 15:43:21, Mike Rapoport wrote:
> > > > > > On Thu, Sep 06, 2018 at 09:28:00AM +0200, Michal Hocko wrote:
> > > > > > > On Wed 05-09-18 20:20:18, Mike Rapoport wrote:
> > > > > > > > On Wed, Sep 05, 2018 at 12:04:36PM -0500, Rob Herring wrote:
> > > > > > > > > On Wed, Sep 5, 2018 at 11:00 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> > > > > > > > > >
> > > > > > > > > > The conversion is done using
> > > > > > > > > >
> > > > > > > > > > sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
> > > > > > > > > >         $(git grep -l memblock_virt_alloc)
> > > > > > > > > 
> > > > > > > > > What's the reason to do this? It seems like a lot of churn even if a
> > > > > > > > > mechanical change.
> > > > > > > > 
> > > > > > > > I felt that memblock_virt_alloc_ is too long for a prefix, e.g:
> > > > > > > > memblock_virt_alloc_node_nopanic, memblock_virt_alloc_low_nopanic.
> > > > > > > > 
> > > > > > > > And for consistency I've changed the memblock_virt_alloc as well.
> > > > > > > 
> > > > > > > I would keep the current API unless the name is terribly misleading or
> > > > > > > it can be improved a lot. Neither seems to be the case here. So I would
> > > > > > > rather stick with the status quo.
> > > > > > 
> > > > > > I'm ok with the memblock_virt_alloc by itself, but having 'virt' in
> > > > > > 'memblock_virt_alloc_try_nid_nopanic' and 'memblock_virt_alloc_low_nopanic'
> > > > > > reduces code readability in my opinion.
> > > > > 
> > > > > Well, is _nopanic really really useful in the name. Do we even need/want
> > > > > implicit panic/nopanic semantic? The code should rather check for the
> > > > > return value and decide depending on the code path. I suspect removing
> > > > > panic/nopanic would make the API slightly lighter.
> > > >  
> > > > I agree that panic/nopanic should be removed. But I prefer to start with
> > > > equivalent replacement to make it as automated as possible and update
> > > > memblock API when the dust settles a bit.
> > > 
> > > Yes, I agree with that approach. But that also doesn't justify the
> > > renaming
> > 
> > Well, the renaming is automated :)
> 
> Yes, it is. It also adds churn to the code so I tend to prefer an
> existing naming unless it is completely misleading or incomprehensible.
> 
> Is this something to lose sleep over. Absolutely not! Does it make sense
> to discuss further? I do not think so. If you strongly believe that the
> renaming is a good thing then just do it.

I won't lose my sleep over it, but I do believe that renaming is a good thing. 
I think that in the end we'll be able to reduce the memblock allocation API
to a handful of memblock_alloc_ variants instead of ~20 we have now.

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.
