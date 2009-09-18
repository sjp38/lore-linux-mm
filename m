Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 17C086B007E
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 22:05:19 -0400 (EDT)
Received: by qyk4 with SMTP id 4so614169qyk.23
        for <linux-mm@kvack.org>; Thu, 17 Sep 2009 19:05:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090917161432.97e06050.kamezawa.hiroyu@jp.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	 <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
	 <20090917114138.e14a1183.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090917114509.a9eb9f2c.kamezawa.hiroyu@jp.fujitsu.com>
	 <2375c9f90909162359m14ec7640m88ddd7ba54d6e793@mail.gmail.com>
	 <20090917161432.97e06050.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 18 Sep 2009 10:05:20 +0800
Message-ID: <2375c9f90909171905m66ff2005m16c5b3421aaf450@mail.gmail.com>
Subject: Re: [PATCH 3/3][mmotm] updateing size of kcore
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 3:14 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Thu, 17 Sep 2009 14:59:35 +0800
> Am=C3=A9rico Wang <xiyou.wangcong@gmail.com> wrote:
>
>> On Thu, Sep 17, 2009 at 10:45 AM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> >
>> > After memory hotplug (or other events in future), kcore size
>> > can be modified.
>> >
>> > To update inode->i_size, we have to know inode/dentry but we
>> > can't get it from inside /proc directly.
>> > But considerinyg memory hotplug, kcore image is updated only when
>> > it's opened. Then, updating inode->i_size at open() is enough.
>> >
>> > Cc: WANG Cong <xiyou.wangcong@gmail.com>
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>
>>
>> This patch looks fine.
>>
>> However, I am thinking if kcore is the only file under /proc whose size
>> is changed dynamically? If no, that probably means we need to change
>> generic proc code.
>>
> I tried yesteray, and back to this ;)
>
> One thing which makes me confused is that there is no way to get
> inode or dentry from proc_dir_entry.
>
> I tried to rewrite proc_getattr() for cheating "ls". But it just works fo=
r
> "stat" and inode->i_size is used more widely. So, this implementation now=
.

Yeah, stat->size is from inode->i_size.

>
> But considering practically, inode->i_size itself is not meaningful in /p=
roc
> files even if it's correct. For example, /proc/vmstat or /proc/stat,
> /proc/<pid>/maps... etc...

Yes.

>
> inode->i_size will be dynamically changed while reading. Now, most of use=
rs
> know regular files under /proc is not a "real" file and handle them in pr=
oper
> way. (programs can be used with pipe/stdin works well.)
>
> I wonder /proc/kcore is a special one, which gdb/objdump/readelf may acce=
ss.
> Above 3 programs are for "usual" files and not considering pseudo files u=
nder
> /proc. So, I think adding generic i->i_size support is an overkill until
> there are users depends on that.

At least I can't think out another /proc file as special as kcore. :-/

Thanks for your analysis, no problem with this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
