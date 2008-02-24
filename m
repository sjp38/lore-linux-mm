Received: from deneb.vpn.enyo.de ([212.9.189.177] helo=deneb.enyo.de)
	by mail.enyo.de with esmtp id 1JTFbr-0007cE-A8
	for linux-mm@kvack.org; Sun, 24 Feb 2008 13:05:35 +0100
Received: from fw by deneb.enyo.de with local (Exim 4.69)
	(envelope-from <fw@deneb.enyo.de>)
	id 1JTFbq-0002q2-Og
	for linux-mm@kvack.org; Sun, 24 Feb 2008 13:05:34 +0100
From: Florian Weimer <fw@deneb.enyo.de>
Subject: How to reserve address space without actual backing store
Date: Sun, 24 Feb 2008 13:05:34 +0100
Message-ID: <87k5kublv5.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is more or less a userspace API question, but the documentation
I've found in manpages does not match actual kernel behavior, so I'm
asking here.

With vm.overcommit_memory and address space randomization, a lot of
applications (particularly those who use certain types of garbage
collectors) need a way to reserve a chunk of the address space, without
actually counting towards the vm.overcommit_memory limit.  Typically,
you want to allocate all the heap in a single, continuous range.  As the
heap usage increases, you gradually allocate backing store from the
kernel.  (Without address space randomization, you can use some
heuristics to avoid DSO space etc. and use MAP_FIXED to grow the heap as
needed, I suppose.)

MAP_NORESERVE does not work for this purpose because memory allocated
that way still counts as comitted.  What seems to work is to reserve
address space with PROT_NONE, and later use mprotected to get backing
store.  My question is if this is an accident, or if this approach is
guaranteed to work in the future.

(mprotect to subsequently add PROT_EXEC has been broken on some
architectures unless you take special measures, so I guess that this is
genuine concern.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
