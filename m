Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD4E26B025E
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:35:40 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fn2so209192161pad.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:35:40 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id m2si28295991pgd.289.2016.10.17.10.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 10:35:39 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161017172547.GJ14666@pc.thejh.net>
Date: Mon, 17 Oct 2016 12:33:33 -0500
In-Reply-To: <20161017172547.GJ14666@pc.thejh.net> (Jann Horn's message of
	"Mon, 17 Oct 2016 19:25:47 +0200")
Message-ID: <87wph6op76.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix ptrace_may_access
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jann@thejh.net>
Cc: Linux Containers <containers@lists.linux-foundation.org>, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

Jann Horn <jann@thejh.net> writes:

> On Mon, Oct 17, 2016 at 11:39:49AM -0500, Eric W. Biederman wrote:
>> 
>> During exec dumpable is cleared if the file that is being executed is
>> not readable by the user executing the file.  A bug in
>> ptrace_may_access allows reading the file if the executable happens to
>> enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
>> unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).
>> 
>> This problem is fixed with only necessary userspace breakage by adding
>> a user namespace owner to mm_struct, captured at the time of exec,
>> so it is clear in which user namespace CAP_SYS_PTRACE must be present
>> in to be able to safely give read permission to the executable.
>> 
>> The function ptrace_may_access is modified to verify that the ptracer
>> has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
>> This ensures that if the task changes it's cred into a subordinate
>> user namespace it does not become ptraceable.
>
> This looks good! Basically applies the same rules that already apply to
> EUID/... changes to namespace changes, and anyone entering a user
> namespace can now safely drop UIDs and GIDs to namespace root.

Yes.  It just required the right perspective and it turned out to be
straight forward to solve.  Especially since it is buggy today for
unreadable executables.

> This integrates better in the existing security concept than my old
> patch "ptrace: being capable wrt a process requires mapped uids/gids",
> and it has less issues in cases where e.g. the extra privileges of an
> entering process are the filesystem root or so.
>
> FWIW, if you want, you can add "Reviewed-by: Jann Horn
> <jann@thejh.net>".

Will do. Thank you.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
