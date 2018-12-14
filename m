Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C20C8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 16:36:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c53so3400077edc.9
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 13:36:44 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k54si2361587edb.369.2018.12.14.13.36.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 13:36:42 -0800 (PST)
Subject: Re: [LKP] [mm] ac5b2c1891: vm-scalability.throughput -61.3%
 regression
References: <64a4aec6-3275-a716-8345-f021f6186d9b@suse.cz>
 <20181204104558.GV23260@techsingularity.net>
 <20181205204034.GB11899@redhat.com>
 <CAHk-=whi8Ju-cTDL4cYtwuLA7BYgGJYyy6HVMoknZaLHnRc83g@mail.gmail.com>
 <20181205233632.GE11899@redhat.com>
 <CAHk-=wguXjkbK8BUU998s7HD7AXJgBkuc9JmuNxiN7uGQyfSfQ@mail.gmail.com>
 <CAHk-=wjm9V843eg0uesMrxKnCCq7UfWn8VJ+z-cNztb_0fVW6A@mail.gmail.com>
 <alpine.DEB.2.21.1812061505010.162675@chino.kir.corp.google.com>
 <CAHk-=wjVuLjZ1Wr52W=hNqh=_8gbzuKA+YpsVb4NBHCJsE6cyA@mail.gmail.com>
 <alpine.DEB.2.21.1812091538310.215735@chino.kir.corp.google.com>
 <20181210044916.GC24097@redhat.com>
 <alpine.DEB.2.21.1812111609060.255489@chino.kir.corp.google.com>
 <0bbf4202-6187-28fb-37b7-da6885b89cce@suse.cz>
 <alpine.DEB.2.21.1812141244450.186427@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0700f5c3-66a8-338a-0ba0-2231cc3bb637@suse.cz>
Date: Fri, 14 Dec 2018 22:33:42 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1812141244450.186427@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, mgorman@techsingularity.net, Michal Hocko <mhocko@kernel.org>, ying.huang@intel.com, s.priebe@profihost.ag, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, alex.williamson@redhat.com, lkp@01.org, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, zi.yan@cs.rutgers.edu, Linux-MM layout <linux-mm@kvack.org>

On 12/14/18 10:04 PM, David Rientjes wrote:
> On Wed, 12 Dec 2018, Vlastimil Babka wrote:

...

> Reclaim likely could be deterministically useful if we consider a redesign 
> of how migration sources and targets are determined in compaction.
> 
> Has anybody tried a migration scanner that isn't linearly based, rather 
> finding the highest-order free page of the same migratetype, iterating the 
> pages of its pageblock, and using this to determine whether the actual 
> migration will be worthwhile or not?

Not exactly that AFAIK, but a year ago in my series [1] patch 6 made
migration scanner 'prescan' the block of requested order before actually
trying to isolate anything for migration.

> I could imagine pageblock_skip being 
> repurposed for this as the heuristic.
> 
> Finding migration targets would be more tricky, but if we iterate the 
> pages of the pageblock for low-order free pages and find them to be mostly 
> used, that seems more appropriate than just pushing all memory to the end 
> of the zone?

Agree. That was patch 8/8 of the same series [1].

> It would be interesting to know if anybody has tried using the per-zone 
> free_area's to determine migration targets and set a bit if it should be 
> considered a migration source or a migration target.  If all pages for a 
> pageblock are not on free_areas, they are fully used.

Repurposing/adding a new pageblock bit was in my mind to help multiple
compactors not undo each other's work in the scheme where there's no
free page scanner, but I didn't implement it yet.

>>> otherwise we fail and defer because it wasn't able 
>>> to make a hugepage available.
>>
>> Note that THP fault compaction doesn't actually defer itself, which I
>> think is a weakness of the current implementation and hope that patch 3
>> in my series from yesterday [1] can address that. Because defering is
>> the general feedback mechanism that we have for suppressing compaction
>> (and thus associated reclaim) in cases it fails for any reason, not just
>> the one you mention. Instead of inspecting failure conditions in detail,
>> which would be costly, it's a simple statistical approach. And when
>> compaction is improved to fail less, defering automatically also happens
>> less.
>>
> 
> I couldn't get the link to work, unfortunately, I don't think the patch 
> series made it to LKML :/  I do see it archived for linux-mm, though, so 
> I'll take a look, thanks!

Yeah I forgot to Cc: LKML, but you were also in direct To: so you should
have received them directly. Also the abovementioned series, but that's
year ago. My fault for not returning to it after being done with the
Meltdown fun. I hope to do that soon.

[1] https://marc.info/?l=linux-mm&m=151315560308753

>> [1] https://lkml.kernel.org/r/20181211142941.20500-1-vbabka@suse.cz
>>
