Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 320956B0031
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 07:07:00 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id cm18so11558396qab.4
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 04:06:59 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id s1si46049665qed.72.2013.12.31.04.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 31 Dec 2013 04:06:59 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so12676848pad.2
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 04:06:57 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [RFC PATCH V1 0/6] mm: add a new option MREMAP_DUP to mmrep syscall
From: Xiao Guangrong <xiaoguangrong.eric@gmail.com>
In-Reply-To: <20131230202342.GA7973@amt.cnet>
Date: Tue, 31 Dec 2013 20:06:51 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <943AC3BD-C4EB-4B6C-BE34-AB921938AAF0@linux.vnet.ibm.com>
References: <1368093011-4867-1-git-send-email-wenchaolinux@gmail.com> <20130509141329.GC11497@suse.de> <518C5B5E.4010706@gmail.com> <CAJSP0QULp5c3tWwZ4ipWn6wS3YWauE07Bmd8nzjp8CJhWaD_oQ@mail.gmail.com> <52AFE828.3010500@linux.vnet.ibm.com> <20131230202342.GA7973@amt.cnet>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Stefan Hajnoczi <stefanha@gmail.com>, wenchao <wenchaolinux@gmail.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, walken@google.com, Alexander Viro <viro@zeniv.linux.org.uk>, kirill.shutemov@linux.intel.com, Anthony Liguori <anthony@codemonkey.ws>, KVM <kvm@vger.kernel.org>


On Dec 31, 2013, at 4:23 AM, Marcelo Tosatti <mtosatti@redhat.com> =
wrote:

> On Tue, Dec 17, 2013 at 01:59:04PM +0800, Xiao Guangrong wrote:
>>=20
>> CCed KVM guys.
>>=20
>> On 05/10/2013 01:11 PM, Stefan Hajnoczi wrote:
>>> On Fri, May 10, 2013 at 4:28 AM, wenchao <wenchaolinux@gmail.com> =
wrote:
>>>> =E4=BA=8E 2013-5-9 22:13, Mel Gorman =E5=86=99=E9=81=93:
>>>>=20
>>>>> On Thu, May 09, 2013 at 05:50:05PM +0800, wenchaolinux@gmail.com =
wrote:
>>>>>>=20
>>>>>> From: Wenchao Xia <wenchaolinux@gmail.com>
>>>>>>=20
>>>>>>  This serial try to enable mremap syscall to cow some private =
memory
>>>>>> region,
>>>>>> just like what fork() did. As a result, user space application =
would got
>>>>>> a
>>>>>> mirror of those region, and it can be used as a snapshot for =
further
>>>>>> processing.
>>>>>>=20
>>>>>=20
>>>>> What not just fork()? Even if the application was threaded it =
should be
>>>>> managable to handle fork just for processing the private memory =
region
>>>>> in question. I'm having trouble figuring out what sort of =
application
>>>>> would require an interface like this.
>>>>>=20
>>>> It have some troubles: parent - child communication, sometimes
>>>> page copy.
>>>> I'd like to snapshot qemu guest's RAM, currently solution is:
>>>> 1) fork()
>>>> 2) pipe guest RAM data from child to parent.
>>>> 3) parent write down the contents.
>>>>=20
>>>> To avoid complex communication for data control, and file content
>>>> protecting, So let parent instead of child handling the data with
>>>> a pipe, but this brings additional copy(). I think an explicit API
>>>> cow mapping an memory region inside one process, could avoid it,
>>>> and faster and cow less pages, also make user space code nicer.
>>>=20
>>> A new Linux-specific API is not portable and not available on =
existing
>>> hosts.  Since QEMU supports non-Linux host operating systems the
>>> fork() approach is preferable.
>>>=20
>>> If you're worried about the memory copy - which should be =
benchmarked
>>> - then vmsplice(2) can be used in the child process and splice(2) =
can
>>> be used in the parent.  It probably doesn't help though since QEMU
>>> scans RAM pages to find all-zero pages before sending them over the
>>> socket, and at that point the memory copy might not make much
>>> difference.
>>>=20
>>> Perhaps other applications can use this new flag better, but for =
QEMU
>>> I think fork()'s portability is more important than the convenience =
of
>>> accessing the CoW pages in the same process.
>>=20
>> Yup, I agree with you that the new syscall sometimes is not a good =
solution.
>>=20
>> Currently, we're working on live-update[1] that will be enabled on =
Qemu firstly,
>> this feature let the guest run on the new Qemu binary smoothly =
without
>> restart, it's good for us to do security-update.
>>=20
>> In this case, we need to move the guest memory on old qemu instance =
to the
>> new one, fork() can not help because we need to exec() a new =
instance, after
>> that all memory mapping will be destroyed.
>>=20
>> We tried to enable SPLICE_F_MOVE[2] for vmsplice() to move the memory =
without
>> memory-copy but the performance isn't so good as we expected: it's =
due to
>> some limitations: the page-size, lock, message-size limitation on =
pipe, etc.
>> Of course, we will continue to improve this, but wenchao's patch =
seems a new
>> direction for us.
>>=20
>> To coordinate with your fork() approach, maybe we can introduce a new =
flag
>> for VMA, something like: VM_KEEP_ONEXEC, to tell exec() to do not =
destroy
>> this VMA. How about this or you guy have new idea? Really appreciate =
for your
>> suggestion.
>>=20
>> [1] http://marc.info/?l=3Dqemu-devel&m=3D138597598700844&w=3D2
>> [2] https://lkml.org/lkml/2013/10/25/285
>=20
> Hi,
>=20

Hi Marcelo,


> What is the purpose of snapshotting guest RAM here, in the context of
> local migration?

RAM-shapshotting and local-migration are on the different ways.
Why i asked for your guy=E2=80=99s suggestion here is  beacuse i  =
thought
they need do a same thing that moves memory from one process
to another in a efficient way. Your idea? :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
