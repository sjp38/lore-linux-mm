Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA986B0269
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 13:34:04 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a206-v6so1818637oib.7
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 10:34:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h1-v6si976900otb.275.2018.10.03.10.34.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 10:34:03 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w93HPTeI093994
	for <linux-mm@kvack.org>; Wed, 3 Oct 2018 13:34:03 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mvy369crp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Oct 2018 13:34:02 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 3 Oct 2018 18:34:00 +0100
Date: Wed, 3 Oct 2018 20:33:54 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
References: <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
 <20180925202959.GY18685@dhcp22.suse.cz>
 <alpine.DEB.2.21.1809251440001.94921@chino.kir.corp.google.com>
 <20180925150406.872aab9f4f945193e5915d69@linux-foundation.org>
 <20180926060624.GA18685@dhcp22.suse.cz>
 <20181002112851.GP18290@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810021329260.87409@chino.kir.corp.google.com>
Message-Id: <20181003173354.GA17328@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Tue, Oct 02, 2018 at 01:29:42PM -0700, David Rientjes wrote:
> On Tue, 2 Oct 2018, Michal Hocko wrote:
> 
> > On Wed 26-09-18 08:06:24, Michal Hocko wrote:
> > > On Tue 25-09-18 15:04:06, Andrew Morton wrote:
> > > > On Tue, 25 Sep 2018 14:45:19 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> > > > 
> > > > > > > It is also used in 
> > > > > > > automated testing to ensure that vmas get disabled for thp appropriately 
> > > > > > > and we used "nh" since that is how PR_SET_THP_DISABLE previously enforced 
> > > > > > > this, and those tests now break.
> > > > > > 
> > > > > > This sounds like a bit of an abuse to me. It shows how an internal
> > > > > > implementation detail leaks out to the userspace which is something we
> > > > > > should try to avoid.
> > > > > > 
> > > > > 
> > > > > Well, it's already how this has worked for years before commit 
> > > > > 1860033237d4 broke it.  Changing the implementation in the kernel is fine 
> > > > > as long as you don't break userspace who relies on what is exported to it 
> > > > > and is the only way to determine if MADV_NOHUGEPAGE is preventing it from 
> > > > > being backed by hugepages.
> > > > 
> > > > 1860033237d4 was over a year ago so perhaps we don't need to be
> > > > too worried about restoring the old interface.  In which case
> > > > we have an opportunity to make improvements such as that suggested
> > > > by Michal?
> > > 
> > > Yeah, can we add a way to export PR_SET_THP_DISABLE to userspace
> > > somehow? E.g. /proc/<pid>/status. It is a process wide thing so
> > > reporting it per VMA sounds strange at best.
> > 
> > So how about this? (not tested yet but it should be pretty
> > straightforward)
> 
> Umm, prctl(PR_GET_THP_DISABLE)?
> 

~/git/linux$ git grep PR_GET_THP_DISABLE
include/uapi/linux/prctl.h:#define PR_GET_THP_DISABLE   42
kernel/sys.c:   case PR_GET_THP_DISABLE:
tools/include/uapi/linux/prctl.h:#define PR_GET_THP_DISABLE     42

-- 
Sincerely yours,
Mike.
