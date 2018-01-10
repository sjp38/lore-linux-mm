Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA3F26B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 11:22:23 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z24so11663725pgu.20
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 08:22:23 -0800 (PST)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id c4si2520664plr.407.2018.01.10.08.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 08:22:21 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1394749328.5225281.1515598510696.JavaMail.zimbra@redhat.com>
Date: Wed, 10 Jan 2018 10:21:31 -0600
In-Reply-To: <1394749328.5225281.1515598510696.JavaMail.zimbra@redhat.com>
	(Jan Stancek's message of "Wed, 10 Jan 2018 10:35:10 -0500 (EST)")
Message-ID: <87d12hbs6s.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: migrate_pages() of process with same UID in 4.15-rcX
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: otto ebeling <otto.ebeling@iki.fi>, mhocko@suse.com, mtk manpages <mtk.manpages@gmail.com>, linux-mm@kvack.org, clameter@sgi.com, w@1wt.eu, keescook@chromium.org, ltp@lists.linux.it, Linus Torvalds <torvalds@linux-foundation.org>

Jan Stancek <jstancek@redhat.com> writes:

> Hi,
>
> LTP test migrate_pages02 [1] is failing with 4.15-rcX, presumably as
> consequence of:
>   313674661925 "Unify migrate_pages and move_pages access checks"
>
> The scenario is that privileged parent forks child, both parent
> and child change euid to nobody and then parent tries to migrate
> child to different node. Starting with 4.15-rcX it fails with EPERM.
>
> Can anyone comment on accuracy of this sentence from man-pages
> after commit 313674661925?
>
> quoting man2/migrate_pages.2:
>  "To move pages in another process, the caller must be privileged
>  (CAP_SYS_NICE) or the real or effective user ID of the calling 
>  process must match the real or saved-set user ID of the target
>  process."
>
> Thanks,
> Jan
>
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/migrate_pages/migrate_pages02.c

The capability has been changed to CAP_SYS_PTRACE

The privilege check has been changed to the can you ptrace the other
process check (to avoid revealing how your pages are laid out to someone
who would not have known anyway) .  Which is essentially the same test
on uids.

*Scratches my head*

The code is using PTRACE_MODE_READ_REALCREDS which tests if the caller's
uid is the same and the target's uid, euid and suid.

The old code would test to see if either the caller's euid or
uid would match the targets uid or suid.  Which is extremely permissive.

For the LTP test above the fact that the target process does not have
matching uids looks like that will make it fail.


All of that said.  I am wondering if we should have used
PTRACE_MODE_READ_FSCREDS on these permission checks.  Using the caller's
euid would make more sense and if the comments are to be believed
PTRACE_MODE_READ_REALCREDS is only supposed to be used for backwards
compatibility.

Given that we can't be perfectly backwards compatibile I expect the
change should at least make sense.

AKA I think we should do:

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4ce44d3ff03d..513f68020e9e 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1404,7 +1404,7 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
         * Check if this process has the right to modify the specified process.
         * Use the regular "ptrace_may_access()" checks.
         */
-       if (!ptrace_may_access(task, PTRACE_MODE_READ_REALCREDS)) {
+       if (!ptrace_may_access(task, PTRACE_MODE_READ_FSCREDS)) {
                rcu_read_unlock();
                err = -EPERM;
                goto out_put;
diff --git a/mm/migrate.c b/mm/migrate.c
index 4d0be47a322a..51124a0b63eb 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1776,7 +1776,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
         * Check if this process has the right to modify the specified
         * process. Use the regular "ptrace_may_access()" checks.
         */
-       if (!ptrace_may_access(task, PTRACE_MODE_READ_REALCREDS)) {
+       if (!ptrace_may_access(task, PTRACE_MODE_READ_FSCREDS)) {
                rcu_read_unlock();
                err = -EPERM;
                goto out;


I know the LTP test case is not a regression and I know this won't fix
it.  I am just thinking since I am looking at it we should change the
permissions to something that makes more sense.

Eric





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
