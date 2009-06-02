Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA9DB5F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 13:24:30 -0400 (EDT)
Received: by bwz21 with SMTP id 21so10670200bwz.38
        for <linux-mm@kvack.org>; Mon, 01 Jun 2009 22:24:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
References: <m1oct739xu.fsf@fess.ebiederm.org>
	 <1243893048-17031-4-git-send-email-ebiederm@xmission.com>
Date: Tue, 2 Jun 2009 08:16:44 +0300
Message-ID: <84144f020906012216n715a04d0ha492abc12175816@mail.gmail.com>
Subject: Re: [PATCH 04/23] vfs: Introduce infrastructure for revoking a file
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, "Eric W. Biederman" <ebiederm@aristanetworks.com>
List-ID: <linux-mm.kvack.org>

Hi Eric,

On Tue, Jun 2, 2009 at 12:50 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> +#ifdef CONFIG_FILE_HOTPLUG
> +
> +static bool file_in_use(struct file *file)
> +{
> + =A0 =A0 =A0 struct task_struct *leader, *task;
> + =A0 =A0 =A0 bool in_use =3D false;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 rcu_read_lock();
> + =A0 =A0 =A0 do_each_thread(leader, task) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < MAX_FILE_HOTPLUG_LOCK_DEP=
TH; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (task->file_hotplug_lock=
[i] =3D=3D file) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 in_use =3D =
true;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto found;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 } while_each_thread(leader, task);
> +found:
> + =A0 =A0 =A0 rcu_read_unlock();
> + =A0 =A0 =A0 return in_use;
> +}

This seems rather heavy-weight. If we're going to use this
infrastructure for forced unmount, I think this will be a problem.

Can't we two this in two stages: (1) mark a bit that forces
file_hotplug_read_trylock to always fail and (2) block until the last
remaining in-kernel file_hotplug_read_unlock() has executed?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
