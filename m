Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D36248E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 05:21:48 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so15614931pfe.10
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 02:21:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p2si13078185pgr.133.2019.01.21.02.21.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 02:21:47 -0800 (PST)
Date: Mon, 21 Jan 2019 11:21:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
Message-ID: <20190121102144.GP4087@dhcp22.suse.cz>
References: <20181221140301.0e87b79b923ceb6d0f683749@linux-foundation.org>
 <alpine.DEB.2.21.1812211419320.219499@chino.kir.corp.google.com>
 <20181224080426.GC9063@dhcp22.suse.cz>
 <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
 <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
 <20190115063202.GA13744@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115063202.GA13744@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Tue 15-01-19 08:32:02, Mike Rapoport wrote:
> Hi,
> 
> The holidays are over and I think it's time to resurrect this thread.
> 
> On Fri, Dec 28, 2018 at 11:54:17AM +0100, Vlastimil Babka wrote:
> > On 12/28/18 9:18 AM, Michal Hocko wrote:
> > > On Thu 27-12-18 21:31:00, Andrew Morton wrote:
> > >> On Thu, 27 Dec 2018 14:11:14 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> > >>
> > >>> On Mon, Dec 24, 2018 at 10:17:31AM +0100, Michal Hocko wrote:
> > >>>> On Mon 24-12-18 01:05:57, David Rientjes wrote:
> > >>>> [...]
> > >>>>> I'm not interested in having a 100 email thread about this when a clear 
> > >>>>> and simple fix exists that actually doesn't break user code.
> > >>>>
> > >>>> You are breaking everybody who really wants to query MADV_NOHUGEPAGE
> > >>>> status by this flag. Is there anybody doing that?
> > >>>
> > >>> Yes.
> > >>>
> > >>> https://github.com/checkpoint-restore/criu/blob/v3.11/criu/proc_parse.c#L143
> > >>
> > >> Ugh.  So the regression fix causes a regression?
> > > 
> > > Yes. The patch from David will hardcode the nohugepage vm flag if the
> > > THP was disabled by the prctl at the time of the snapshot. And if the
> > > application later enables THP by the prctl then existing mappings would
> > > never get the THP enabled status back.
> > > 
> > > This is the kind of a potential regression I was poiting out earlier
> > > when explaining that the patch encodes the logic into the flag exporting
> > > and that means that whoever wants to get the raw value of the flag will
> > > not be able to do so. Please note that the raw value is exactly what
> > > this interface is documented and supposed to export. And as the
> > > documentation explains it is implementation specific and anybody to use
> > > it should be careful.
> > 
> > Let's add some CRIU guys in the loop (dunno if the right ones). We're
> > discussing David's patch [1] that makes 'nh' and 'hg' flags reported in
> > /proc/pid/smaps (and set by madvise) overridable by
> > prctl(PR_SET_THP_DISABLE). This was sort of accidental behavior (but
> > only for mappings created after the prctl call) before 4.13 commit
> > 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active").
> > 
> > For David's userspace that commit is a regression as there are false
> > positives when checking for vma's that are eligible for THP (=don't have
> > the 'nh' flag in smaps) but didn't really obtain THP's. The userspace
> > assumes it's due to fragmentation (=bad) and cannot know that it's due
> > to the prctl(). But we fear that making prctl() affect smaps vma flags
> > means that CRIU can't query them accurately anymore, and thus it's a
> > regression for CRIU. Can you comment on that?
> > Michal has a patch [2] that reports the prctl() status separately, but
> > that doesn't help David's existing userspace. For CRIU this also won't
> > help as long the smaps vma flags still silently included the prctl()
> > status. Do you see some solution that would work for everybody?
> 
> The patch from David obviously breaks CRIU, and I can't see a nice solution
> that will work for everybody.
> 
> Of course we could add something like 'NH' to /proc/pid/smaps so that 'nh'
> will work as David's userspace is expecting and 'NH' will represent the
> state of VmFlags. This is hackish and ugly, though.
> 
> In any case, if David's patch is not reverted CRIU needs some way to know
> if VMA has VM_NOHUGEPAGE set.

Hmm, there doesn't seem to be any follow up here and the patch is still
in the mmotm tree AFAICS in mainline-urgent section. I thought it was
clarified that the patch will break an existing userspace that relies on
the documented semantic.

While it is unfortunate that the use case mentioned by David got broken
we have provided a long term sustainable which is much better than
relying on an undocumented side effect of the prctl implementation at
the time.

So can we make a decision on this finally please?

> > [1]
> > https://www.ozlabs.org/~akpm/mmots/broken-out/mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
> > [2]
> > https://www.ozlabs.org/~akpm/mmots/broken-out/mm-proc-report-pr_set_thp_disable-in-proc.patch
> > 
> 
> -- 
> Sincerely yours,
> Mike.

-- 
Michal Hocko
SUSE Labs
