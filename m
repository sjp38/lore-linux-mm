Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 22B376B0032
	for <linux-mm@kvack.org>; Sat, 11 May 2013 10:17:32 -0400 (EDT)
Message-ID: <518E52C8.8080207@parallels.com>
Date: Sat, 11 May 2013 18:16:40 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com> <20130509141329.GC11497@suse.de> <518C5B5E.4010706@gmail.com> <20130510092255.592E1E0085@blue.fi.intel.com>
In-Reply-To: <20130510092255.592E1E0085@blue.fi.intel.com>
Content-Type: text/plain; charset=x-mac-cyrillic
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, wenchao <wenchaolinux@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com

On 05/10/2013 01:22 PM, Kirill A. Shutemov wrote:
> wenchao wrote:
>> ao? 2013-5-9 22:13, Mel Gorman a??e??:
>>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
>>>> From: Wenchao Xia <wenchaolinux@gmail.com>
>>>>
>>>>    This serial try to enable mremap syscall to cow some private memory region,
>>>> just like what fork() did. As a result, user space application would got a
>>>> mirror of those region, and it can be used as a snapshot for further processing.
>>>>
>>>
>>> What not just fork()? Even if the application was threaded it should be
>>> managable to handle fork just for processing the private memory region
>>> in question. I'm having trouble figuring out what sort of application
>>> would require an interface like this.
>>>
>>    It have some troubles: parent - child communication, sometimes
>> page copy.
>>    I'd like to snapshot qemu guest's RAM, currently solution is:
>> 1) fork()
>> 2) pipe guest RAM data from child to parent.
>> 3) parent write down the contents.
> 
> CC Pavel

Thank you!

> I wounder if you can reuse the CRIU approach for memory snapshoting.

I doubt it. First of all, we need to have task's memory in existing external process
which is not its child. With MREMAP_DUP we can't have this. And the most important
thing is that we don't need pages duplication on modification. It's the waste of
memory for our case. We just need to know the fact that the page has changed.

Wenchao, why can't you use existing KVM dirty-tracking for making mem snapshot? As
per my understanding of how KVM MMU works you can

1 turn dirty track on
2 read pages from their original places
3 pick dirty bitmap and read changed pages several times
4 freeze guest
5 repeat step 3
6 release guest

Does it work for you?

This is very very similar to how we do mem snapshot with CRIU (dirty tracking is the
soft-dirty patches from the link Kirill provided).

> http://thread.gmane.org/gmane.linux.kernel/1483158/
> 


Thanks,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
