Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 930516B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 10:53:17 -0400 (EDT)
Received: from mail-pv0-f169.google.com (mail-pv0-f169.google.com [74.125.83.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id o8FEr7Kb026515
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 07:53:14 -0700
Received: by pvc30 with SMTP id 30so99426pvc.14
        for <linux-mm@kvack.org>; Wed, 15 Sep 2010 07:53:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100916001232.0c496b02@lilo>
References: <20100915104855.41de3ebf@lilo> <4C90A6C7.9050607@redhat.com> <20100916001232.0c496b02@lilo>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 15 Sep 2010 07:52:39 -0700
Message-ID: <AANLkTikkAs5jUPhsq5=_Efv-MbbfCNmT10rcV6VUc54D@mail.gmail.com>
Subject: Re: [RFC][PATCH] Cross Memory Attach
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 15, 2010 at 7:42 AM, Christopher Yeoh <cyeoh@au1.ibm.com> wrote=
:
> On Wed, 15 Sep 2010 12:58:15 +0200
> Avi Kivity <avi@redhat.com> wrote:
>
>> =A0 On 09/15/2010 03:18 AM, Christopher Yeoh wrote:
>> > The basic idea behind cross memory attach is to allow MPI programs
>> > doing intra-node communication to do a single copy of the message
>> > rather than a double copy of the message via shared memory.
>>
>> If the host has a dma engine (many modern ones do) you can reduce
>> this to zero copies (at least, zero processor copies).
>
> Yes, this interface doesn't really support that. I've tried to keep
> things really simple here, but I see potential for increasing
> level/complexity of support with diminishing returns:

I think keeping things simple is a good goal. The vmfd() approach
might be worth looking into, but your patch certainly is pretty simple
as-is.

That said, it's also buggy. You can't just get a task and then do

  down_read(task->mm->mmap_sem)

on it. Not even if you have a refcount. The mm may well go away. You
need to do the same thing "get_task_mm()" does, ie look up the mm
under task_lock, and get a reference to it. You already get the
task-lock for permission testing, so it looks like doing it there
would likely work out.

> 3. ability to map part of another process's address space directly into
> =A0 the current one. Would have setup/tear down overhead, but this would
> =A0 be useful specifically for reduction operations where we don't even
> =A0 need to really copy the data once at all, but use it directly in
> =A0 arithmetic/logical operations on the receiver.

Don't even think about this. If you want to map another tasks memory,
use shared memory. The shared memory code knows about that. The races
for anything else are crazy.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
