Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 96C826B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 00:59:18 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id rd3so4039233pab.27
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 21:59:18 -0800 (PST)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id v7si10805468pbi.188.2013.12.16.21.59.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 21:59:17 -0800 (PST)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 17 Dec 2013 11:29:12 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6B6191258051
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:30:22 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBH5x5Fs46727232
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:29:05 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBH5x7Ol020616
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:29:08 +0530
Message-ID: <52AFE828.3010500@linux.vnet.ibm.com>
Date: Tue, 17 Dec 2013 13:59:04 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com> <20130509141329.GC11497@suse.de>	<518C5B5E.4010706@gmail.com> <CAJSP0QULp5c3tWwZ4ipWn6wS3YWauE07Bmd8nzjp8CJhWaD_oQ@mail.gmail.com>
In-Reply-To: <CAJSP0QULp5c3tWwZ4ipWn6wS3YWauE07Bmd8nzjp8CJhWaD_oQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Hajnoczi <stefanha@gmail.com>, wenchao <wenchaolinux@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, walken@google.com, Alexander Viro <viro@zeniv.linux.org.uk>, kirill.shutemov@linux.intel.com, Anthony Liguori <anthony@codemonkey.ws>, KVM <kvm@vger.kernel.org>


CCed KVM guys.

On 05/10/2013 01:11 PM, Stefan Hajnoczi wrote:
> On Fri, May 10, 2013 at 4:28 AM, wenchao <wenchaolinux@gmail.com> wrote:
>> ao? 2013-5-9 22:13, Mel Gorman a??e??:
>>
>>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
>>>>
>>>> From: Wenchao Xia <wenchaolinux@gmail.com>
>>>>
>>>>    This serial try to enable mremap syscall to cow some private memory
>>>> region,
>>>> just like what fork() did. As a result, user space application would got
>>>> a
>>>> mirror of those region, and it can be used as a snapshot for further
>>>> processing.
>>>>
>>>
>>> What not just fork()? Even if the application was threaded it should be
>>> managable to handle fork just for processing the private memory region
>>> in question. I'm having trouble figuring out what sort of application
>>> would require an interface like this.
>>>
>>   It have some troubles: parent - child communication, sometimes
>> page copy.
>>   I'd like to snapshot qemu guest's RAM, currently solution is:
>> 1) fork()
>> 2) pipe guest RAM data from child to parent.
>> 3) parent write down the contents.
>>
>>   To avoid complex communication for data control, and file content
>> protecting, So let parent instead of child handling the data with
>> a pipe, but this brings additional copy(). I think an explicit API
>> cow mapping an memory region inside one process, could avoid it,
>> and faster and cow less pages, also make user space code nicer.
> 
> A new Linux-specific API is not portable and not available on existing
> hosts.  Since QEMU supports non-Linux host operating systems the
> fork() approach is preferable.
> 
> If you're worried about the memory copy - which should be benchmarked
> - then vmsplice(2) can be used in the child process and splice(2) can
> be used in the parent.  It probably doesn't help though since QEMU
> scans RAM pages to find all-zero pages before sending them over the
> socket, and at that point the memory copy might not make much
> difference.
> 
> Perhaps other applications can use this new flag better, but for QEMU
> I think fork()'s portability is more important than the convenience of
> accessing the CoW pages in the same process.

Yup, I agree with you that the new syscall sometimes is not a good solution.

Currently, we're working on live-update[1] that will be enabled on Qemu firstly,
this feature let the guest run on the new Qemu binary smoothly without
restart, it's good for us to do security-update.

In this case, we need to move the guest memory on old qemu instance to the
new one, fork() can not help because we need to exec() a new instance, after
that all memory mapping will be destroyed.

We tried to enable SPLICE_F_MOVE[2] for vmsplice() to move the memory without
memory-copy but the performance isn't so good as we expected: it's due to
some limitations: the page-size, lock, message-size limitation on pipe, etc.
Of course, we will continue to improve this, but wenchao's patch seems a new
direction for us.

To coordinate with your fork() approach, maybe we can introduce a new flag
for VMA, something like: VM_KEEP_ONEXEC, to tell exec() to do not destroy
this VMA. How about this or you guy have new idea? Really appreciate for your
suggestion.

[1] http://marc.info/?l=qemu-devel&m=138597598700844&w=2
[2] https://lkml.org/lkml/2013/10/25/285


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
