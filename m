Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C8776B06C5
	for <linux-mm@kvack.org>; Fri, 18 May 2018 23:51:40 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id l95-v6so7477943otl.17
        for <linux-mm@kvack.org>; Fri, 18 May 2018 20:51:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b17-v6sor4940198otk.330.2018.05.18.20.51.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 20:51:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180519032400.GA12517@ziepe.ca>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
 <20180518154945.GC15611@ziepe.ca> <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
 <20180518173637.GF15611@ziepe.ca> <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com>
 <c8861cbb-5b2e-d6e2-9c89-66c5c92181e6@nvidia.com> <20180519032400.GA12517@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 20:51:38 -0700
Message-ID: <CAPcyv4iGmUg108O-s1h6_YxmjQgMcV_pFpciObHh3zJkTOKfKA@mail.gmail.com>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: John Hubbard <jhubbard@nvidia.com>, Christopher Lameter <cl@linux.com>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Fri, May 18, 2018 at 8:24 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Fri, May 18, 2018 at 07:33:41PM -0700, John Hubbard wrote:
>> On 05/18/2018 01:23 PM, Dan Williams wrote:
>> > On Fri, May 18, 2018 at 10:36 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>> >> On Fri, May 18, 2018 at 04:47:48PM +0000, Christopher Lameter wrote:
>> >>> On Fri, 18 May 2018, Jason Gunthorpe wrote:
>> >>>
>> >>>
>> >>> The newcomer here is RDMA. The FS side is the mainstream use case and has
>> >>> been there since Unix learned to do paging.
>> >>
>> >> Well, it has been this way for 12 years, so it isn't that new.
>> >>
>> >> Honestly it sounds like get_user_pages is just a broken Linux
>> >> API??
>> >>
>> >> Nothing can use it to write to pages because the FS could explode -
>> >> RDMA makes it particularly easy to trigger this due to the longer time
>> >> windows, but presumably any get_user_pages could generate a race and
>> >> hit this? Is that right?
>>
>> +1, and I am now super-interested in this conversation, because
>> after tracking down a kernel BUG to this classic mistaken pattern:
>>
>>     get_user_pages (on file-backed memory from ext4)
>>     ...do some DMA
>>     set_pages_dirty
>>     put_page(s)
>
> Ummm, RDMA has done essentially that since 2005, since when did it
> become wrong? Do you have some references? Is there some alternative?
>
> See __ib_umem_release
>
>> ...there is (rarely!) a backtrace from ext4, that disavows ownership of
>> any such pages.
>
> Yes, I've seen that oops with RDMA, apparently isn't actually that
> rare if you tweak things just right.
>
> I thought it was an obscure ext4 bug :(
>
>> Because the obvious "fix" in device driver land is to use a dedicated
>> buffer for DMA, and copy to the filesystem buffer, and of course I will
>> get *killed* if I propose such a performance-killing approach. But a
>> core kernel fix really is starting to sound attractive.
>
> Yeah, killed is right. That idea totally cripples RDMA.
>
> What is the point of get_user_pages FOLL_WRITE if you can't write to
> and dirty the pages!?!
>

You're oversimplifying the problem, here are the details:

https://www.spinics.net/lists/linux-mm/msg142700.html
