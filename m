Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD7E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 14:08:15 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id r2-v6so6830386ybb.4
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 11:08:15 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o1-v6si2156962ywi.42.2018.09.14.11.08.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 11:08:14 -0700 (PDT)
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
 <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
 <82d2b35c-272a-ad02-692f-2c109aacdfb6@oracle.com>
 <8569dabb-4930-aa20-6249-72457e2df51e@intel.com>
 <51145ccb-fc0d-0281-9757-fb8a5112ec24@oracle.com>
 <c72fea44-59f3-b106-8311-b5eae2d254e7@intel.com>
 <addeaadc-5ab2-f0c9-2194-dd100ae90f3a@oracle.com>
 <aaca3180-7510-c008-3e12-8bbe92344ef4@intel.com>
 <94ee0b6c-4663-0705-d4a8-c50342f6b483@oracle.com>
 <CAG48ez1YhHKTDHZoH2tEFaLk4LcCSw5G60=+KpGRaMQxvw1qLw@mail.gmail.com>
 <20180914062132.GI20287@dhcp22.suse.cz>
 <CAG48ez2RSn-EQkf-ahs41tOKpzt23JMGYZxUtWMRPe8c5jAq-A@mail.gmail.com>
From: Prakash Sangappa <prakash.sangappa@oracle.com>
Message-ID: <a1834be4-0f8e-9d07-1013-7477d3a5e6be@oracle.com>
Date: Fri, 14 Sep 2018 11:07:53 -0700
MIME-Version: 1.0
In-Reply-To: <CAG48ez2RSn-EQkf-ahs41tOKpzt23JMGYZxUtWMRPe8c5jAq-A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, n-horiguchi@ah.jp.nec.com, Ulrich Drepper <drepper@gmail.com>, David Rientjes <rientjes@google.com>, Horiguchi Naoya <nao.horiguchi@gmail.com>, steven.sistare@oracle.com



On 9/14/18 5:49 AM, Jann Horn wrote:
> On Fri, Sep 14, 2018 at 8:21 AM Michal Hocko <mhocko@kernel.org> wrote:
>> On Fri 14-09-18 03:33:28, Jann Horn wrote:
>>> On Wed, Sep 12, 2018 at 10:43 PM prakash.sangappa
>>> <prakash.sangappa@oracle.com> wrote:
>>>> On 05/09/2018 04:31 PM, Dave Hansen wrote:
>>>>> On 05/07/2018 06:16 PM, prakash.sangappa wrote:
>>>>>> It will be /proc/<pid>/numa_vamaps. Yes, the behavior will be
>>>>>> different with respect to seeking. Output will still be text and
>>>>>> the format will be same.
>>>>>>
>>>>>> I want to get feedback on this approach.
>>>>> I think it would be really great if you can write down a list of the
>>>>> things you actually want to accomplish.  Dare I say: you need a
>>>>> requirements list.
>>>>>
>>>>> The numa_vamaps approach continues down the path of an ever-growing list
>>>>> of highly-specialized /proc/<pid> files.  I don't think that is
>>>>> sustainable, even if it has been our trajectory for many years.
>>>>>
>>>>> Pagemap wasn't exactly a shining example of us getting new ABIs right,
>>>>> but it sounds like something along those is what we need.
>>>> Just sent out a V2 patch.  This patch simplifies the file content. It
>>>> only provides VA range to numa node id information.
>>>>
>>>> The requirement is basically observability for performance analysis.
>>>>
>>>> - Need to be able to determine VA range to numa node id information.
>>>>     Which also gives an idea of which range has memory allocated.
>>>>
>>>> - The proc file /proc/<pid>/numa_vamaps is in text so it is easy to
>>>>     directly view.
>>>>
>>>> The V2 patch supports seeking to a particular process VA from where
>>>> the application could read the VA to  numa node id information.
>>>>
>>>> Also added the 'PTRACE_MODE_READ_REALCREDS' check when opening the
>>>> file /proc file as was indicated by Michal Hacko
>>> procfs files should use PTRACE_MODE_*_FSCREDS, not PTRACE_MODE_*_REALCREDS.
>> Out of my curiosity, what is the semantic difference? At least
>> kernel_move_pages uses PTRACE_MODE_READ_REALCREDS. Is this a bug?
> No, that's fine. REALCREDS basically means "look at the caller's real
> UID for the access check", while FSCREDS means "look at the caller's
> filesystem UID". The ptrace access check has historically been using
> the real UID, which is sorta weird, but normally works fine. Given
> that this is documented, I didn't see any reason to change it for most
> things that do ptrace access checks, even if the EUID would IMO be
> more appropriate. But things that capture caller credentials at points
> like open() really shouldn't look at the real UID; instead, they
> should use the filesystem UID (which in practice is basically the same
> as the EUID).
>
> So in short, it depends on the interface you're coming through: Direct
> syscalls use REALCREDS, things that go through the VFS layer use
> FSCREDS.

So in this case can the REALCREDS check be done in the read() system call
when reading the /proc file instead of the open call?
