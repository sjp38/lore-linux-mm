Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 979EA6B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 01:11:49 -0400 (EDT)
Received: by mail-qe0-f44.google.com with SMTP id s14so2287840qeb.31
        for <linux-mm@kvack.org>; Thu, 09 May 2013 22:11:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <518C5B5E.4010706@gmail.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com>
	<20130509141329.GC11497@suse.de>
	<518C5B5E.4010706@gmail.com>
Date: Fri, 10 May 2013 07:11:48 +0200
Message-ID: <CAJSP0QULp5c3tWwZ4ipWn6wS3YWauE07Bmd8nzjp8CJhWaD_oQ@mail.gmail.com>
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
From: Stefan Hajnoczi <stefanha@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wenchao <wenchaolinux@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, walken@google.com, Alexander Viro <viro@zeniv.linux.org.uk>, kirill.shutemov@linux.intel.com, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Anthony Liguori <anthony@codemonkey.ws>

On Fri, May 10, 2013 at 4:28 AM, wenchao <wenchaolinux@gmail.com> wrote:
> =E4=BA=8E 2013-5-9 22:13, Mel Gorman =E5=86=99=E9=81=93:
>
>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com wrote:
>>>
>>> From: Wenchao Xia <wenchaolinux@gmail.com>
>>>
>>>    This serial try to enable mremap syscall to cow some private memory
>>> region,
>>> just like what fork() did. As a result, user space application would go=
t
>>> a
>>> mirror of those region, and it can be used as a snapshot for further
>>> processing.
>>>
>>
>> What not just fork()? Even if the application was threaded it should be
>> managable to handle fork just for processing the private memory region
>> in question. I'm having trouble figuring out what sort of application
>> would require an interface like this.
>>
>   It have some troubles: parent - child communication, sometimes
> page copy.
>   I'd like to snapshot qemu guest's RAM, currently solution is:
> 1) fork()
> 2) pipe guest RAM data from child to parent.
> 3) parent write down the contents.
>
>   To avoid complex communication for data control, and file content
> protecting, So let parent instead of child handling the data with
> a pipe, but this brings additional copy(). I think an explicit API
> cow mapping an memory region inside one process, could avoid it,
> and faster and cow less pages, also make user space code nicer.

A new Linux-specific API is not portable and not available on existing
hosts.  Since QEMU supports non-Linux host operating systems the
fork() approach is preferable.

If you're worried about the memory copy - which should be benchmarked
- then vmsplice(2) can be used in the child process and splice(2) can
be used in the parent.  It probably doesn't help though since QEMU
scans RAM pages to find all-zero pages before sending them over the
socket, and at that point the memory copy might not make much
difference.

Perhaps other applications can use this new flag better, but for QEMU
I think fork()'s portability is more important than the convenience of
accessing the CoW pages in the same process.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
