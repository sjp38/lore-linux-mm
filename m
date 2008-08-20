Received: by wr-out-0506.google.com with SMTP id c30so407512wra.14
        for <linux-mm@kvack.org>; Wed, 20 Aug 2008 06:25:37 -0700 (PDT)
Message-ID: <a2776ec50808200625m5f6d9e6fs4d8e594bd259115a@mail.gmail.com>
Date: Wed, 20 Aug 2008 15:25:37 +0200
From: righi.andrea@gmail.com
Reply-To: righiandr@users.sourceforge.net
Subject: Re: [discuss] memrlimit - potential applications that can use
In-Reply-To: <1219167669.23641.156.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48AA73B5.7010302@linux.vnet.ibm.com>
	 <1219161525.23641.125.camel@nimitz>
	 <48AAF8C0.1010806@linux.vnet.ibm.com>
	 <1219167669.23641.156.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Marco Sbrighi <m.sbrighi@cineca.it>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 8/19/08, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> On Tue, 2008-08-19 at 22:15 +0530, Balbir Singh wrote:
>> Dave Hansen wrote:
>> > On Tue, 2008-08-19 at 12:48 +0530, Balbir Singh wrote:
>> >> 1. To provide a soft landing mechanism for applications that exceed
>> >> their memory
>> >> limit. Currently in the memory resource controller, we swap and on
>> >> failure OOM.
>> >> 2. To provide a mechanism similar to memory overcommit for control
>> >> groups.
>> >> Overcommit has finer accounting, we just account for virtual address
>> >> space usage.
>> >> 3. Vserver will directly be able to port over on top of memrlimit
>> >> (their address
>> >> space limitation feature)
>> >
>> > Balbir,
>> >
>> > This all seems like a little bit too much hand waving to me.  I don't
>>
>> Dave, there is no hand waving, just an honest discussion. Although, you
>> may not
>> see it in the background, we still need overcommit protection and we have
>> it
>> enabled by default for the system. There are applications that can deal
>> with the
>> constraints setup by the administrator and constraints of the environment,
>> please see http://en.wikipedia.org/wiki/Autonomic_computing.
>
> OK, let's get back to describing the basic problem here.  What is the
> basic problem being solved?  Applications basically want to get a
> failure back from malloc() when the machine is (nearly?) out of memory
> so they can stop consuming?

Hi Dave,

IMHO there're two different problems, and both should be considered by
the kernel system wide as well as for each cgroup:

1) how to prevent OOM conditions
2) how to handle OOM conditions

The perfect solution for 2) doesn't exist IMHO, because there's no
clean way from the applications point of view to handle such critical
condition post-facto.

Containing the OOM within a cgroup is surely a great improvement, but
there's always the risk to kill the wrong applications (within the
cgroup). Another good improvement would be to handle the OOM condition
in userspace, Balbir is working/discussing/plannig something about
this, if I remember well.

An interesting solution, proposed in the past, was to send a special
signal to userspace apps to free up caches/buffers/unused mem when the
whole memory in the system goes under a critical threshold. But this
would require an active support by all the userspace applications,
that should implement the signal handler in a proper way. Maybe this
could be even considered a special case of the userspace OOM handling.

Memory overcommit protection, instead, is a way to *prevent* OOM
conditions (problem 1). This approach is safer for critical
applications that have a chance to cleanly handle the OOM at the time
they're requesting memory to the kernel, instead of receiving a
SIGKILL (or whatever signal) asynchronously during the execution path.
Unfortunately, this kind of prevention is not always acceptable,
because, in this case, userspace apps must request virtual memory
carefully, otherwise it would be quite easy to create memory DoS for
other applications (and probably the per-application/per-cgroup
RLIMIT_AS could help here).

As an example, an ideal solution I'd like to implement for a generic
enterprise environment is to create all the critical apps inside a
cgroup with never-overcommit memory policy and move all the other
userspace apps in another cgroup with oom-killer enabled. But for this
we need both 1) and 2) functionalities, and I don't see any other way
to do so.

-Andrea

>
> Is this the only way to do autonomic computing with memory?  Or, are
> there other or better approaches?
>
> Surely an autonomic computing app could keep track of its own memory
> footprint.
>
>> > really see a single concrete user in the "potential applications" here.
>> > I really don't understand why you're pushing this so hard if you don't
>> > have anyone to actually use it.
>> >
>> > I just don't see anyone that *needs* it.  There's a lot of "it would be
>> > nice", but no "needs".
>>
>> If you see the original email, I've sent - I've mentioned that we need
>> overcommit support (either via memrlimit or by porting over the overcommit
>> feature) and the exploiters you are looking for is the same as the ones
>> who need
>> overcommit and RLIMIT_AS support.
>>
>> On the memory overcommit front, please see PostgreSQL Server
>> Administrator's
>> Guide at
>> http://www.network-theory.co.uk/docs/postgresql/vol3/LinuxMemoryOvercommit.html
>>
>> The guide discusses turning off memory overcommit so that the database is
>> never
>> OOM killed, how do we provide these guarantees for a particular control
>> group?
>> We can do it system wide, but ideally we want the control point to be per
>> control group.
>
> Heh.  That suggestion is, at best, working around a kernel bug.  The DB
> guys are just saying to do that because they're the biggest memory users
> and always seem to get OOM killed first.
>
> The base problem here is the OOM killer, not an application that truly
> uses memory overcommit restriction in an interesting way.
>
>> As far as other users are concerned, I've listed users of the memory limit
>> feature, in the original email I sent out. To try and understand your
>> viewpoint
>> better, could you please tell me if
>>
>> 1. You are opposed to overcommit and RLIMIT_AS as features
>>
>> OR
>>
>> 2. Expanding them to control groups
>
> I think that too many of the users of (1) probably fall into the
> PostgreSQL category.  They found that turning it on "fixed" their bugs,
> but it really just swept them under the rug.
>
> So, before we expand the use of those features to control groups by
> adding a bunch of new code, let's make sure that there will be users for
> it and that those users have no better way of doing it.
>
> -- Dave
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
