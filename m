Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C5D256B007B
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 15:35:21 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20100915104855.41de3ebf@lilo> <4C90A6C7.9050607@redhat.com>
	<AANLkTi=rmUUPCm212Sju-wW==5cT4eqqU+FEP_hX-Z_y@mail.gmail.com>
	<4C90F09F.9080307@redhat.com>
Date: Wed, 15 Sep 2010 12:35:02 -0700
In-Reply-To: <4C90F09F.9080307@redhat.com> (Avi Kivity's message of "Wed, 15
	Sep 2010 18:13:19 +0200")
Message-ID: <m1pqwe6brt.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [RFC][PATCH] Cross Memory Attach
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Bryan Donlan <bdonlan@gmail.com>, Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Linus Torvalds <torvalds@linux-foundation.org>, Valdis.Kletnieks@vt.edu, Alan Cox <alan@lxorguk.ukuu.org.uk>, Robin Holt <holt@sgi.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity <avi@redhat.com> writes:

>  On 09/15/2010 04:46 PM, Bryan Donlan wrote:
>> On Wed, Sep 15, 2010 at 19:58, Avi Kivity<avi@redhat.com>  wrote:
>>
>>> Instead of those two syscalls, how about a vmfd(pid_t pid, ulong start,
>>> ulong len) system call which returns an file descriptor that represents a
>>> portion of the process address space.  You can then use preadv() and
>>> pwritev() to copy memory, and io_submit(IO_CMD_PREADV) and
>>> io_submit(IO_CMD_PWRITEV) for asynchronous variants (especially useful with
>>> a dma engine, since that adds latency).
>>>
>>> With some care (and use of mmu_notifiers) you can even mmap() your vmfd and
>>> access remote process memory directly.
>> Rather than introducing a new vmfd() API for this, why not just add
>> implementations for these more efficient operations to the existing
>> /proc/$pid/mem interface?
>
> Yes, opening that file should be equivalent (and you could certainly implement
> aio via dma for it).

I will second this /proc/$pid/mem is semantically the same and it would
really be good if this patch became a patch optimizing that case.

Otherwise we have code duplication and thus dilution of knowledge in
two different places for no discernable reason.  Hindering long term
maintenance.

+int copy_to_from_process_allowed(struct task_struct *task)
+{
+	/* Allow copy_to_from_process to access another process using
+	   the same critera  as a process would be allowed to ptrace
+	   that same process */
+	const struct cred *cred = current_cred(), *tcred;
+
+	rcu_read_lock();
+	tcred = __task_cred(task);
+	if ((cred->uid != tcred->euid ||
+	     cred->uid != tcred->suid ||
+	     cred->uid != tcred->uid  ||
+	     cred->gid != tcred->egid ||
+	     cred->gid != tcred->sgid ||
+	     cred->gid != tcred->gid) &&
+	    !capable(CAP_SYS_PTRACE)) {
+		rcu_read_unlock();
+		return 0;
+	}
+	rcu_read_unlock();
+	return 1;
+}

This hunk of the patch is a copy of __ptrace_may_access without security
hooks removed.  Both the code duplication, the removal of the dumpable
check and the removal of the security hooks look like a bad idea.

Removing the other checks in check_mem_permission seems reasonable as
those appear to be overly paranoid.

Hmm.  This is weird:

+	/* Get the pages we're interested in */
+	pages_pinned = get_user_pages(task, task->mm, pa,
+				      nr_pages_to_copy,
+				      copy_to, 0, process_pages, NULL);
+
+	if (pages_pinned != nr_pages_to_copy)
+		goto end;
+
+	/* Do the copy for each page */
+	for (i = 0; i < nr_pages_to_copy; i++) {
+		target_kaddr = kmap(process_pages[i]) + start_offset;
+		bytes_to_copy = min(PAGE_SIZE - start_offset,
+				    len - *bytes_copied);
+		if (start_offset)
+			start_offset = 0;
+
+		if (copy_to) {
+			ret = copy_from_user(target_kaddr,
+					     user_buf + *bytes_copied,
+					     bytes_to_copy);
+			if (ret) {
+				kunmap(process_pages[i]);
+				goto end;
+			}
+		} else {
+			ret = copy_to_user(user_buf + *bytes_copied,
+					   target_kaddr, bytes_to_copy);
+			if (ret) {
+				kunmap(process_pages[i]);
+				goto end;
+			}
+		}
+		kunmap(process_pages[i]);
+		*bytes_copied += bytes_to_copy;
+	}
+

That hunk of code appears to be an copy of mm/memmory.c:access_process_vm.
A little more optimized by taking the get_user_pages out of the inner
loop but otherwise pretty much the same code.

So I would argue it makes sense to optimize access_process_vm.

So unless there are fundamental bottlenecks to performance I am not
seeing please optimize the existing code paths in the kernel that do
exactly what you are trying to do.

Thanks,
Eric




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
