Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAF86B0003
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 04:02:45 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o42so9846294edc.13
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 01:02:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c6-v6si905195ejd.9.2018.11.15.01.02.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 01:02:43 -0800 (PST)
Date: Thu, 15 Nov 2018 10:02:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, proc: report PR_SET_THP_DISABLE in proc
Message-ID: <20181115090242.GH23831@dhcp22.suse.cz>
References: <20181009083326.GG8528@dhcp22.suse.cz>
 <20181015150325.GN18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810151519250.247641@chino.kir.corp.google.com>
 <20181016104855.GQ18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810161416540.83080@chino.kir.corp.google.com>
 <20181017070531.GC18839@dhcp22.suse.cz>
 <alpine.DEB.2.21.1810171256330.60837@chino.kir.corp.google.com>
 <20181018070031.GW18839@dhcp22.suse.cz>
 <20181114132306.GX23419@dhcp22.suse.cz>
 <alpine.DEB.2.21.1811141336010.200345@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1811141336010.200345@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed 14-11-18 13:41:12, David Rientjes wrote:
> On Wed, 14 Nov 2018, Michal Hocko wrote:
> 
> > > > > Do you know of any other userspace except your usecase? Is there
> > > > > anything fundamental that would prevent a proper API adoption for you?
> > > > > 
> > > > 
> > > > Yes, it would require us to go back in time and build patched binaries. 
> > > 
> > > I read that as there is a fundamental problem to update existing
> > > binaries. If that is the case then there surely is no way around it
> > > and another sad page in the screwed up APIs book we provide.
> > > 
> > > But I was under impression that the SW stack which actually does the
> > > monitoring is under your controll. Moreover I was under impression that
> > > you do not use the current vanilla kernel so there is no need for an
> > > immediate change on your end. It is trivial to come up with a backward
> > > compatible way to check for the new flag (if it is not present then
> > > fallback to vma flags).
> > > 
> 
> The userspace had a single way to determine if thp had been disabled for a 
> specific vma and that was broken with your commit.  We have since fixed 
> it.  Modifying our software stack to start looking for some field 
> somewhere else will not help anybody else that this has affected or will 
> affect.  I'm interested in not breaking userspace, not trying a wait and 
> see approach to see if anybody else complains once we start looking for 
> some other field.  The risk outweighs the reward, it already broke us, and 
> I'd prefer not to even open the possibility of breaking anybody else.

I very much agree on "do not break userspace" part but this is kind of
gray area. VMA flags are a deep internal implementation detail and
nobody should really depend on it for anything important. The original
motivation for introducing it was CRIU where it is kind of
understandable. I would argue they should find a different way but it is
just too late for them.

For this particular case there was no other bug report except for yours
and if it is possible to fix it on your end then I would really love to
make the a sensible user interface to query the status. If we are going
to change the semantic of the exported flag again then we risk yet
another breakage.

Therefore I am asking whether changing your particular usecase to a new
interface is possible because that would allow to have a longerm
sensible user interface rather than another kludge which still doesn't
cover all the usecases (e.g. there is no way to reliably query the
madvise status after your patch).

-- 
Michal Hocko
SUSE Labs
