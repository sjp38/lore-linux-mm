Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C9B556B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 22:46:09 -0400 (EDT)
Message-ID: <49B9C8E0.5080500@cs.columbia.edu>
Date: Thu, 12 Mar 2009 22:45:52 -0400
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>	<1234285547.30155.6.camel@nimitz>	<20090211141434.dfa1d079.akpm@linux-foundation.org>	<1234462282.30155.171.camel@nimitz> <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
In-Reply-To: <20090213152836.0fbbfa7d.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, mingo@elte.hu, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, hpa@zytor.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

Hi,

Just got back from 3 weeks with practically no internet, and I see
that I missed a big party !

Trying to catch up with what's been said so far --

"An app really has to know whether it can reliably checkpoint+restart."

It was suggested (Dave) to either have an "uncheckpointable" flag at containter,
or process, or resource level. Another suggestion (Serge, Alexey) was to let
the app try to checkpoint and return an error.

For what it's worth, I vote for the latter. Have the checkpoint code always
return an error if the checkpoint cannot be taken. If checkpoint succeeds
then the app/user is guaranteed that restart will succeed (if it is given
the right starting conditions, e.g. correct file system view).

To figure out what/when went wrong, the c/r code can indicate the _reason_
to the failure (e.g. output to the console, or other means) so that the
frustrated user/developer/app can report it. I also think it's cleaner as
it keep c/r consideration within the c/r subsystem and not scattered around
different locations in the kernel.


Andrew Morton wrote:
> On Thu, 12 Feb 2009 10:11:22 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
>> ...
>>
>>> - In bullet-point form, what features are missing, and should be added?
>>  * support for more architectures than i386
>>  * file descriptors:
>>   * sockets (network, AF_UNIX, etc...)
>>   * devices files
>>   * shmfs, hugetlbfs
>>   * epoll
>>   * unlinked files
>>  * Filesystem state
>>   * contents of files
>>   * mount tree for individual processes
>>  * flock
>>  * threads and sessions
>>  * CPU and NUMA affinity
>>  * sys_remap_file_pages()
>>
>> This is a very minimal list that is surely incomplete and sure to grow.
> 
> That's a worry.
> 
>>> For extra marks:
>>>
>>> - Will any of this involve non-trivial serialisation of kernel
>>>   objects?  If so, that's getting into the
>>>   unacceptably-expensive-to-maintain space, I suspect.
>> We have some structures that are certainly tied to the kernel-internal
>> ones.  However, we are certainly *not* simply writing kernel structures
>> to userspace.  We could do that with /dev/mem.  We are carefully pulling
>> out the minimal bits of information from the kernel structures that we
>> *need* to recreate the function of the structure at restart.  There is a
>> maintenance burden here but, so far, that burden is almost entirely in
>> checkpoint/*.c.  We intend to test this functionality thoroughly to
>> ensure that we don't regress once we have integrated it.
> 
> I guess my question can be approximately simplified to: "will it end up
> looking like openvz"?  (I don't believe that we know of any other way
> of implementing this?)
> 
> Because if it does then that's a concern, because my assessment when I
> looked at that code (a number of years ago) was that having code of
> that nature in mainline would be pretty costly to us, and rather
> unwelcome.

I originally implemented c/r for linux as as kernel module, without
requiring any changes from the kernel. (Doing the namespaces as a kernel
module was much harder). For more details, see:
	https://www.ncl.cs.columbia.edu/research/migrate

The current set of patches is the beginning of a re-implementation
based on that work and other lessons learned, as well as feedback and
collaboration with other players.

I am confident that the the vast majority of the code will end up as a
separate "subsystem", and that relatively few changes will be required
from the existing kernel.

> The broadest form of the question is "will we end up regretting having
> done this".

I bet that once this works for a critical mass of apps/users - we will
never regret having done this. (We may regret - and fix - having done
specific part this way or another).

> 
> If we can arrange for the implementation to sit quietly over in a
> corner with a team of people maintaining it and not screwing up other
> people's work then I guess we'd be OK - if it breaks then the breakage
> is localised.

In my experience, there is very little code of the c/r that affects
other parts of the kernel, it's mostly isolated. So I believe this
will be the case.

> 
> And it's not just a matter of "does the diffstat only affect a single
> subdirectory".  We also should watch out for the imposition of new
> rules which kernel code must follow.  "you can't do that, because we
> can't serialise it", or something.
> 
> Similar to the way in which perfectly correct and normal kernel
> sometimes has to be changed because it unexpectedly upsets the -rt
> patch.
> 
> Do you expect that any restrictions of this type will be imposed?
> 

That an excellent point. Again, judging from past experience -
it is possible (but not always pretty) to implement c/r as a kernel
module, without requiring _any_ kernel changes. I can't think of
any such restrictions, but we'll certainly have to keep our eyes
open.

Oren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
