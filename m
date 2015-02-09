Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id 24D3C6B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 12:46:08 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id a41so8292753yho.9
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 09:46:07 -0800 (PST)
Received: from remote.erley.org ([2600:3c03:e000:15::1])
        by mx.google.com with ESMTP id v10si15024653qgv.67.2015.02.09.09.46.06
        for <linux-mm@kvack.org>;
        Mon, 09 Feb 2015 09:46:06 -0800 (PST)
Message-ID: <54D8F235.7040105@erley.org>
Date: Mon, 09 Feb 2015 11:45:25 -0600
From: Pat Erley <pat-lkml@erley.org>
MIME-Version: 1.0
Subject: Re: BUG: non-zero nr_pmds on freeing mm: 1
References: <CA+icZUVTVdHc3QYD1LkWn=Xt-Zz6RcXPcjL6Xbpz0FZ6rdA5CQ@mail.gmail.com> <20150209164248.GA29522@node.dhcp.inet.fi> <CA+icZUU_xYhg1kqbrb+y71EQQWNPk0vf9V2YS4dimXBA5jTYCg@mail.gmail.com> <20150209171320.GB29522@node.dhcp.inet.fi>
In-Reply-To: <20150209171320.GB29522@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Sedat Dilek <sedat.dilek@gmail.com>
Cc: Linux-Next <linux-next@vger.kernel.org>, kirill.shutemov@linux.intel.com, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>

On 02/09/2015 11:13 AM, Kirill A. Shutemov wrote:
> On Mon, Feb 09, 2015 at 06:06:11PM +0100, Sedat Dilek wrote:
>> On Mon, Feb 9, 2015 at 5:42 PM, Kirill A. Shutemov <kirill@shutemov.name> wrote:
>>> On Sat, Feb 07, 2015 at 08:33:02AM +0100, Sedat Dilek wrote:
>>>> On Sat, Feb 7, 2015 at 6:12 AM, Pat Erley <pat-lkml@erley.org> wrote:
>>>>> I'm seeing the message in $subject on my Xen DOM0 on next-20150204 on
>>>>> x86_64.  I haven't had time to bisect it, but have seen some discussion on
>>>>> similar topics here recently.  I can trigger this pretty reliably by
>>>>> watching Netflix.  At some point (minutes to hours) into it, the netflix
>>>>> video goes black (audio keeps going, so it still thinks it's working) and
>>>>> the error appears in dmesg.  Refreshing the page gets the video going again,
>>>>> and it will continue playing for some indeterminate amount of time.
>>>>>
>>>>> Kirill, I've CC'd you as looking in the logs, you've patched a false
>>>>> positive trigger of this very recently(patch in kernel I'm running).  Am I
>>>>> actually hitting a problem, or is this another false positive case? Any
>>>>> additional details that might help?
>>>>>
>>>>> Dmesg from system attached.
>>>>
>>>> [ CC some mm folks ]
>>>>
>>>> I have seen this, too.
>>>>
>>>> root# grep "BUG: non-zero nr_pmds on freeing mm:" /var/log/kern.log | wc -l
>>>> 21
>>>>
>>>> Checking my logs: On next-20150203 and next-20150204.
>>>>
>>>> I am here not in a VM environment and cannot say what causes these messages.
>>>
>>> Sorry, my fault.
>>>
>>> The patch below should fix that.
>>>
>>>  From 11bce596e653302e41f819435912f01ca8cbc27e Mon Sep 17 00:00:00 2001
>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>> Date: Mon, 9 Feb 2015 18:34:56 +0200
>>> Subject: [PATCH] mm: fix race on pmd accounting
>>>
>>> Do not account the pmd table to the process if other thread allocated it
>>> under us.
>>>
>>> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>>> Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
>>
>> Still building with the fix...
>>
>> Please feel free to add Pat as a reporter.
>>
>>       Reported-by: Pat Erley <pat-lkml@erley.org>
>>
>> Is that fixing...?
>>
>> commit daa1b0f29cdccae269123e7f8ae0348dbafdc3a7
>> "mm: account pmd page tables to the process"
>>
>> If yes, please add a Fixes-tag [2]...
>>
>>       Fixes: daa1b0f29cdc ("mm: account pmd page tables to the process")
>>
>> I will re-test with LTP/mmap and report.
>
> The commit is not in Linus tree, so the sha1-id is goinging to change.
>

I won't be able to test for at least 6 hours (more likely closer to 8 as 
I have to get home, boot the machine, apply patch, compile, reboot, and 
wait).  So not likely I'll be able to get a 'tested-by' on this one 
without holding up the whole flow of the patch.

Thanks for the prompt fix Kirill!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
