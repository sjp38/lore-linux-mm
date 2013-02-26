Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 64B9C6B0005
	for <linux-mm@kvack.org>; Tue, 26 Feb 2013 15:54:23 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20130213031056.GA32135@marvin.atrad.com.au>
	<alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
	<20130213042552.GC32135@marvin.atrad.com.au>
	<511BADEA.3070403@linux.vnet.ibm.com>
	<20130226063916.GM16712@marvin.atrad.com.au>
	<512CD435.30704@linux.vnet.ibm.com>
Date: Tue, 26 Feb 2013 12:54:08 -0800
In-Reply-To: <512CD435.30704@linux.vnet.ibm.com> (Dave Hansen's message of
	"Tue, 26 Feb 2013 07:26:45 -0800")
Message-ID: <87d2vmkd8v.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: OOM triggered with plenty of memory free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Jonathan Woithe <jwoithe@atrad.com.au>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

Dave Hansen <dave@linux.vnet.ibm.com> writes:

> On 02/25/2013 10:39 PM, Jonathan Woithe wrote:
>> On Wed, Feb 13, 2013 at 07:14:50AM -0800, Dave Hansen wrote:
>>> David's analysis looks spot-on.  The only other thing I'll add is that
>>> it just looks weird that all three kmalloc() caches are so _even_:
>>>
>>>>> kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
>>>>> kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
>>>>> kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0
>>>
>>> It's almost like something goes and does 3 allocations in series and
>>> leaks them all.
> ...
>> Given these observations it seems that 2.6.35.11 was leaking memory,
>> probably as a result of a bug in the fork() execution path.  At this stage
>> kmemleak is not showing the same recurring problem under 3.7.9.
>
> Your kmemleak data shows that the leaks are always from either 'struct
> cred', or 'struct pid'.  Those are _generally_ tied to tasks, but you
> only have a couple thousand task_structs.
>
> My suspicion would be that something is allocating those structures, but
> a refcount got leaked somewhere.  2.6.35.11 is about the same era that
> this code went in:
>
> http://lists.linux-foundation.org/pipermail/containers/2010-June/024720.html
>
> and it deals with both creds and 'struct pid'.  Eric, do you recall any
> bugs like this that got fixed along the way?
>
> I do think it's fairly safe to assume that 3.7.9 doesn't have this
> bug.

I remember that at one point there was a very subtle leak of I think
struct pid.  That leak was not associated with the socket code but
something else.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
