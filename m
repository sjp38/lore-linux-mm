Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 1D1456B0036
	for <linux-mm@kvack.org>; Sun, 12 May 2013 22:41:00 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id y19so3350653dan.14
        for <linux-mm@kvack.org>; Sun, 12 May 2013 19:40:59 -0700 (PDT)
Message-ID: <519052AA.7080401@gmail.com>
Date: Mon, 13 May 2013 10:40:42 +0800
From: wenchao <wenchaolinux@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com> <20130509141329.GC11497@suse.de> <518C5B5E.4010706@gmail.com> <20130510092255.592E1E0085@blue.fi.intel.com> <518E52C8.8080207@parallels.com>
In-Reply-To: <518E52C8.8080207@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, walken@google.com, viro@zeniv.linux.org.uk, xiaoguangrong@linux.vnet.ibm.com, anthony@codemonkey.ws, stefanha@gmail.com

ao? 2013-5-11 22:16, Pavel Emelyanov a??e??:
> On 05/10/2013 01:22 PM, Kirill A. Shutemov wrote:
>> wenchao wrote:
>>> D'D?D? 2013-5-9 22:13, Mel Gorman DuD?D(C)D1D?DGBP:
>>>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
>>>>> From: Wenchao Xia <wenchaolinux@gmail.com>
>>>>>
>>>>>     This serial try to enable mremap syscall to cow some private memory region,
>>>>> just like what fork() did. As a result, user space application would got a
>>>>> mirror of those region, and it can be used as a snapshot for further processing.
>>>>>
>>>>
>>>> What not just fork()? Even if the application was threaded it should be
>>>> managable to handle fork just for processing the private memory region
>>>> in question. I'm having trouble figuring out what sort of application
>>>> would require an interface like this.
>>>>
>>>     It have some troubles: parent - child communication, sometimes
>>> page copy.
>>>     I'd like to snapshot qemu guest's RAM, currently solution is:
>>> 1) fork()
>>> 2) pipe guest RAM data from child to parent.
>>> 3) parent write down the contents.
>>
>> CC Pavel
>
> Thank you!
>
   Sorry I forgot CC you, I have viewed the contents on CRIU website 
before patching. :>

>> I wounder if you can reuse the CRIU approach for memory snapshoting.
>
> I doubt it. First of all, we need to have task's memory in existing external process
> which is not its child. With MREMAP_DUP we can't have this. And the most important
> thing is that we don't need pages duplication on modification. It's the waste of
> memory for our case. We just need to know the fact that the page has changed.
>
> Wenchao, why can't you use existing KVM dirty-tracking for making mem snapshot? As
> per my understanding of how KVM MMU works you can
>
> 1 turn dirty track on
> 2 read pages from their original places
> 3 pick dirty bitmap and read changed pages several times
> 4 freeze guest
> 5 repeat step 3
> 6 release guest
>
> Does it work for you?
>
> This is very very similar to how we do mem snapshot with CRIU (dirty tracking is the
> soft-dirty patches from the link Kirill provided).
>
   It is different. Actually this approach is already used in qemu as
migration, also as a work around for snapshot. Dirty tracking actually
made a mirror of latest memory region, but for snapshot we need not
sync up the two mirror, and syncing up require frequently changed pages 
being saved several times. This brings extra trouble for following
actions, and also require transfer speed > memory changing speed.
   Looking at the block layer's function, for example, LVM2. Most of them
provided an API to do a snapshot by COW, so the idea comes: why not add
an same one for memory? Then the APIs are full for user. Later in
discuss Fork() seems one way to do it, with disadvantage that additional
process comes, so I hope to improve it.
   Comparation:
        Dirty tracking   VS   cow
CPU       higher              minimum
Memory    less                higher
I/O       higher              minimum

   Since dirty tracking keeps sync with latest memory data, so it is
more ideal for migration than snapshot, but in principle migration
is a bit different with snapshot. Further thinking, dirty tracking
could work together with cow, to form an incremental snapshot chain,
reducing the pages need to be written, but not related to this patch.

Base->delta->delta

>> http://thread.gmane.org/gmane.linux.kernel/1483158/
>>
>
>
> Thanks,
> Pavel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
