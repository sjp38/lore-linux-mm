Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 1BF8D6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 18:06:21 -0400 (EDT)
Date: Mon, 5 Aug 2013 15:06:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/7] arch: mm: pass userspace fault flag to generic
 fault handler
Message-Id: <20130805150618.47d699f5ce9f42242ee2e7c3@linux-foundation.org>
In-Reply-To: <1375549200-19110-4-git-send-email-hannes@cmpxchg.org>
References: <1375549200-19110-1-git-send-email-hannes@cmpxchg.org>
	<1375549200-19110-4-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, azurIt <azurit@pobox.sk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

On Sat,  3 Aug 2013 12:59:56 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Unlike global OOM handling, memory cgroup code will invoke the OOM
> killer in any OOM situation because it has no way of telling faults
> occuring in kernel context - which could be handled more gracefully -
> from user-triggered faults.
> 
> Pass a flag that identifies faults originating in user space from the
> architecture-specific fault handlers to generic code so that memcg OOM
> handling can be improved.

arch/arm64/mm/fault.c has changed.  Here's what I came up with:

--- a/arch/arm64/mm/fault.c~arch-mm-pass-userspace-fault-flag-to-generic-fault-handler
+++ a/arch/arm64/mm/fault.c
@@ -199,13 +199,6 @@ static int __kprobes do_page_fault(unsig
 	unsigned long vm_flags = VM_READ | VM_WRITE | VM_EXEC;
 	unsigned int mm_flags = FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_KILLABLE;
 
-	if (esr & ESR_LNX_EXEC) {
-		vm_flags = VM_EXEC;
-	} else if ((esr & ESR_WRITE) && !(esr & ESR_CM)) {
-		vm_flags = VM_WRITE;
-		mm_flags |= FAULT_FLAG_WRITE;
-	}
-
 	tsk = current;
 	mm  = tsk->mm;
 
@@ -220,6 +213,16 @@ static int __kprobes do_page_fault(unsig
 	if (in_atomic() || !mm)
 		goto no_context;
 
+	if (user_mode(regs))
+		mm_flags |= FAULT_FLAG_USER;
+
+	if (esr & ESR_LNX_EXEC) {
+		vm_flags = VM_EXEC;
+	} else if ((esr & ESR_WRITE) && !(esr & ESR_CM)) {
+		vm_flags = VM_WRITE;
+		mm_flags |= FAULT_FLAG_WRITE;
+	}
+
 	/*
 	 * As per x86, we may deadlock here. However, since the kernel only
 	 * validly references user space from well defined areas of the code,

But I'm not terribly confident in it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
