Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D05918E005B
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 12:56:08 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id n39so32460331qtn.18
        for <linux-mm@kvack.org>; Sun, 30 Dec 2018 09:56:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t14si1042790qve.42.2018.12.30.09.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Dec 2018 09:56:07 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wBUHrfEg118052
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 12:56:07 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ppq4h9mwq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 30 Dec 2018 12:56:07 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 30 Dec 2018 17:56:05 -0000
Date: Sun, 30 Dec 2018 19:55:56 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
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
Message-Id: <20181230175555.GA31291@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On Fri, Dec 28, 2018 at 11:54:17AM +0100, Vlastimil Babka wrote:
> On 12/28/18 9:18 AM, Michal Hocko wrote:
> > On Thu 27-12-18 21:31:00, Andrew Morton wrote:
> >> On Thu, 27 Dec 2018 14:11:14 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> >>
> >>> On Mon, Dec 24, 2018 at 10:17:31AM +0100, Michal Hocko wrote:
> >>>> On Mon 24-12-18 01:05:57, David Rientjes wrote:
> >>>> [...]
> >>>>> I'm not interested in having a 100 email thread about this when a clear 
> >>>>> and simple fix exists that actually doesn't break user code.
> >>>>
> >>>> You are breaking everybody who really wants to query MADV_NOHUGEPAGE
> >>>> status by this flag. Is there anybody doing that?
> >>>
> >>> Yes.
> >>>
> >>> https://github.com/checkpoint-restore/criu/blob/v3.11/criu/proc_parse.c#L143
> >>
> >> Ugh.  So the regression fix causes a regression?
> > 
> > Yes. The patch from David will hardcode the nohugepage vm flag if the
> > THP was disabled by the prctl at the time of the snapshot. And if the
> > application later enables THP by the prctl then existing mappings would
> > never get the THP enabled status back.
> > 
> > This is the kind of a potential regression I was poiting out earlier
> > when explaining that the patch encodes the logic into the flag exporting
> > and that means that whoever wants to get the raw value of the flag will
> > not be able to do so. Please note that the raw value is exactly what
> > this interface is documented and supposed to export. And as the
> > documentation explains it is implementation specific and anybody to use
> > it should be careful.
> 
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

CRIU parses VmFlags from /proc/pid/smaps during the checkpoint and then
uses their raw values to recreate exactly the same mappings during restore.
We use appropriate madvise() calls to re-establish VMA flags.

Implicitly setting the 'nh' flag in /proc/pid/smaps when THP usage was
restricted with prctl() will make CRIU to call madvise(MADV_NOHUPEPAGE) for
all the mappings with 'nh' set as CRIU cannot detect the actual reason for
VMA being marked as VM_NOHUGEPAGE.

As Andrew pointed out, if the restored process will re-enable THP with
prtcl(), the VMAs will retail VM_NOHUGEPAGE flag. And, I don't see how can
we work around this in CRIU.

> Michal has a patch [2] that reports the prctl() status separately, but
> that doesn't help David's existing userspace. For CRIU this also won't
> help as long the smaps vma flags still silently included the prctl()
> status. Do you see some solution that would work for everybody?

Nothing comes to mind at the moment, maybe next year ;-)

> [1]
> https://www.ozlabs.org/~akpm/mmots/broken-out/mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
> [2]
> https://www.ozlabs.org/~akpm/mmots/broken-out/mm-proc-report-pr_set_thp_disable-in-proc.patch
> 

-- 
Sincerely yours,
Mike.
