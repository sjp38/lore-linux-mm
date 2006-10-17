Received: from master.linux-sh.org (124x34x33x190.ap124.ftth.ucom.ne.jp [124.34.33.190])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.ocgnet.org (Postfix) with ESMTP id A84EE70C93F
	for <linux-mm@kvack.org>; Tue, 17 Oct 2006 07:44:49 -0500 (CDT)
Received: from localhost (unknown [127.0.0.1])
	by master.linux-sh.org (Postfix) with ESMTP id 9FE61658E8
	for <linux-mm@kvack.org>; Tue, 17 Oct 2006 12:44:44 +0000 (UTC)
Received: from master.linux-sh.org ([127.0.0.1])
	by localhost (master.linux-sh.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id T0ZjAoE3d0EV for <linux-mm@kvack.org>;
	Tue, 17 Oct 2006 21:44:44 +0900 (JST)
Date: Tue, 17 Oct 2006 21:44:44 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Decoupled pte_read/write/exec()?
Message-ID: <20061017124444.GA17640@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm faced with a bit of an issue interfacing a new MMU. Our previous ones
were quite simple, lacking both explicit execute protections and
following write implies read semantics. In this new case however we have
a full read/write/execute set of permissions, for both user _and_ kernel
access, effectively allowing for user mappings that aren't readable by
the kernel.

What I've been doing so far is setting the access bits for both user and
kernel space in the PTE modifiers and clearing out the user bit when the
clear happens. This would seem to work, but I don't like the idea of
leaving stray permission bits set, particularly with regards to the exec
bit, though it is only for privileged space where it's not cleared.

Is there anything obvious that I'm missing? I suspect I will just have to
have a software _PAGE_USER bit that gets set in these places to figure
out which set of permissions to adjust, and make sure that the kernel
permission bits match the userspace bits so long as _PAGE_USER is set.

It looks like PowerPC is doing something similar, particularly with
regards to pte_mkexec()/pte_exprotect(), but this seems to deny the exec
permission to the kernel as well, where pte_rdprotect() simply clears the
user bit, and pte_wrprotect() simply implies user write protection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
