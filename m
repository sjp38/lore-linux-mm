Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC5C8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 07:36:01 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id g92-v6so6808940ljg.23
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 04:36:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w25-v6sor24839012ljw.35.2018.12.28.04.35.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Dec 2018 04:35:59 -0800 (PST)
Date: Fri, 28 Dec 2018 15:35:56 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
Message-ID: <20181228123556.GE9509@uranus.lan>
References: <20181221151256.GA6410@dhcp22.suse.cz>
 <20181221140301.0e87b79b923ceb6d0f683749@linux-foundation.org>
 <alpine.DEB.2.21.1812211419320.219499@chino.kir.corp.google.com>
 <20181224080426.GC9063@dhcp22.suse.cz>
 <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
 <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Fri, Dec 28, 2018 at 11:54:17AM +0100, Vlastimil Babka wrote:
...
> Let's add some CRIU guys in the loop (dunno if the right ones). We're
> discussing David's patch [1] that makes 'nh' and 'hg' flags reported in
> /proc/pid/smaps (and set by madvise) overridable by
> prctl(PR_SET_THP_DISABLE). This was sort of accidental behavior (but
> only for mappings created after the prctl call) before 4.13 commit
> 1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active").
> 
> For David's userspace that commit is a regression as there are false
> positives when checking for vma's that are eligible for THP (=don't have
> the 'nh' flag in smaps) but didn't really obtain THP's. The userspace
> assumes it's due to fragmentation (=bad) and cannot know that it's due
> to the prctl(). But we fear that making prctl() affect smaps vma flags
> means that CRIU can't query them accurately anymore, and thus it's a
> regression for CRIU. Can you comment on that?
> Michal has a patch [2] that reports the prctl() status separately, but
> that doesn't help David's existing userspace. For CRIU this also won't
> help as long the smaps vma flags still silently included the prctl()
> status. Do you see some solution that would work for everybody?
> 
> [1]
> https://www.ozlabs.org/~akpm/mmots/broken-out/mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
> [2]
> https://www.ozlabs.org/~akpm/mmots/broken-out/mm-proc-report-pr_set_thp_disable-in-proc.patch

First of all, thanks for CC'ing. Pavel and Mike should know more about
criu's part of THP. We'are using the smaps flags on later restore stage
only where we call madvise on particular vma area. But from general pov
it is fishy to hardcode nh flag into smaps report depedning on prctl flag
-- prctl and madvise are two different interfaces. Is it possible for
David to update their userspace tools instead? I know it shounds as
we're violating 'don't-break-user-space' term but with ability to
parse /proc/pid/status to figure out if thp is enabled/disabled should
not be that hard.
