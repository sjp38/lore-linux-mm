Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8D54B6B0011
	for <linux-mm@kvack.org>; Thu, 12 May 2011 06:43:07 -0400 (EDT)
Received: by vws4 with SMTP id 4so1515830vws.14
        for <linux-mm@kvack.org>; Thu, 12 May 2011 03:43:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305147776.2883.1.camel@work-vm>
References: <1305073386-4810-1-git-send-email-john.stultz@linaro.org>
	<1305073386-4810-3-git-send-email-john.stultz@linaro.org>
	<BANLkTikXyqddLbQKyDYFrAwq9DamDj--AQ@mail.gmail.com>
	<1305147776.2883.1.camel@work-vm>
Date: Thu, 12 May 2011 18:43:05 +0800
Message-ID: <BANLkTikxcfGYAmKf5QEAwJjDLdo6_k6zaw@mail.gmail.com>
Subject: Re: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Thu, May 12, 2011 at 5:02 AM, John Stultz <john.stultz@linaro.org> wrote=
:
> On Wed, 2011-05-11 at 17:33 +0800, Am=C3=A9rico Wang wrote:
>> On Wed, May 11, 2011 at 8:23 AM, John Stultz <john.stultz@linaro.org> wr=
ote:
>> > Acessing task->comm requires proper locking. However in the past
>> > access to current->comm could be done without locking. This
>> > is no longer the case, so all comm access needs to be done
>> > while holding the comm_lock.
>> >
>> > In my attempt to clean up unprotected comm access, I've noticed
>> > most comm access is done for printk output. To simpify correct
>> > locking in these cases, I've introduced a new %ptc format,
>> > which will safely print the corresponding task's comm.
>> >
>> > Example use:
>> > printk("%ptc: unaligned epc - sending SIGBUS.\n", current);
>> >
>>
>> Why do you hide current->comm behide printk?
>> How is this better than printk("%s: ....", task_comm(current)) ?
>
> So to properly access current->comm, you need to hold the task-lock (or
> with my new patch set, the comm_lock). Rather then adding locking to all
> the call sites that printk("%s ...", current->comm), I'm suggesting we
> add a new %ptc method which will handle the locking for you.
>

Sorry, I meant why not adding the locking into a wrapper function,
probably get_task_comm() and let the users to call it directly?

Why is %ptc better than

char comm[...];
get_task_comm(comm, current);
printk("%s: ....", comm);

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
