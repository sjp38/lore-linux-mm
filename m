Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 062AB6B0686
	for <linux-mm@kvack.org>; Fri, 18 May 2018 16:23:53 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u13-v6so5854678oif.0
        for <linux-mm@kvack.org>; Fri, 18 May 2018 13:23:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f18-v6sor4663318oig.292.2018.05.18.13.23.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 13:23:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180518173637.GF15611@ziepe.ca>
References: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
 <20180518154945.GC15611@ziepe.ca> <0100016374267882-16b274b1-d6f6-4c13-94bb-8e78a51e9091-000000@email.amazonses.com>
 <20180518173637.GF15611@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 May 2018 13:23:50 -0700
Message-ID: <CAPcyv4i_W94iXCyOd8gSSU6kWscncz5KUqnuzZ_RdVW9UT2U3w@mail.gmail.com>
Subject: Re: [LSFMM] RDMA data corruption potential during FS writeback
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christopher Lameter <cl@linux.com>, linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>

On Fri, May 18, 2018 at 10:36 AM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
> On Fri, May 18, 2018 at 04:47:48PM +0000, Christopher Lameter wrote:
>> On Fri, 18 May 2018, Jason Gunthorpe wrote:
>>
>> > > The solution that was proposed at the meeting was that mmu notifiers can
>> > > remedy that situation by allowing callbacks to the RDMA device to ensure
>> > > that the RDMA device and the filesystem do not do concurrent writeback.
>> >
>> > This keeps coming up, and I understand why it seems appealing from the
>> > MM side, but the reality is that very little RDMA hardware supports
>> > this, and it carries with it a fairly big performance penalty so many
>> > users don't like using it.
>>
>> Ok so we have a latent data corruption issue that is not being addressed.
>>
>> > > But could we do more to prevent issues here? I think what may be useful is
>> > > to not allow the memory registrations of file back writable mappings
>> > > unless the device driver provides mmu callbacks or something like that.
>> >
>> > Why does every proposed solution to this involve crippling RDMA? Are
>> > there really no ideas no ideas to allow the FS side to accommodate
>> > this use case??
>>
>> The newcomer here is RDMA. The FS side is the mainstream use case and has
>> been there since Unix learned to do paging.
>
> Well, it has been this way for 12 years, so it isn't that new.
>
> Honestly it sounds like get_user_pages is just a broken Linux
> API??
>
> Nothing can use it to write to pages because the FS could explode -
> RDMA makes it particularly easy to trigger this due to the longer time
> windows, but presumably any get_user_pages could generate a race and
> hit this? Is that right?
>
> I am left with the impression that solving it in the FS is too
> performance costly so FS doesn't want that overheard? Was that also
> the conclusion?
>
> Could we take another crack at this during Linux Plumbers? Will the MM
> parties be there too? I'm sorry I wasn't able to attend LSFMM this
> year!

Yes, you and hch were missed, and I had to skip the last day due to a
family emergency.

Plumbers sounds good to resync on this topic, but we already have a
plan, use "break_layouts()" to coordinate a filesystem's need to move
dax blocks around relative to an active RDMA memory registration. If
you never punch a hole in the middle of your RDMA registration then
you never incur any performance penalty. Otherwise the layout break
notification is just there to tell the application "hey man, talk to
your friend that punched a hole in the middle of your mapping, but the
filesystem wants this block back now. Sorry, I'm kicking you out. Ok,
bye.".

In other words, get_user_pages_longterm() is just a short term
band-aid for RDMA until we can get that infrastructure built. We don't
need to go down any mmu-notifier rabbit holes.
