Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BC806B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 12:32:53 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y8so11036415pgq.12
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 09:32:53 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id 132si24113171pge.141.2018.11.14.09.32.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Nov 2018 09:32:51 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Nov 2018 09:32:50 -0800
From: isaacm@codeaurora.org
Subject: Re: [PATCH] mm/usercopy: Use memory range to be accessed for
 wraparound check
In-Reply-To: <7C54170F-DE66-47E0-9C0D-7D1A97DCD339@oracle.com>
References: <1542156686-12253-1-git-send-email-isaacm@codeaurora.org>
 <FFE931C2-DE41-4AD8-866B-FD37C1493590@oracle.com>
 <5dcd06a0f84a4824bb9bab2b437e190d@AcuMS.aculab.com>
 <7C54170F-DE66-47E0-9C0D-7D1A97DCD339@oracle.com>
Message-ID: <50baa4900e55b523f18eea2759f8efae@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: David Laight <David.Laight@aculab.com>, Kees Cook <keescook@chromium.org>, crecklin@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, psodagud@codeaurora.org, tsoni@codeaurora.org, stable@vger.kernel.org

On 2018-11-14 03:46, William Kucharski wrote:
>> On Nov 14, 2018, at 4:09 AM, David Laight <David.Laight@ACULAB.COM> 
>> wrote:
>> 
>> From: William Kucharski
>>> Sent: 14 November 2018 10:35
>>> 
>>>> On Nov 13, 2018, at 5:51 PM, Isaac J. Manjarres 
>>>> <isaacm@codeaurora.org> wrote:
>>>> 
>>>> diff --git a/mm/usercopy.c b/mm/usercopy.c
>>>> index 852eb4e..0293645 100644
>>>> --- a/mm/usercopy.c
>>>> +++ b/mm/usercopy.c
>>>> @@ -151,7 +151,7 @@ static inline void check_bogus_address(const 
>>>> unsigned long ptr, unsigned long n,
>>>> 				       bool to_user)
>>>> {
>>>> 	/* Reject if object wraps past end of memory. */
>>>> -	if (ptr + n < ptr)
>>>> +	if (ptr + (n - 1) < ptr)
>>>> 		usercopy_abort("wrapped address", NULL, to_user, 0, ptr + n);
>>> 
>>> I'm being paranoid, but is it possible this routine could ever be 
>>> passed "n" set to zero?
>>> 
>>> If so, it will erroneously abort indicating a wrapped address as (n - 
>>> 1) wraps to ULONG_MAX.
>>> 
>>> Easily fixed via:
>>> 
>>> 	if ((n != 0) && (ptr + (n - 1) < ptr))
>> 
>> Ugg... you don't want a double test.
>> 
>> I'd guess that a length of zero is likely, but a usercopy that 
>> includes
>> the highest address is going to be invalid because it is a kernel 
>> address
>> (on most archs, and probably illegal on others).
>> What you really want to do is add 'ptr + len' and check the carry 
>> flag.
> 
> The extra test is only a few extra instructions, but I understand the
> concern. (Though I don't
> know how you'd access the carry flag from C in a machine-independent
> way. Also, for the
> calculation to be correct you still need to check 'ptr + (len - 1)'
> for the wrap.)
> 
> You could also theoretically call gcc's __builtin_uadd_overflow() if
> you want to get carried away.
> 
> As I mentioned, I was just being paranoid, but the passed zero length
> issue stood out to me.
> 
>     William Kucharski

Hi William,

Thank you and David for your feedback. The check_bogus_address() routine 
is only invoked from one place in the kernel, which is 
__check_object_size(). Before invoking check_bogus_address, 
__check_object_size ensures that n is non-zero, so it is not possible to 
call this routine with n being 0. Therefore, we shouldn't run into the 
scenario you described. Also, in the case where we are copying a page's 
contents into a kernel space buffer and will not have that buffer 
interacting with userspace at all, this change to that check should 
still be valid, correct?

Thanks,
Isaac Manjarres
