Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74DA4800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:51:24 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id d13so4247099ybn.14
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:51:24 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h187sor851665ywh.38.2018.01.24.23.51.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 23:51:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
References: <20171030124358.GF23278@quack2.suse.cz> <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz> <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com> <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com> <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
 <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz> <CAOQ4uxhDpBBUrr0JWRBaNQTTaUeJ4=gnM0iij2KivaGgp1ggtg@mail.gmail.com>
 <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Thu, 25 Jan 2018 09:51:22 +0200
Message-ID: <CAOQ4uxhyZNghjQU5atNv5xtgdHzA75UayphCyQDzxjM8GDTv3Q@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 25, 2018 at 3:08 AM, Shakeel Butt <shakeelb@google.com> wrote:
> On Wed, Jan 24, 2018 at 3:12 AM, Amir Goldstein <amir73il@gmail.com> wrote:
>> On Wed, Jan 24, 2018 at 12:34 PM, Jan Kara <jack@suse.cz> wrote:
>>> On Mon 22-01-18 22:31:20, Amir Goldstein wrote:
>>>> On Fri, Jan 19, 2018 at 5:02 PM, Shakeel Butt <shakeelb@google.com> wrote:
>>>> > On Wed, Nov 15, 2017 at 1:31 AM, Jan Kara <jack@suse.cz> wrote:
>>>> >> On Wed 15-11-17 01:32:16, Yang Shi wrote:
>>>> >>> On 11/14/17 1:39 AM, Michal Hocko wrote:
>>>> >>> >On Tue 14-11-17 03:10:22, Yang Shi wrote:
>>>> >>> >>
>>>> >>> >>
>>>> >>> >>On 11/9/17 5:54 AM, Michal Hocko wrote:
>>>> >>> >>>[Sorry for the late reply]
>>>> >>> >>>
>>>> >>> >>>On Tue 31-10-17 11:12:38, Jan Kara wrote:
>>>> >>> >>>>On Tue 31-10-17 00:39:58, Yang Shi wrote:
>>>> >>> >>>[...]
>>>> >>> >>>>>I do agree it is not fair and not neat to account to producer rather than
>>>> >>> >>>>>misbehaving consumer, but current memcg design looks not support such use
>>>> >>> >>>>>case. And, the other question is do we know who is the listener if it
>>>> >>> >>>>>doesn't read the events?
>>>> >>> >>>>
>>>> >>> >>>>So you never know who will read from the notification file descriptor but
>>>> >>> >>>>you can simply account that to the process that created the notification
>>>> >>> >>>>group and that is IMO the right process to account to.
>>>> >>> >>>
>>>> >>> >>>Yes, if the creator is de-facto owner which defines the lifetime of
>>>> >>> >>>those objects then this should be a target of the charge.
>>>> >>> >>>
>>>> >>> >>>>I agree that current SLAB memcg accounting does not allow to account to a
>>>> >>> >>>>different memcg than the one of the running process. However I *think* it
>>>> >>> >>>>should be possible to add such interface. Michal?
>>>> >>> >>>
>>>> >>> >>>We do have memcg_kmem_charge_memcg but that would require some plumbing
>>>> >>> >>>to hook it into the specific allocation path. I suspect it uses kmalloc,
>>>> >>> >>>right?
>>>> >>> >>
>>>> >>> >>Yes.
>>>> >>> >>
>>>> >>> >>I took a look at the implementation and the callsites of
>>>> >>> >>memcg_kmem_charge_memcg(). It looks it is called by:
>>>> >>> >>
>>>> >>> >>* charge kmem to memcg, but it is charged to the allocator's memcg
>>>> >>> >>* allocate new slab page, charge to memcg_params.memcg
>>>> >>> >>
>>>> >>> >>I think this is the plumbing you mentioned, right?
>>>> >>> >
>>>> >>> >Maybe I have misunderstood, but you are using slab allocator. So you
>>>> >>> >would need to force it to use a different charging context than current.
>>>> >>>
>>>> >>> Yes.
>>>> >>>
>>>> >>> >I haven't checked deeply but this doesn't look trivial to me.
>>>> >>>
>>>> >>> I agree. This is also what I explained to Jan and Amir in earlier
>>>> >>> discussion.
>>>> >>
>>>> >> And I also agree. But the fact that it is not trivial does not mean that it
>>>> >> should not be done...
>>>> >>
>>>> >
>>>> > I am currently working on directed or remote memcg charging for a
>>>> > different usecase and I think that would be helpful here as well.
>>>> >
>>>> > I have two questions though:
>>>> >
>>>> > 1) Is fsnotify_group the right structure to hold the reference to
>>>> > target mem_cgroup for charging?
>>>>
>>>> I think it is. The process who set up the group and determined the unlimited
>>>> events queue size and did not consume the events from the queue in a timely
>>>> manner is the process to blame for the OOM situation.
>>>
>>> Agreed here.
>
> Please note that for fcntl(F_NOTIFY), a global group, dnotify_group,
> is used. The allocations from dnotify_struct_cache &
> dnotify_mark_cache happens in the fcntl(F_NOTIFY), so , I take that
> the memcg of the current process should be charged.

