Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB0916B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 14:06:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so2236321wme.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:06:27 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id z7si50133280wjl.99.2016.10.18.11.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 11:06:26 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id d199so577068wmd.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:06:26 -0700 (PDT)
Date: Tue, 18 Oct 2016 20:06:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix
 ptrace_may_access
Message-ID: <20161018180624.GA27792@dhcp22.suse.cz>
References: <87twcbq696.fsf@x220.int.ebiederm.org>
 <20161018135031.GB13117@dhcp22.suse.cz>
 <8737jt903u.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8737jt903u.fsf@xmission.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-kernel@vger.kernel.org

On Tue 18-10-16 09:56:53, Eric W. Biederman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Mon 17-10-16 11:39:49, Eric W. Biederman wrote:
> >> 
> >> During exec dumpable is cleared if the file that is being executed is
> >> not readable by the user executing the file.  A bug in
> >> ptrace_may_access allows reading the file if the executable happens to
> >> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
> >> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
> >> 
> >> This problem is fixed with only necessary userspace breakage by adding
> >> a user namespace owner to mm_struct, captured at the time of exec,
> >> so it is clear in which user namespace CAP_SYS_PTRACE must be present
> >> in to be able to safely give read permission to the executable.
> >> 
> >> The function ptrace_may_access is modified to verify that the ptracer
> >> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
> >> This ensures that if the task changes it's cred into a subordinate
> >> user namespace it does not become ptraceable.
> >
> > I haven't studied your patch too deeply but one thing that immediately 
> > raised a red flag was that mm might be shared between processes (aka
> > thread groups). What prevents those two to sit in different user
> > namespaces?
> >
> > I am primarily asking because this generated a lot of headache for the
> > memcg handling as those processes might sit in different cgroups while
> > there is only one correct memcg for them which can disagree with the
> > cgroup associated with one of the processes.
> 
> That is a legitimate concern, but I do not see any of those kinds of
> issues here.
> 
> Part of the memcg pain comes from the fact that control groups are
> process centric, and part of the pain comes from the fact that it is
> possible to change control groups.  What I am doing is making the mm
> owned by a user namespace (at creation time), and I am not allowing
> changes to that ownership. The credentials of the tasks that use that mm
> may be in the same user namespace or descendent user namespaces.

OK, then my worries about this weird "threading" model is void.

Thanks for the clarification.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
