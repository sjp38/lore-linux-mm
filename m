Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1B6A16B0044
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 10:03:40 -0500 (EST)
Received: by fxm25 with SMTP id 25so4371808fxm.6
        for <linux-mm@kvack.org>; Tue, 15 Dec 2009 07:03:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	 <ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	 <cc557aab0912150111k41517b41t8999568db3bd8daa@mail.gmail.com>
	 <20091215183533.1a1e87d9.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 15 Dec 2009 17:03:37 +0200
Message-ID: <cc557aab0912150703qcfe6458paa7da71cb032cb93@mail.gmail.com>
Subject: Re: [PATCH RFC v2 1/4] cgroup: implement eventfd-based generic API
	for notifications
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 11:35 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 15 Dec 2009 11:11:16 +0200
> "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> Could anybody review the patch?
>>
>> Thank you.
>
> some nitpicks.
>
>>
>> On Sat, Dec 12, 2009 at 12:59 AM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>
>> > + =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Unregister events and notify userspace.
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* FIXME: How to avoid race with cgroup_ev=
ent_remove_work()
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0* =C2=A0 =C2=A0 =C2=A0 =C2=A0which runs f=
rom workqueue?
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&cgrp->event_list_mutex);
>> > + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_safe(event, tmp, &cgrp->eve=
nt_list, list) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cgroup_event_remove=
(event);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 eventfd_signal(even=
t->eventfd, 1);
>> > + =C2=A0 =C2=A0 =C2=A0 }
>> > + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&cgrp->event_list_mutex);
>> > +
>> > +out:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>> > =C2=A0}
>
> How ciritical is this FIXME ?
> But Hmm..can't we use RCU ?

It's not reasonable to have RCU here, since event_list isn't mostly-read.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
