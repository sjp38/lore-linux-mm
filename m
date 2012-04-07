Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 04E6E6B004A
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 01:11:42 -0400 (EDT)
Received: by bkwq16 with SMTP id q16so3142898bkw.14
        for <linux-mm@kvack.org>; Fri, 06 Apr 2012 22:11:41 -0700 (PDT)
Message-ID: <4F7FCC8A.6050707@openvz.org>
Date: Sat, 07 Apr 2012 09:11:38 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm: account VMA before forced-COW via /proc/pid/mem
References: <20120402153631.5101.44091.stgit@zurg> <20120403143752.GA5150@redhat.com> <4F7C1B67.6030300@openvz.org> <20120404154148.GA7105@redhat.com> <4F7D5859.5050106@openvz.org> <alpine.LSU.2.00.1204062104090.4297@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204062104090.4297@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Roland Dreier <roland@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hugh Dickins wrote:
> On Thu, 5 Apr 2012, Konstantin Khlebnikov wrote:
>> Oleg Nesterov wrote:
>>> On 04/04, Konstantin Khlebnikov wrote:
>>>> Oleg Nesterov wrote:
>>>>> On 04/02, Konstantin Khlebnikov wrote:
>>>>>>
>>>>>> Currently kernel does not account read-only private mappings into
>>>>>> memory commitment.
>>>>>> But these mappings can be force-COW-ed in get_user_pages().
>>>>>
>>>>> Heh. tail -n3 Documentation/vm/overcommit-accounting
>>>>> may be you should update it then.
>>>>
>>>> I just wonder how fragile this accounting...
>>>
>>> I meant, this patch could also remove this "TODO" from the docs.
>>
>> Actually I dug into this code for killing VM_ACCOUNT vma flag.
>> Currently we cannot do this only because asymmetry in mprotect_fixup():
>> it account vma on read-only ->  writable conversion, but keep on backward
>> operation.
>> Probably we can kill this asymmetry, and after that we can recognize
>> accountable vma
>> by its others flags state, so we don't need special VM_ACCOUNT for this.
>
> (I believe the VM_ACCOUNT flag will need to stay.)
>
> But this is just a quick note to say that I'm not ignoring you: I have
> a strong interest in this, but only now found time to look through the
> thread and ponder, and I'm not yet ready to decide.
>
> I've long detested that behaviour of GUP write,force, and my strong
> preference would be not to layer more strangeness upon strangeness,
> but limit the damage by making GUP write,force fail in that case,
> instead of inserting a PageAnon page into a VM_SHARED mapping.
>
> I think it's unlikely that it will cause a regression in real life
> (it already fails if you did not open the mmap'ed file for writing),
> but it would be a user-visible change in behaviour, and I've research
> to do before arriving at a conclusion.

Agree, but this stuff is very weak. Even if sysctl vm.overcommit_memory=2,
probably we should fixup accounting in /proc/pid/mem only for this case,
because vm.overcommit_memory=2 supposed to protect against overcommit, but it does not.

>
> Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
