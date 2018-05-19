Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42E916B06C0
	for <linux-mm@kvack.org>; Fri, 18 May 2018 22:34:15 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id c20-v6so8800278qkm.13
        for <linux-mm@kvack.org>; Fri, 18 May 2018 19:34:15 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id p1-v6si2084607qkl.18.2018.05.18.19.34.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 19:34:14 -0700 (PDT)
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
 <20180518154945.GC15611@ziepe.ca>
 <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
 <20180518173637.GF15611@ziepe.ca>
 <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com>
Date: Fri, 18 May 2018 19:33:41 -0700
MIME-Version: 1.0
In-Reply-To: <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christopher Lameter <cl@linux.com>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On 05/18/2018 01:23 PM, Dan Williams wrote:
> On Fri, May 18, 2018 at 10:36 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>> On Fri, May 18, 2018 at 04:47:48PM +0000, Christopher Lameter wrote:
>>> On Fri, 18 May 2018, Jason Gunthorpe wrote:
>>>
---8<---------------------------------
>>>
>>> The newcomer here is RDMA. The FS side is the mainstream use case and has
>>> been there since Unix learned to do paging.
>>
>> Well, it has been this way for 12 years, so it isn't that new.
>>
>> Honestly it sounds like get_user_pages is just a broken Linux
>> API??
>>
>> Nothing can use it to write to pages because the FS could explode -
>> RDMA makes it particularly easy to trigger this due to the longer time
>> windows, but presumably any get_user_pages could generate a race and
>> hit this? Is that right?

+1, and I am now super-interested in this conversation, because
after tracking down a kernel BUG to this classic mistaken pattern:

    get_user_pages (on file-backed memory from ext4)
    ...do some DMA
    set_pages_dirty
    put_page(s)

...there is (rarely!) a backtrace from ext4, that disavows ownership of
any such pages. It happens rarely enough that people have come to believe
that the pattern is OK, from what I can tell. But some new, cutting edge
systems with zillions of threads and lots of memory are able to expose the
problem.

Anyway, I've been dividing my time between trying to prove exactly 
which FS action is disconnecting the page from ext4 in this particular
bug (even though it's lately becoming well-documented that the design itself
is not correct), and casting about for the most proper place to fix this. 

Because the obvious "fix" in device driver land is to use a dedicated
buffer for DMA, and copy to the filesystem buffer, and of course I will
get *killed* if I propose such a performance-killing approach. But a
core kernel fix really is starting to sound attractive.

>>
>> I am left with the impression that solving it in the FS is too
>> performance costly so FS doesn't want that overheard? Was that also
>> the conclusion?
>>
>> Could we take another crack at this during Linux Plumbers? Will the MM
>> parties be there too? I'm sorry I wasn't able to attend LSFMM this
>> year!
> 
> Yes, you and hch were missed, and I had to skip the last day due to a
> family emergency.
> 
> Plumbers sounds good to resync on this topic, but we already have a
> plan, use "break_layouts()" to coordinate a filesystem's need to move
> dax blocks around relative to an active RDMA memory registration. If
> you never punch a hole in the middle of your RDMA registration then
> you never incur any performance penalty. Otherwise the layout break
> notification is just there to tell the application "hey man, talk to
> your friend that punched a hole in the middle of your mapping, but the
> filesystem wants this block back now. Sorry, I'm kicking you out. Ok,
> bye.".
> 
> In other words, get_user_pages_longterm() is just a short term
> band-aid for RDMA until we can get that infrastructure built. We don't
> need to go down any mmu-notifier rabbit holes.
> 

git grep claims that break_layouts is so far an XFS-only feature, though. 
Were there plans to fix this for all filesystems?


thanks,
-- 
John Hubbard
NVIDIA
