Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 584FA8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 05:57:23 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so25465719ede.14
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 02:57:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6-v6si854193eji.172.2018.12.28.02.57.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 02:57:21 -0800 (PST)
Subject: Re: + mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch added
 to -mm tree
References: <alpine.DEB.2.21.1812210123210.232416@chino.kir.corp.google.com>
 <14e15543-c18b-6fa0-e107-194216ef3ada@suse.cz>
 <20181221151256.GA6410@dhcp22.suse.cz>
 <20181221140301.0e87b79b923ceb6d0f683749@linux-foundation.org>
 <alpine.DEB.2.21.1812211419320.219499@chino.kir.corp.google.com>
 <20181224080426.GC9063@dhcp22.suse.cz>
 <alpine.DEB.2.21.1812240058060.114867@chino.kir.corp.google.com>
 <20181224091731.GB16738@dhcp22.suse.cz>
 <20181227111114.5tvvkddyp7cytzeb@kshutemo-mobl1>
 <20181227213100.aeee730c1f9ec5cb11de39a3@linux-foundation.org>
 <20181228081847.GP16738@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <00ec4644-70c2-4bd1-ec3f-b994fa0669e8@suse.cz>
Date: Fri, 28 Dec 2018 11:54:17 +0100
MIME-Version: 1.0
In-Reply-To: <20181228081847.GP16738@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, kirill.shutemov@linux.intel.com, adobriyan@gmail.com, Linux API <linux-api@vger.kernel.org>, Andrei Vagin <avagin@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Linux-MM layout <linux-mm@kvack.org>

On 12/28/18 9:18 AM, Michal Hocko wrote:
> On Thu 27-12-18 21:31:00, Andrew Morton wrote:
>> On Thu, 27 Dec 2018 14:11:14 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>>
>>> On Mon, Dec 24, 2018 at 10:17:31AM +0100, Michal Hocko wrote:
>>>> On Mon 24-12-18 01:05:57, David Rientjes wrote:
>>>> [...]
>>>>> I'm not interested in having a 100 email thread about this when a clear 
>>>>> and simple fix exists that actually doesn't break user code.
>>>>
>>>> You are breaking everybody who really wants to query MADV_NOHUGEPAGE
>>>> status by this flag. Is there anybody doing that?
>>>
>>> Yes.
>>>
>>> https://github.com/checkpoint-restore/criu/blob/v3.11/criu/proc_parse.c#L143
>>
>> Ugh.  So the regression fix causes a regression?
> 
> Yes. The patch from David will hardcode the nohugepage vm flag if the
> THP was disabled by the prctl at the time of the snapshot. And if the
> application later enables THP by the prctl then existing mappings would
> never get the THP enabled status back.
> 
> This is the kind of a potential regression I was poiting out earlier
> when explaining that the patch encodes the logic into the flag exporting
> and that means that whoever wants to get the raw value of the flag will
> not be able to do so. Please note that the raw value is exactly what
> this interface is documented and supposed to export. And as the
> documentation explains it is implementation specific and anybody to use
> it should be careful.

Let's add some CRIU guys in the loop (dunno if the right ones). We're
discussing David's patch [1] that makes 'nh' and 'hg' flags reported in
/proc/pid/smaps (and set by madvise) overridable by
prctl(PR_SET_THP_DISABLE). This was sort of accidental behavior (but
only for mappings created after the prctl call) before 4.13 commit
1860033237d4 ("mm: make PR_SET_THP_DISABLE immediately active").

For David's userspace that commit is a regression as there are false
positives when checking for vma's that are eligible for THP (=don't have
the 'nh' flag in smaps) but didn't really obtain THP's. The userspace
assumes it's due to fragmentation (=bad) and cannot know that it's due
to the prctl(). But we fear that making prctl() affect smaps vma flags
means that CRIU can't query them accurately anymore, and thus it's a
regression for CRIU. Can you comment on that?
Michal has a patch [2] that reports the prctl() status separately, but
that doesn't help David's existing userspace. For CRIU this also won't
help as long the smaps vma flags still silently included the prctl()
status. Do you see some solution that would work for everybody?

[1]
https://www.ozlabs.org/~akpm/mmots/broken-out/mm-thp-always-specify-disabled-vmas-as-nh-in-smaps.patch
[2]
https://www.ozlabs.org/~akpm/mmots/broken-out/mm-proc-report-pr_set_thp_disable-in-proc.patch
