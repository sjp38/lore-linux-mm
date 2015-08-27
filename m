Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B3B9A6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 03:22:48 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so35573266wid.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 00:22:48 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bn5si2382164wjb.37.2015.08.27.00.22.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 27 Aug 2015 00:22:46 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm, procfs: Display VmAnon, VmFile and VmShm in
 /proc/pid/status
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
 <1438779685-5227-5-git-send-email-vbabka@suse.cz>
 <55C20DDE.1080506@yandex-team.ru>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DEBAC3.4050500@suse.cz>
Date: Thu, 27 Aug 2015 09:22:43 +0200
MIME-Version: 1.0
In-Reply-To: <55C20DDE.1080506@yandex-team.ru>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Minchan Kim <minchan@kernel.org>

On 08/05/2015 03:21 PM, Konstantin Khlebnikov wrote:
> On 05.08.2015 16:01, Vlastimil Babka wrote:
>> From: Jerome Marchand <jmarchan@redhat.com>
>>
>> It's currently inconvenient to retrieve MM_ANONPAGES value from status
>> and statm files and there is no way to separate MM_FILEPAGES and
>> MM_SHMEMPAGES. Add VmAnon, VmFile and VmShm lines in /proc/<pid>/status
>> to solve these issues.
>>
>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>    Documentation/filesystems/proc.txt | 10 +++++++++-
>>    fs/proc/task_mmu.c                 | 13 +++++++++++--
>>    2 files changed, 20 insertions(+), 3 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
>> index fcf67c7..fadd1b3 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -168,6 +168,9 @@ For example, to get the status information of a process, all you have to do is
>>      VmLck:         0 kB
>>      VmHWM:       476 kB
>>      VmRSS:       476 kB
>> +  VmAnon:      352 kB
>> +  VmFile:      120 kB
>> +  VmShm:         4 kB
>>      VmData:      156 kB
>>      VmStk:        88 kB
>>      VmExe:        68 kB
>> @@ -229,7 +232,12 @@ Table 1-2: Contents of the status files (as of 4.1)
>>     VmSize                      total program size
>>     VmLck                       locked memory size
>>     VmHWM                       peak resident set size ("high water mark")
>> - VmRSS                       size of memory portions
>> + VmRSS                       size of memory portions. It contains the three
>> +                             following parts (VmRSS = VmAnon + VmFile + VmShm)
>> + VmAnon                      size of resident anonymous memory
>> + VmFile                      size of resident file mappings
>> + VmShm                       size of resident shmem memory (includes SysV shm,
>> +                             mapping of tmpfs and shared anonymous mappings)
>
> "Vm" is an acronym for Virtual Memory, but all these are not virtual.
> They are real pages. Let's leave VmRSS as is and invent better prefix
> for new fields: something like "Mem", "Pg", or no prefix at all.

No prefix would be IMHO confusing. Mem could work, but it's not exactly 
consistent with the rest. I think only VmPeak and VmSize talk about 
virtual memory. The rest of existing counters is about physical memory 
being mapped into that virtual memory or consumed by supporting it (PTE, 
PMD) or swapped out. I don't see any difference for the new counters 
here, they would just stand out oddly with some new prefix IMHO.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