Correct. Note that dnotify_struct_cache is allocated when setting up the
watch. that is always done by the listener, which is the correct process to
charge. handling the event does not allocate an event struct, so there is
no issue here.

>
>>>
>>>> > 2) Remote charging can trigger an OOM in the target memcg. In this
>>>> > usecase, I think, there should be security concerns if the events
>>>> > producer can trigger OOM in the memcg of the monitor. We can either
>>>> > change these allocations to use __GFP_NORETRY or some new gfp flag to
>>>> > not trigger oom-killer. So, is this valid concern or am I
>>>> > over-thinking?
>
> First, let me apologize, I think I might have led the discussion in
> wrong direction by giving one wrong information. The current upstream
> kernel, from the syscall context, does not invoke oom-killer when a
> memcg hits its limit and fails to reclaim memory, instead ENOMEM is
> returned. The memcg oom-killer is only invoked on page faults. However
> in a separate effort I do plan to converge the behavior, long
> discussion at <https://patchwork.kernel.org/patch/9988063/>.
>

So I guess it would be better if we limit the discussion on this
thread to which memcg should be accounted for the purpose of
ENOMEM. oom-killer is a whole different flammable discussion.

>>>> >
>>>>
>>>> I think that is a very valid concern, but not sure about the solution.
>>>> For an inotify listener and fanotify listener of class FAN_CLASS_NOTIF
>>>> (group->priority == 0), I think it makes sense to let oom-killer kill
>>>> the listener which is not keeping up with consuming events.
>>>
>>> Agreed.
>>>
>
> Is ENOMEM as acceptable as oom-killer killing the listener for
> FAN_CLASS_NOTIF? The current kernel will return ENOMEM but the future
> may trigger the oom-killer.
>

I can't say that the behavior change would be welcome by all current
applications. But current behavior allows fanotify listener to deep into
the pools of other memcg, so I don't know what the right answer is here.

