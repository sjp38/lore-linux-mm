Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9197B6B0087
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:58:47 -0400 (EDT)
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
References: <m1oct739xu.fsf@fess.ebiederm.org>
	<1243893048-17031-4-git-send-email-ebiederm@xmission.com>
	<84144f020906012216n715a04d0ha492abc12175816@mail.gmail.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 01 Jun 2009 23:51:56 -0700
In-Reply-To: <84144f020906012216n715a04d0ha492abc12175816@mail.gmail.com> (Pekka Enberg's message of "Tue\, 2 Jun 2009 08\:16\:44 +0300")
Message-ID: <m1ws7vyvoz.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@cs.helsinki.fi> writes:

> Hi Eric,
>
> On Tue, Jun 2, 2009 at 12:50 AM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> +#ifdef CONFIG_FILE_HOTPLUG
>> +
>> +static bool file_in_use(struct file *file)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 struct task_struct *leader, *task;
>> + =C2=A0 =C2=A0 =C2=A0 bool in_use =3D false;
>> + =C2=A0 =C2=A0 =C2=A0 int i;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 rcu_read_lock();
>> + =C2=A0 =C2=A0 =C2=A0 do_each_thread(leader, task) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i < MAX=
_FILE_HOTPLUG_LOCK_DEPTH; i++) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (task->file_hotplug_lock[i] =3D=3D file) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 in_use =3D true;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto found;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 } while_each_thread(leader, task);
>> +found:
>> + =C2=A0 =C2=A0 =C2=A0 rcu_read_unlock();
>> + =C2=A0 =C2=A0 =C2=A0 return in_use;
>> +}
>
> This seems rather heavy-weight. If we're going to use this
> infrastructure for forced unmount, I think this will be a problem.

> Can't we two this in two stages: (1) mark a bit that forces
> file_hotplug_read_trylock to always fail and (2) block until the last
> remaining in-kernel file_hotplug_read_unlock() has executed?

Yes there is room for more optimization in the slow path.
I haven't noticed being a problem yet so I figured I would start
with stupid and simple.

I can easily see two passes.  The first setting the flag an calling
f_op->dead.  The second some kind of consolidate walk through the task
list, allowing checking on multiple files at once.

I'm not ready to consider anything that will add cost to the fast
path in the file descriptors though.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
