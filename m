Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6941C6B00BB
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 13:57:51 -0400 (EDT)
Received: by yxm34 with SMTP id 34so1588872yxm.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 10:57:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101028170132.GY27796@think>
References: <AANLkTimt7wzR9RwGWbvhiOmot_zzayfCfSh_-v6yvuAP@mail.gmail.com>
	<AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com>
	<AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
	<AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
	<AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
	<20101028090002.GA12446@elte.hu>
	<AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
	<20101028133036.GA30565@elte.hu>
	<20101028170132.GY27796@think>
Date: Thu, 28 Oct 2010 20:57:49 +0300
Message-ID: <AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
Subject: Re: 2.6.36 io bring the system to its knees
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 28, 2010 at 03:30:36PM +0200, Ingo Molnar wrote:
>> "Many seconds freezes" and slowdowns wont be fixed via the VFS scalabili=
ty patches
>> i'm afraid.
>>
>> This has the appearance of some really bad IO or VM latency problem. Unf=
ixed and
>> present in stable kernel versions going from years ago all the way to v2=
.6.36.

On Thu, Oct 28, 2010 at 8:01 PM, Chris Mason <chris.mason@oracle.com> wrote=
:
> Hmmm, the workload you're describing here has two special parts. =A0First
> it dramatically overloads the disk, and then it has guis doing things
> waiting for the disk.
>
> The virtualbox part of the workload is probably filling the queue with
> huge amounts of synchronous random IO (I'm assuming it is going in via
> O_DIRECT), and this will defeat any attempts from the filesystem to tell
> the elevator "hey look, my IO is synchronous, please do hurry"
>
> So, I'd try mounting ext4 in data=3Dwriteback mode. =A0I can't make ext4
> stall fsyncs on non-fsync IO locally and it looks like they have solved
> the ext3 data=3Dordered problem. =A0But I still like to rule out old and
> known issues before we dig into new things.
>
> I'd also suggest something like the below patch which is entirely
> untested and must be blessed by an actual ext4 developer. =A0I think we
> can make fsync faster if we put the mutex locking down in the FS, but
> until then it should be ok to drop the mutex while we are doing the
> expensive log commits:
>
> diff --git a/fs/ext4/fsync.c b/fs/ext4/fsync.c
> index 592adf2..1b7a637 100644
> --- a/fs/ext4/fsync.c
> +++ b/fs/ext4/fsync.c
> @@ -114,6 +114,7 @@ int ext4_sync_file(struct file *file, int datasync)
> =A0 =A0 =A0 =A0if (ext4_should_journal_data(inode))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ext4_force_commit(inode->i_sb);
>
> + =A0 =A0 =A0 mutex_unlock(&inode->i_mutex);
> =A0 =A0 =A0 =A0commit_tid =3D datasync ? ei->i_datasync_tid : ei->i_sync_=
tid;
> =A0 =A0 =A0 =A0if (jbd2_log_start_commit(journal, commit_tid)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -133,5 +134,7 @@ int ext4_sync_file(struct file *file, int datasync)
> =A0 =A0 =A0 =A0} else if (journal->j_flags & JBD2_BARRIER)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blkdev_issue_flush(inode->i_sb->s_bdev, GF=
P_KERNEL, NULL,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BLKDEV_IFL_WAIT);
> +
> + =A0 =A0 =A0 mutex_lock(&inode->i_mutex);
> =A0 =A0 =A0 =A0return ret;
> =A0}

Don't we need to call ext4_should_writeback_data() before we drop the
lock? It pokes at ->i_mode which needs ->i_mutex AFAICT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
