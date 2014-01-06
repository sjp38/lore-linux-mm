Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id B2FED6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 02:42:05 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so18198691pbc.13
        for <linux-mm@kvack.org>; Sun, 05 Jan 2014 23:42:04 -0800 (PST)
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com. [202.81.31.141])
        by mx.google.com with ESMTPS id qu5si54023640pbc.180.2014.01.05.23.42.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 05 Jan 2014 23:42:03 -0800 (PST)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Mon, 6 Jan 2014 17:42:00 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id E1D832CE802D
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 18:41:57 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s067NEpn56623202
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 18:23:14 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s067fu27030735
	for <linux-mm@kvack.org>; Mon, 6 Jan 2014 18:41:57 +1100
Message-ID: <52CA5E40.6040603@linux.vnet.ibm.com>
Date: Mon, 06 Jan 2014 15:41:52 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com> <20130509141329.GC11497@suse.de> <518C5B5E.4010706@gmail.com> <CAJSP0QULp5c3tWwZ4ipWn6wS3YWauE07Bmd8nzjp8CJhWaD_oQ@mail.gmail.com> <52AFE828.3010500@linux.vnet.ibm.com> <20131230202342.GA7973@amt.cnet> <943AC3BD-C4EB-4B6C-BE34-AB921938AAF0@linux.vnet.ibm.com> <20131231185328.GA22414@amt.cnet>
In-Reply-To: <20131231185328.GA22414@amt.cnet>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Stefan Hajnoczi <stefanha@gmail.com>, wenchao <wenchaolinux@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, walken@google.com, Alexander Viro <viro@zeniv.linux.org.uk>, kirill.shutemov@linux.intel.com, Anthony Liguori <anthony@codemonkey.ws>, KVM <kvm@vger.kernel.org>

On 01/01/2014 02:53 AM, Marcelo Tosatti wrote:
> On Tue, Dec 31, 2013 at 08:06:51PM +0800, Xiao Guangrong wrote:
>>
>> On Dec 31, 2013, at 4:23 AM, Marcelo Tosatti <mtosatti@redhat.com> wrote:
>>
>>> On Tue, Dec 17, 2013 at 01:59:04PM +0800, Xiao Guangrong wrote:
>>>>
>>>> CCed KVM guys.
>>>>
>>>> On 05/10/2013 01:11 PM, Stefan Hajnoczi wrote:
>>>>> On Fri, May 10, 2013 at 4:28 AM, wenchao <wenchaolinux@gmail.com> wrote:
>>>>>> ao? 2013-5-9 22:13, Mel Gorman a??e??:
>>>>>>
>>>>>>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
>>>>>>>>
>>>>>>>> From: Wenchao Xia <wenchaolinux@gmail.com>
>>>>>>>>
>>>>>>>>  This serial try to enable mremap syscall to cow some private memory
>>>>>>>> region,
>>>>>>>> just like what fork() did. As a result, user space application would got
>>>>>>>> a
>>>>>>>> mirror of those region, and it can be used as a snapshot for further
>>>>>>>> processing.
>>>>>>>>
>>>>>>>
>>>>>>> What not just fork()? Even if the application was threaded it should be
>>>>>>> managable to handle fork just for processing the private memory region
>>>>>>> in question. I'm having trouble figuring out what sort of application
>>>>>>> would require an interface like this.
>>>>>>>
>>>>>> It have some troubles: parent - child communication, sometimes
>>>>>> page copy.
>>>>>> I'd like to snapshot qemu guest's RAM, currently solution is:
>>>>>> 1) fork()
>>>>>> 2) pipe guest RAM data from child to parent.
>>>>>> 3) parent write down the contents.
>>>>>>
>>>>>> To avoid complex communication for data control, and file content
>>>>>> protecting, So let parent instead of child handling the data with
>>>>>> a pipe, but this brings additional copy(). I think an explicit API
>>>>>> cow mapping an memory region inside one process, could avoid it,
>>>>>> and faster and cow less pages, also make user space code nicer.
>>>>>
>>>>> A new Linux-specific API is not portable and not available on existing
>>>>> hosts.  Since QEMU supports non-Linux host operating systems the
>>>>> fork() approach is preferable.
>>>>>
>>>>> If you're worried about the memory copy - which should be benchmarked
>>>>> - then vmsplice(2) can be used in the child process and splice(2) can
>>>>> be used in the parent.  It probably doesn't help though since QEMU
>>>>> scans RAM pages to find all-zero pages before sending them over the
>>>>> socket, and at that point the memory copy might not make much
>>>>> difference.
>>>>>
>>>>> Perhaps other applications can use this new flag better, but for QEMU
>>>>> I think fork()'s portability is more important than the convenience of
>>>>> accessing the CoW pages in the same process.
>>>>
>>>> Yup, I agree with you that the new syscall sometimes is not a good solution.
>>>>
>>>> Currently, we're working on live-update[1] that will be enabled on Qemu firstly,
>>>> this feature let the guest run on the new Qemu binary smoothly without
>>>> restart, it's good for us to do security-update.
>>>>
>>>> In this case, we need to move the guest memory on old qemu instance to the
>>>> new one, fork() can not help because we need to exec() a new instance, after
>>>> that all memory mapping will be destroyed.
>>>>
>>>> We tried to enable SPLICE_F_MOVE[2] for vmsplice() to move the memory without
>>>> memory-copy but the performance isn't so good as we expected: it's due to
>>>> some limitations: the page-size, lock, message-size limitation on pipe, etc.
>>>> Of course, we will continue to improve this, but wenchao's patch seems a new
>>>> direction for us.
>>>>
>>>> To coordinate with your fork() approach, maybe we can introduce a new flag
>>>> for VMA, something like: VM_KEEP_ONEXEC, to tell exec() to do not destroy
>>>> this VMA. How about this or you guy have new idea? Really appreciate for your
>>>> suggestion.
>>>>
>>>> [1] http://marc.info/?l=qemu-devel&m=138597598700844&w=2
>>>> [2] https://lkml.org/lkml/2013/10/25/285
>>>
>>> Hi,
>>>
>>
>> Hi Marcelo,
>>
>>
>>> What is the purpose of snapshotting guest RAM here, in the context of
>>> local migration?
>>
>> RAM-shapshotting and local-migration are on the different ways.
>> Why i asked for your guya??s suggestion here is  beacuse i  thought
>> they need do a same thing that moves memory from one process
>> to another in a efficient way. Your idea? :)
> 
> Another possibility is to use memory that is not anonymous for guest
> RAM, such as hugetlbfs or tmpfs. 
> 
> IIRC ksm and thp have limitations wrt tmpfs.

Yes, KSM and THP are what we're concerning about.

> 
> Still curious about RAM snapshotting.

Wen Chao, could you please tell it more?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
