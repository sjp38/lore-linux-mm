Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3D21382F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 17:19:59 -0500 (EST)
Received: by igvi2 with SMTP id i2so99895615igv.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 14:19:59 -0800 (PST)
Received: from out01.mta.xmission.com (out01.mta.xmission.com. [166.70.13.231])
        by mx.google.com with ESMTPS id yt6si3944783igb.75.2015.11.04.14.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 04 Nov 2015 14:19:58 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1446574204-15567-1-git-send-email-dcashman@android.com>
	<20151103160410.34bbebc805c17d2f41150a19@linux-foundation.org>
	<87k2pyppfk.fsf@x220.int.ebiederm.org>
	<20151103173156.9ca17f52.akpm@linux-foundation.org>
	<563A5D0D.9030109@android.com>
Date: Wed, 04 Nov 2015 16:10:43 -0600
In-Reply-To: <563A5D0D.9030109@android.com> (Daniel Cashman's message of "Wed,
	4 Nov 2015 11:31:25 -0800")
Message-ID: <87r3k5mn4s.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH v2 1/2] mm: mmap: Add new /proc tunable for mmap_base ASLR.
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Cashman <dcashman@android.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux@arm.linux.org.uk, keescook@chromium.org, mingo@kernel.org, linux-arm-kernel@lists.infradead.org, corbet@lwn.net, dzickus@redhat.com, xypron.glpk@gmx.de, jpoimboe@redhat.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, mgorman@suse.de, tglx@linutronix.de, rientjes@google.com, linux-mm@kvack.org, linux-doc@vger.kernel.org, salyzyn@android.com, jeffv@google.com, nnk@google.com, dcashman <dcashman@google.com>

Daniel Cashman <dcashman@android.com> writes:

> On 11/3/15 5:31 PM, Andrew Morton wrote:
>> On Tue, 03 Nov 2015 18:40:31 -0600 ebiederm@xmission.com (Eric W. Biederman) wrote:
>> 
>>> Andrew Morton <akpm@linux-foundation.org> writes:
>>>
>>>> On Tue,  3 Nov 2015 10:10:03 -0800 Daniel Cashman <dcashman@android.com> wrote:
>>>>
>>>>> ASLR currently only uses 8 bits to generate the random offset for the
>>>>> mmap base address on 32 bit architectures. This value was chosen to
>>>>> prevent a poorly chosen value from dividing the address space in such
>>>>> a way as to prevent large allocations. This may not be an issue on all
>>>>> platforms. Allow the specification of a minimum number of bits so that
>>>>> platforms desiring greater ASLR protection may determine where to place
>>>>> the trade-off.
>>>>
>>>> Can we please include a very good description of the motivation for this
>>>> change?  What is inadequate about the current code, what value does the
>>>> enhancement have to our users, what real-world problems are being solved,
>>>> etc.
>>>>
>>>> Because all we have at present is "greater ASLR protection", which doesn't
>>>> really tell anyone anything.
>>>
>>> The description seemed clear to me.
>>>
>>> More random bits, more entropy, more work needed to brute force.
>>>
>>> 8 bits only requires 256 tries (or a 1 in 256) chance to brute force
>>> something.
>> 
>> Of course, but that's not really very useful.
>> 
>>> We have seen in the last couple of months on Android how only having 8 bits
>>> doesn't help much.
>> 
>> Now THAT is important.  What happened here and how well does the
>> proposed fix improve things?  How much longer will a brute-force attack
>> take to succeed, with a particular set of kernel parameters?  Is the
>> new duration considered to be sufficiently long and if not, are there
>> alternative fixes we should be looking at?
>> 
>> Stuff like this.
>> 
>>> Each additional bit doubles the protection (and unfortunately also
>>> increases fragmentation of the userspace address space).
>> 
>> OK, so the benefit comes with a cost and people who are configuring
>> systems (and the people who are reviewing this patchset!) need to
>> understand the tradeoffs.  Please.
>
> The direct motivation here was in response to the libstagefright
> vulnerabilities that affected Android, specifically to information
> provided by Google's project zero at:
>
> http://googleprojectzero.blogspot.com/2015/09/stagefrightened.html
>
> The attack there specifically used the limited randomness used in
> generating the mmap base address as part of a brute-force-based exploit.
>  In this particular case, the attack was against the mediaserver process
> on Android, which was limited to respawning every 5 seconds, giving the
> attacker an average expected success rate of defeating the mmap ASLR
> after over 10 minutes (128 tries at 5 seconds each).  With change to the
> maximum proposed value of 16 bits, this would change to over 45 hours
> (32768 tries), which would make the user of such a system much more
> likely to notice such an attack.
>
> I understand the desire for this clarification, and will happily try to
> improve the explanation for this change, especially so that those
> considering use of this option understand the tradeoffs, but I also view
> this as one particular hardening change which is a component of making
> attacks such as these harder, rather than the only solution.  As for the
> clarification itself, where would you like it?  I could include a cover
> letter for this patch-set, elaborate more in the commit message itself,
> add more to the Kconfig help description, or some combination of the above.

Unless I am mistaken this there is no cross over between different
processes of this randomization.  Would it make sense to have this as
an rlimit so that if you have processes on the system that are affected
by the tradeoff differently this setting can be changed per process?

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
