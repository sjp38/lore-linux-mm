Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6314F6B000C
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 14:59:27 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id l16-v6so3223412ybe.11
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:59:27 -0700 (PDT)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id w6si1910175qtc.196.2018.04.12.11.59.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 11:59:26 -0700 (PDT)
Subject: Re: [PATCH] mmap.2: MAP_FIXED is okay if the address range has been
 reserved
References: <20180412153941.170849-1-jannh@google.com>
 <b617740b-fd07-e248-2ba0-9e99b0240594@nvidia.com>
 <CAKgNAkgcJ2kCTff0=7=D3zPFwpJt-9EM8yis6-4qDjfvvb8ukw@mail.gmail.com>
 <CAG48ez2NtCr8+HqnKJTFBcLW+kCKUa=2pz=7HD9p9u1p-MfJqw@mail.gmail.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <13801e2a-c44d-e940-f872-890a0612a483@nvidia.com>
Date: Thu, 12 Apr 2018 11:59:24 -0700
MIME-Version: 1.0
In-Reply-To: <CAG48ez2NtCr8+HqnKJTFBcLW+kCKUa=2pz=7HD9p9u1p-MfJqw@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 04/12/2018 11:49 AM, Jann Horn wrote:
> On Thu, Apr 12, 2018 at 8:37 PM, Michael Kerrisk (man-pages)
> <mtk.manpages@gmail.com> wrote:
>> Hi John,
>>
>> On 12 April 2018 at 20:33, John Hubbard <jhubbard@nvidia.com> wrote:
>>> On 04/12/2018 08:39 AM, Jann Horn wrote:
>>>> Clarify that MAP_FIXED is appropriate if the specified address range has
>>>> been reserved using an existing mapping, but shouldn't be used otherwise.
>>>>
>>>> Signed-off-by: Jann Horn <jannh@google.com>
>>>> ---
>>>>  man2/mmap.2 | 19 +++++++++++--------
>>>>  1 file changed, 11 insertions(+), 8 deletions(-)
>>>>
>>>> diff --git a/man2/mmap.2 b/man2/mmap.2
> [...]
>>>>  .IP
>>>>  For example, suppose that thread A looks through
>>>> @@ -284,13 +285,15 @@ and the PAM libraries
>>>>  .UR http://www.linux-pam.org
>>>>  .UE .
>>>>  .IP
>>>> -Newer kernels
>>>> -(Linux 4.17 and later) have a
>>>> +For cases in which the specified memory region has not been reserved using an
>>>> +existing mapping, newer kernels (Linux 4.17 and later) provide an option
>>>>  .B MAP_FIXED_NOREPLACE
>>>> -option that avoids the corruption problem; if available,
>>>> -.B MAP_FIXED_NOREPLACE
>>>> -should be preferred over
>>>> -.BR MAP_FIXED .
>>>> +that should be used instead; older kernels require the caller to use
>>>> +.I addr
>>>> +as a hint (without
>>>> +.BR MAP_FIXED )
>>>
>>> Here, I got lost: the sentence suddenly jumps into explaining non-MAP_FIXED
>>> behavior, in the MAP_FIXED section. Maybe if you break up the sentence, and
>>> possibly omit non-MAP_FIXED discussion, it will help.
>>
>> Hmmm -- true. That piece could be a little clearer.
> 
> How about something like this?
> 
>               For  cases in which MAP_FIXED can not be used because
> the specified memory
>               region has not been reserved using an existing mapping,
> newer kernels
>               (Linux  4.17  and  later)  provide  an  option
> MAP_FIXED_NOREPLACE  that
>               should  be  used  instead. Older kernels require the
>               caller to use addr as a hint and take appropriate action if
>               the kernel places the new mapping at a different address.
> 
> John, Michael, what do you think?


I'm still having difficulty with it, because this is in the MAP_FIXED section,
but I think you're documenting the behavior that you get if you do *not*
specify MAP_FIXED, right? Also, the hint behavior is true of both older and 
new kernels...

So, if that's your intent (you want to sort of document by contrast to what 
would happen if this option were not used), then how about something like this:


Without the MAP_FIXED option, the kernel would treat addr as a hint, rather
than a requirement, and the caller would need to take appropriate action
if the kernel placed the mapping at a different address. (For example,
munmap and try again.)


thanks,
-- 
John Hubbard
NVIDIA