>>>> For fanotify listener of class FAN_CLASS_{,PRE_}CONTENT
>>>> (group->priority > 0) allowing an adversary to trigger oom-killer
>>>> and kill the listener could bypass permission event checks.
>>>>
>>>> So we could use different allocation flags for permission events
>>>> or for groups with high priority or for groups that have permission
>>>> events in their mask, so an adversary could not use non-permission
>>>> events to oom-kill a listener that is also monitoring permission events.
>>>>
>>>> Generally speaking, permission event monitors should not be
>>>> setting  FAN_UNLIMITED_QUEUE and should not be causing oom
>>>> (because permission events are not queued they are blocking), but
>>>> there is nothing preventing a process to setup a FAN_CLASS_CONTENT
>>>> group with FAN_UNLIMITED_QUEUE and also monitor non-permission
>>>> events.
>>>>
>>>> There is also nothing preventing a process from setting up one
>>>> FAN_CLASS_CONTENT listener for permission events and another
>>>> FAN_CLASS_NOTIF listener for non-permission event.
>>>> Maybe it is not wise, but we don't know that there are no such processes
>>>> out there.
>>>
>>> So IMHO there are different ways to setup memcgs and processes in them and
>>> you cannot just guess what desired outcome is. The facts are:
>>>
>>> 1) Process has setup queue with unlimited length.
>>> 2) Admin has put the process into memcg with limited memory.
>>> 3) The process cannot keep up with event producer.
>>>
>>> These three facts are creating conflicting demands and it depends on the
>>> eye of the beholder what is correct. E.g. you may not want to take the
>>> whole hosting machine down because something bad happened in one container.
>>> OTOH you might what that to happen if that particular container is
>>> responsible for maintaining security - but then IMHO it is not a clever
>>> setup to constrain memory of the security sensitive application.
>>>
>>> So my stance on this is that we should define easy to understand semantics
>>> and let the admins deal with it. IMO that semantics should follow how we
>>> currently behave on system-wide OOM - i.e., simply trigger OOM killer when
>>> cgroup is going over limits.
>>>
>>> If we wanted to create safer API for fanotify from this standpoint, we
>>> could allow new type of fanotify groups where queue would be limited in
>>> length but tasks adding events to queue would get throttled as the queue
>>> fills up. Something like dirty page cache throttling. But I'd go for this
>>> complexity only once we have clear indications from practice that current
>>> scheme is not enough.
>>>
>>
>> What you are saying makes sense for a good design, but IIUC, what follows
>> is that you think we should change behavior and start accounting event
>> allocation to listener without any opt-in from admin?
>>
>> That could make existing systems break and become vulnerable to killing
>> the AV daemon by unlimited queue overflow attack.
>> My claim was that we cannot change behavior to charge a misconfigured
>> permission event fanotify listener with allocations, because of that risk.
>> Perhaps I did not read your response correctly to understand how you intend
>> we mitigate this potential breakage.
>>
>
> I am new to fsnotify APIs, so please point out if I have missed or
> misunderstood something. From what I understand after looking at the
> code, the only allocations which are interesting are from
> fanotify_perm_event_cachep and fanotify_event_cachep when
> fanotify_alloc_event() is called from fanotify_handle_event(). For all

There is also the variable length event kmalloc allocation in
inotify_handle_event(). Not sure what we can do about that??

> the other kmem caches, the allocations happen from syscalls done by
> the listener and thus can directly be charged to the memcg of the
> current and if charging is unsuccessful the ENOMEM will be returned by
> the syscall to the listener (oom-kill in the future probable kernel
> should be fine too).

ENOMEM would be acceptable in that case (failure to setup or modify watch).

>
> For the interesting case, we can get the memcg from the fsnotify_group
> object. Following scenarios can happen:
>
> 1. ENOMEM returned by fanotify_perm_event_cachep

That is almost certainly correct.
Only admin can set a watch for permission events.
If admin sets a listener for permission events inside a constrained memcg
any user in any memcg could get ENOMEM when accessing a file, because
that is what the admin cooked.

> 2. ENOMEM returned by fanotify_event_cachep

There is a nicer alternative, instead of failing the file access,
an overflow event can be queued. I sent a patch for that and Jan
agreed to the concept, but thought we should let user opt-in for this
change:
https://marc.info/?l=linux-fsdevel&m=150944704716447&w=2

So IMO, if user opts-in for OVERFLOW instead of ENOMEM,
charging the listener memcg would be non controversial.
Otherwise, I cannot say that starting to charge the listener memgc
for events won't break any application.

> 3. (Maybe) oom-kill triggered by fanotify_perm_event_cachep (in the
> future kernel)

Certainly not acceptable.

> 4. (Maybe) oom-kill triggered by fanotify_event_cachep (in the future kernel)
>

Too hard to answer.
In favor of oom-kill -  when a listener cannot keep up with reading events,
it is bound to get OVERFLOW at some point, which for many change tracking
applications has the same consequences as restarting the app.
Against oom-kill -  there is a much more subtle way to handle a full
events queue -
empty the queue and queue an overflow event, but that will require
fanotify/inotofy
to register a shrinker. Not sure how easy that solution is.


Thanks,
Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
