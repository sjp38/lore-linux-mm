Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 98E526B000E
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 03:26:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so437375edi.20
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:26:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g4-v6si774503edq.282.2018.07.26.00.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 00:26:23 -0700 (PDT)
Date: Thu, 26 Jul 2018 09:26:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-ID: <20180726072622.GS28386@dhcp22.suse.cz>
References: <bug-200651-27@https.bugzilla.kernel.org/>
 <20180725125239.b591e4df270145f9064fe2c5@linux-foundation.org>
 <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cd474b37-263f-b186-2024-507a9a4e12ae@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, gnikolov@icdsoft.com, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

On Thu 26-07-18 09:18:57, Vlastimil Babka wrote:
> On 07/25/2018 09:52 PM, Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > On Wed, 25 Jul 2018 11:42:57 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:
> > 
> >> https://bugzilla.kernel.org/show_bug.cgi?id=200651
> >>
> >>             Bug ID: 200651
> >>            Summary: cgroups iptables-restor: vmalloc: allocation failure
> > 
> > Thanks.  Please do note the above request.
> > 
> >>            Product: Memory Management
> >>            Version: 2.5
> >>     Kernel Version: 4.14
> >>           Hardware: All
> >>                 OS: Linux
> >>               Tree: Mainline
> >>             Status: NEW
> >>           Severity: normal
> >>           Priority: P1
> >>          Component: Other
> >>           Assignee: akpm@linux-foundation.org
> >>           Reporter: gnikolov@icdsoft.com
> >>         Regression: No
> >>
> >> Created attachment 277505
> >>   --> https://bugzilla.kernel.org/attachment.cgi?id=277505&action=edit
> >> iptables save
> >>
> >> After creating large number of cgroups and under memory pressure, iptables
> >> command fails with following error:
> >>
> >> "iptables-restor: vmalloc: allocation failure, allocated 3047424 of 3465216
> >> bytes, mode:0x14010c0(GFP_KERNEL|__GFP_NORETRY), nodemask=(null)"
> 
> This is likely the kvmalloc() in xt_alloc_table_info(). Between 4.13 and
> 4.17 it shouldn't use __GFP_NORETRY, but looks like commit 0537250fdc6c
> ("netfilter: x_tables: make allocation less aggressive") was backported
> to 4.14. Removing __GFP_NORETRY might help here, but bring back other
> issues. Less than 4MB is not that much though, maybe find some "sane"
> limit and use __GFP_NORETRY only above that?

I have seen the same report via http://lkml.kernel.org/r/df6f501c-8546-1f55-40b1-7e3a8f54d872@icdsoft.com
and the reported confirmed that kvmalloc is not a real culprit
http://lkml.kernel.org/r/d99a9598-808a-6968-4131-c3949b752004@icdsoft.com
 
> > I'm not sure what the problem is here, apart from iptables being
> > over-optimistic about vmalloc()'s abilities.
> > 
> > Are cgroups having any impact on this, or is it simply vmalloc arena
> > fragmentation, and the iptables code should use some data structure
> > more sophisticated than a massive array?
> > 
> > Maybe all that ccgroup metadata is contributing to the arena
> > fragmentation, but that allocations will be small and the two systems
> > should be able to live alongside, by being realistic about vmalloc.
> > 
> >> System which is used to reproduce the bug is with 2 vcpus and 2GB of ram, but
> >> it happens on more powerfull systems.
> >>
> >> Steps to reproduce:
> >>
> >> mkdir /cgroup
> >> mount cgroup -t cgroup -omemory,pids,blkio,cpuacct /cgroup
> >> for a in `seq 1 1000`; do for b in `seq 1 4` ; do mkdir -p
> >> "/cgroup/user/$a/$b"; done; done
> >>
> >> Then in separate consoles
> >>
> >> cat /dev/vda > /dev/null
> >> ./test
> >> ./test
> >> i=0;while sleep 0 ; do iptables-restore < iptables.save ; i=$(($i+1)); echo $i;
> >> done
> >>
> >> Here is the source of "test" program and attached iptables.save. It happens
> >> also with smaller iptables.save file.
> >>
> >> #include <stdio.h>
> >> #include <stdlib.h>
> >>
> >> int main(void) {
> >>
> >>     srand(time(NULL));
> >>     int i = 0, j = 0, randnum=0;
> >>     int arr[6] = { 3072, 7168, 15360 , 31744, 64512, 130048}; 
> >>     while(1) {
> >>
> >>         for (i = 0; i < 6 ; i++) {
> >>
> >>             int *ptr = (int*) malloc(arr[i] * 93);  
> >>
> >>             for(j = 0 ; j < arr[i] * 93 / sizeof(int); j++) {
> >>                 *(ptr+j) = j+1;
> >>             }
> >>
> >>             free(ptr);
> >>         }
> >>     }       
> >> }
> >>
> > 

-- 
Michal Hocko
SUSE Labs
