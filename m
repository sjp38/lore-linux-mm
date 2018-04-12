Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF7A76B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 15:18:41 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 25-v6so3581006oir.13
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 12:18:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 61-v6sor2031001otd.150.2018.04.12.12.18.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 12 Apr 2018 12:18:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <13801e2a-c44d-e940-f872-890a0612a483@nvidia.com>
References: <20180412153941.170849-1-jannh@google.com> <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
 <CAKgNAkgcJ2kCTff0=7=D3zPFwpJt-9EM8yis6-4qDjfvvb8ukw@mail.gmail.com>
 <CAG48ez2NtCr8+HqnKJTFBcLW+kCKUa=2pz=7HD9p9u1p-MfJqw@mail.gmail.com> <13801e2a-c44d-e940-f872-890a0612a483@nvidia.com>
From: Jann Horn <jannh@google.com>
Date: Thu, 12 Apr 2018 21:18:19 +0200
Message-ID: <CAG48ez085cASur3kZTRkdJY20dFZ4Yqc1KVOHxnCAn58_NtW8w@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Michael Kerrisk-manpages <mtk.manpages@gmail.com>, linux-man <linux-man@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu, Apr 12, 2018 at 8:59 PM, John Hubbard <jhubbard@nvidia.com> wrote:
> On 04/12/2018 11:49 AM, Jann Horn wrote:
>> On Thu, Apr 12, 2018 at 8:37 PM, Michael Kerrisk (man-pages)
>> <mtk.manpages@gmail.com> wrote:
>>> Hi John,
>>>
>>> On 12 April 2018 at 20:33, John Hubbard <jhubbard@nvidia.com> wrote:
>>>> On 04/12/2018 08:39 AM, Jann Horn wrote:
>>>>> Clarify that MAP_FIXED is appropriate if the specified address range has
>>>>> been reserved using an existing mapping, but shouldn't be used otherwise.
>>>>>
>>>>> Signed-off-by: Jann Horn <jannh@google.com>
>>>>> ---
>>>>>  man2/mmap.2 | 19 +++++++++++--------
>>>>>  1 file changed, 11 insertions(+), 8 deletions(-)
>>>>>
>>>>> diff --git a/man2/mmap.2 b/man2/mmap.2
>> [...]
>>>>>  .IP
>>>>>  For example, suppose that thread A looks through
>>>>> @@ -284,13 +285,15 @@ and the PAM libraries
>>>>>  .UR http://www.linux-pam.org
>>>>>  .UE .
>>>>>  .IP
>>>>> -Newer kernels
>>>>> -(Linux 4.17 and later) have a
>>>>> +For cases in which the specified memory region has not been reserved using an
>>>>> +existing mapping, newer kernels (Linux 4.17 and later) provide an option
>>>>>  .B MAP_FIXED_NOREPLACE
>>>>> -option that avoids the corruption problem; if available,
>>>>> -.B MAP_FIXED_NOREPLACE
>>>>> -should be preferred over
>>>>> -.BR MAP_FIXED .
>>>>> +that should be used instead; older kernels require the caller to use
>>>>> +.I addr
>>>>> +as a hint (without
>>>>> +.BR MAP_FIXED )
>>>>
>>>> Here, I got lost: the sentence suddenly jumps into explaining non-MAP_FIXED
>>>> behavior, in the MAP_FIXED section. Maybe if you break up the sentence, and
>>>> possibly omit non-MAP_FIXED discussion, it will help.
>>>
>>> Hmmm -- true. That piece could be a little clearer.
>>
>> How about something like this?
>>
>>               For  cases in which MAP_FIXED can not be used because
>> the specified memory
>>               region has not been reserved using an existing mapping,
>> newer kernels
>>               (Linux  4.17  and  later)  provide  an  option
>> MAP_FIXED_NOREPLACE  that
>>               should  be  used  instead. Older kernels require the
>>               caller to use addr as a hint and take appropriate action if
>>               the kernel places the new mapping at a different address.
>>
>> John, Michael, what do you think?
>
>
> I'm still having difficulty with it, because this is in the MAP_FIXED section,
> but I think you're documenting the behavior that you get if you do *not*
> specify MAP_FIXED, right? Also, the hint behavior is true of both older and
> new kernels...

The manpage patch you and mhocko wrote mentioned MAP_FIXED_NOREPLACE
in the MAP_FIXED section - I was trying to avoid undoing a change you
had just explicitly made.

> So, if that's your intent (you want to sort of document by contrast to what
> would happen if this option were not used), then how about something like this:
>
>
> Without the MAP_FIXED option, the kernel would treat addr as a hint, rather
> than a requirement, and the caller would need to take appropriate action
> if the kernel placed the mapping at a different address. (For example,
> munmap and try again.)

I'd be fine with removing the paragraph. As you rightly pointed out,
it doesn't really describe MAP_FIXED.
