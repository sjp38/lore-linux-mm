Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE02B6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 13:57:53 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id m65-v6so31562663qkh.11
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 10:57:53 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id b80-v6si5972876qkg.25.2018.06.04.10.57.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 10:57:51 -0700 (PDT)
Subject: Re: pkeys on POWER: Access rights not reset on execve
References: <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
 <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
 <20180519202747.GK5479@ram.oc3035372033.ibm.com>
 <CALCETrVz9otkOQAxVkz6HtuMwjAeY6mMuLgFK_o0M0kbkUznwg@mail.gmail.com>
 <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
Date: Mon, 4 Jun 2018 19:57:46 +0200
MIME-Version: 1.0
In-Reply-To: <20180604140135.GA10088@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Dave Hansen <dave.hansen@intel.com>

On 06/04/2018 04:01 PM, Ram Pai wrote:
> On Mon, Jun 04, 2018 at 12:12:07PM +0200, Florian Weimer wrote:
>> On 06/03/2018 10:18 PM, Ram Pai wrote:
>>> On Mon, May 21, 2018 at 01:29:11PM +0200, Florian Weimer wrote:
>>>> On 05/20/2018 09:11 PM, Ram Pai wrote:
>>>>> Florian,
>>>>>
>>>>> 	Does the following patch fix the problem for you?  Just like x86
>>>>> 	I am enabling all keys in the UAMOR register during
>>>>> 	initialization itself. Hence any key created by any thread at
>>>>> 	any time, will get activated on all threads. So any thread
>>>>> 	can change the permission on that key. Smoke tested it
>>>>> 	with your test program.
>>>>
>>>> I think this goes in the right direction, but the AMR value after
>>>> fork is still strange:
>>>>
>>>> AMR (PID 34912): 0x0000000000000000
>>>> AMR after fork (PID 34913): 0x0000000000000000
>>>> AMR (PID 34913): 0x0000000000000000
>>>> Allocated key in subprocess (PID 34913): 2
>>>> Allocated key (PID 34912): 2
>>>> Setting AMR: 0xffffffffffffffff
>>>> New AMR value (PID 34912): 0x0fffffffffffffff
>>>> About to call execl (PID 34912) ...
>>>> AMR (PID 34912): 0x0fffffffffffffff
>>>> AMR after fork (PID 34914): 0x0000000000000003
>>>> AMR (PID 34914): 0x0000000000000003
>>>> Allocated key in subprocess (PID 34914): 2
>>>> Allocated key (PID 34912): 2
>>>> Setting AMR: 0xffffffffffffffff
>>>> New AMR value (PID 34912): 0x0fffffffffffffff
>>>>
>>>> I mean this line:
>>>>
>>>> AMR after fork (PID 34914): 0x0000000000000003
>>>>
>>>> Shouldn't it be the same as in the parent process?
>>>
>>> Fixed it. Please try this patch. If it all works to your satisfaction, I
>>> will clean it up further and send to Michael Ellermen(ppc maintainer).
>>>
>>>
>>> commit 51f4208ed5baeab1edb9b0f8b68d7144449b3527
>>> Author: Ram Pai <linuxram@us.ibm.com>
>>> Date:   Sun Jun 3 14:44:32 2018 -0500
>>>
>>>      Fix for the fork bug.
>>>      Signed-off-by: Ram Pai <linuxram@us.ibm.com>
>>
>> Is this on top of the previous patch, or a separate fix?
> 
> top of previous patch.

Thanks.  With this patch, I get this on an LPAR:

AMR (PID 1876): 0x0000000000000003
AMR after fork (PID 1877): 0x0000000000000003
AMR (PID 1877): 0x0000000000000003
Allocated key in subprocess (PID 1877): 2
Allocated key (PID 1876): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 1876): 0x0fffffffffffffff
About to call execl (PID 1876) ...
AMR (PID 1876): 0x0000000000000003
AMR after fork (PID 1878): 0x0000000000000003
AMR (PID 1878): 0x0000000000000003
Allocated key in subprocess (PID 1878): 2
Allocated key (PID 1876): 2
Setting AMR: 0xffffffffffffffff
New AMR value (PID 1876): 0x0fffffffffffffff

Test program is still this one:

<https://lists.ozlabs.org/pipermail/linuxppc-dev/2018-May/173198.html>

So the process starts out with a different AMR value for some reason. 
That could be a pre-existing bug that was just hidden by the 
reset-to-zero on fork, or it could be intentional.  But the kernel code 
does not indicate that key 63 is reserved (POWER numbers keys from the 
MSB to the LSB).

But it looks like we are finally getting somewhere. 8-)

Thanks,
Florian
