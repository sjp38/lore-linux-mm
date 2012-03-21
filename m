Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 3412D6B004A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 09:16:11 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so1218199bkw.14
        for <linux-mm@kvack.org>; Wed, 21 Mar 2012 06:16:09 -0700 (PDT)
Message-ID: <4F69D496.2040509@openvz.org>
Date: Wed, 21 Mar 2012 17:16:06 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
References: <20120321065140.13852.52315.stgit@zurg> <20120321100602.GA5522@barrios>
In-Reply-To: <20120321100602.GA5522@barrios>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

Minchan Kim wrote:
> Hi Konstantin,
>
> It seems to be nice clean up to me and you are a volunteer we have been wanted
> for a long time. Thanks!
> I am one of people who really want to expand vm_flags to 64 bit but when KOSAKI
> tried it, Linus said his concerning, I guess you already saw that.
>
> He want to tidy vm_flags's usage up rather than expanding it.
> Without the discussion about that, just expanding vm_flags would make us use
> it up easily so that we might need more space.

Strictly speaking, my pachset does not expands vm_flags, it just prepares to this.
Anyway vm_flags_t looks better than hard-coded "unsigned long" and messy type-casts around it.

>
> Readahead flags are good candidate to move into another space and arch-specific flags, I guess.
> Another candidate I think of is THP flag. It's just for only anonymous vma now
> (But I am not sure we have a plan to support it for file-backed pages in future)
> so we can move it to anon_vma or somewhere.
> I think other guys might find more somethings
>
> The point is that at least, we have to discuss about clean up current vm_flags's
> use cases before expanding it unconditionally.

Seems like we can easily remove VM_EXECUTABLE
(count in mm->num_exe_file_vmas amount of vmas with vma->vm_file == mm->exe_file
instead of vmas with VM_EXECUTABLE bit)

And probably VM_CAN_NONLINEAR...

>
> On Wed, Mar 21, 2012 at 10:56:07AM +0400, Konstantin Khlebnikov wrote:
>> There is good old tradition: every year somebody submit patches for extending
>> vma->vm_flags upto 64-bits, because there no free bits left on 32-bit systems.
>>
>> previous attempts:
>> https://lkml.org/lkml/2011/4/12/24	(KOSAKI Motohiro)
>> https://lkml.org/lkml/2010/4/27/23	(Benjamin Herrenschmidt)
>> https://lkml.org/lkml/2009/10/1/202	(Hugh Dickins)
>>
>> Here already exist special type for this: vm_flags_t, but not all code uses it.
>> So, before switching vm_flags_t from unsinged long to u64 we must spread
>> vm_flags_t everywhere and fix all possible type-casting problems.
>>
>> There is no functional changes in this patch set,
>> it only prepares code for vma->vm_flags converting.
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
