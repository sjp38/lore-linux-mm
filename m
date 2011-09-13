Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A2FFC900172
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 14:09:25 -0400 (EDT)
Received: by gxk22 with SMTP id 22so1018959gxk.30
        for <linux-mm@kvack.org>; Tue, 13 Sep 2011 11:09:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E6E39DD.2040102@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
 <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
 <4E699341.9010606@parallels.com> <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com>
 <4E6E39DD.2040102@parallels.com>
From: Paul Menage <paul@paulmenage.org>
Date: Tue, 13 Sep 2011 11:09:03 -0700
Message-ID: <CALdu-PC7ESSUHuF4vfVoRFFfkaBt1V28rGW3-O5pT3WtegAh4g@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>, Lennart Poettering <lennart@poettering.net>

On Mon, Sep 12, 2011 at 9:57 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
>
> I think at this point there is at least consensus that this could very we=
ll
> live in memcg, right ?

Yes, it looks that way.

>> This is definitely an improvement, but I'd say it's not enough. I
>> think we should consider something like:
>
> One step at a time =3D)

Yes, as far as design and initial implementation goes - but the full
plan has to be figured out before anything gets committed to mainline,
given the stability guarantees that implies.

>> - the 'active' control determines whether (all) child cgroups will
>> have =A0memory.{limit,usage}_in_bytes files, or
>> memory.{kernel,user}_{limit,usage}_in_bytes files
>> - kernel memory will be charged either against 'kernel' or 'total'
>> depending on the value of unified
>
> You mean for display/pressure purposes, right? Internally, I think once w=
e
> have kernel memory, we always charge it to kernel memory, regardless of
> anything else. The value in unified field will only take place when we ne=
ed
> to grab this value.
>
> I don't personally see a reason for not having all files present at all
> times.

There's pretty much only one reason - avoiding the overhead of
maintaining multiple counters.

Each set of counters (user, kernel, total) will have its own locks,
contention and other overheads to keep up to date. If userspace
doesn't care about one or two of the three, then that's mostly wasted.

Now it might be that the accounting of all three can be done with
little more overhead than that required to update just a split view or
just a unified view, in which case there's much less argument against
simplifying and tracking/charging/limiting all three.

>
> It is overly flexible if we're exposing these counters and expecting the
> user to do anything with them. It is perfectly fine if a single file, whe=
n
> read, displays this information as statistics.
>

When I proposed this, I guess I was envisioning that most of the
counters (e.g. things like TCP buffers or general network buffers)
would be primarily for stats, since the admin probably only cares
about total memory usage.

The main point of this was to allow people who want to do something
like tracking/limiting TCP buffer usage specifically per-cgroup to do
so, without having any performance impact on the regular users.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
