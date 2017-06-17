Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80A026B0317
	for <linux-mm@kvack.org>; Fri, 16 Jun 2017 20:25:41 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id o21so45626738qtb.13
        for <linux-mm@kvack.org>; Fri, 16 Jun 2017 17:25:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e54si3442704qtf.136.2017.06.16.17.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jun 2017 17:25:40 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
References: <20170603005413.10380-1-Liam.Howlett@Oracle.com>
 <20170605045725.GA9248@dhcp22.suse.cz>
 <20170605151541.avidrotxpoiekoy5@oracle.com>
 <20170606054917.GA1189@dhcp22.suse.cz> <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170616120755.c56d205f49d93a6e3dffb14f@linux-foundation.org>
Message-ID: <4ca8d7dd-0fa2-1aa0-b477-97f328e728ec@oracle.com>
Date: Fri, 16 Jun 2017 17:25:19 -0700
MIME-Version: 1.0
In-Reply-To: <20170616120755.c56d205f49d93a6e3dffb14f@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Liam R. Howlett" <Liam.Howlett@oracle.com>
Cc: Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On 06/16/2017 12:07 PM, Andrew Morton wrote:
> On Mon, 12 Jun 2017 21:35:17 -0400 "Liam R. Howlett" <Liam.Howlett@Oracle.com> wrote:
> 
>>>
>>>> If there's no message stating any
>>>> configuration issue, then many admins would probably think something is
>>>> seriously broken and it's not just a simple typo of K vs M.
>>>>
>>>> Even though this doesn't catch all errors, I think it's a worth while
>>>> change since this is currently a silent failure which results in a
>>>> system crash.
>>>
>>> Seriously, this warning just doesn't help in _most_ miscofigurations. It
>>> just focuses on one particular which really requires to misconfigure
>>> really badly. And there are way too many other ways to screw your system
>>> that way, yet we do not warn about many of those. So just try to step
>>> back and think whether this is something we actually do care about and
>>> if yes then try to come up with a more reasonable warning which would
>>> cover a wider range of misconfigurations.
>>
>> Understood.  Again, I appreciate all the time you have taken on my
>> patch and explaining your points.  I will look at this again as you
>> have suggested.
> 
> So do we want to drop
> mm-hugetlb-warn-the-user-when-issues-arise-on-boot-due-to-hugepages.patch?
> 
> I'd be inclined to keep it if Liam found it a bit useful - it does have
> some overhead, but half the patch is in __init code...
> 

Before sending out this patch, I asked Liam off list why he was doing it.
Was it something he just thought would be useful?  Or, was there some type
of user situation/need.  He said that he had been called in to assist on
several occasions when a system OOMed during boot.  In almost all of these
situations, the user had grossly misconfigured huge pages.  DB users want
to pre-allocate just the right amount of huge pages, but sometimes they
can be really off.  In such situations, the huge page init code just
allocates as many huge pages as it can and reports the number allocated.
There is no indication that it quit allocating because it ran out of memory.
Of course, a user could compare the number in the message to what they
requested on the command line to determine if they got all the huge pages
they requested.  The thought was that it would be useful to at least flag
this situation.  That way, the user might be able to better relate the huge
page allocation failure to the OOM.

I'm not sure if the e-mail discussion made it obvious that this is
something he has seen on several occasions.

I see Michal's point that this will only flag the situation where someone
configures huge pages very badly.  And, a more extensive look at the situation
of misconfiguring huge pages might be in order.  But, this has happened on
several occasions which led to the creation of this patch.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
