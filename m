Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id D44976B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:37:32 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gg9so232090297pac.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:37:32 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id a22si36341021pfl.173.2016.10.18.08.37.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:37:31 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net>
Date: Tue, 18 Oct 2016 10:35:23 -0500
In-Reply-To: <20161018150507.GP14666@pc.thejh.net> (Jann Horn's message of
	"Tue, 18 Oct 2016 17:05:07 +0200")
Message-ID: <87twc9656s.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix ptrace_may_access
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Jann Horn <jann@thejh.net> writes:

> On Tue, Oct 18, 2016 at 09:56:53AM -0500, Eric W. Biederman wrote:
>> Michal Hocko <mhocko@kernel.org> writes:
>> 
>> > On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
>> >> 
>> >> During exec dumpable is cleared if the file that is being executed is
>> >> not readable by the user executing the file.  A bug in
>> >> ptrace_may_access allows reading the file if the executable happens to
>> >> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
>> >> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>> >> 
>> >> This problem is fixed with only necessary userspace breakage by adding
>> >> a user namespace owner to mm_struct, captured at the time of exec,
>> >> so it is clear in which user namespace CAP_SYS_PTRACE must be present
>> >> in to be able to safely give read permission to the executable.
>> >> 
>> >> The function ptrace_may_access is modified to verify that the ptracer
>> >> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
>> >> This ensures that if the task changes it's cred into a subordinate
>> >> user namespace it does not become ptraceable.
>> >
>> > I haven't studied your patch too deeply but one thing that immediately 
>> > raised a red flag was that mm might be shared between processes (aka
>> > thread groups). What prevents those two to sit in different user
>> > namespaces?
>> >
>> > I am primarily asking because this generated a lot of headache for the
>> > memcg handling as those processes might sit in different cgroups while
>> > there is only one correct memcg for them which can disagree with the
>> > cgroup associated with one of the processes.
>> 
>> That is a legitimate concern, but I do not see any of those kinds of
>> issues here.
>> 
>> Part of the memcg pain comes from the fact that control groups are
>> process centric, and part of the pain comes from the fact that it is
>> possible to change control groups.  What I am doing is making the mm
>> owned by a user namespace (at creation time), and I am not allowing
>> changes to that ownership. The credentials of the tasks that use that mm
>> may be in the same user namespace or descendent user namespaces.
>> 
>> The core goal is to enforce the unreadability of an mm when an
>> non-readable file is executed.  This is a time of mm creation property.
>> The enforcement of which fits very well with the security/permission
>> checking role of the user namespace.
>
> How is that going to work? I thought the core goal was better security for
> entering containers.

The better security when entering containers came from fixing the the
check for unreadable files.  Because that is fundamentally what
the mm dumpable settings are for.

> If I want to dump a non-readable file, afaik, I can just make a new user
> namespace, then run the file in there and dump its memory.
> I guess you could fix that by entirely prohibiting the execution of a
> non-readable file whose owner UID is not mapped. (Adding more dumping
> restrictions wouldn't help much because you could still e.g. supply a
> malicious dynamic linker if you control the mount namespace.)

That seems to be a part of this puzzle I have incompletely addressed,
thank you.

It looks like I need to change either the owning user namespace or
fail the exec.  Malicious dynamic linkers are doubly interesting.

As mount name spaces are also owned if I have privileges I can address
the possibility of a malicious dynamic linker that way.  AKA who cares
about the link if the owner of the mount namespace has permissions to
read the file.

I am going to look at failing the exec if the owning user namespace
of the mm would not have permissions to read the file.  That should just
be a couple of lines of code and easy to maintain.  Plus it does not
appear that non-readable executables are particularly common.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
