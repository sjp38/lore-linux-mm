Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id F337B6B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 20:31:53 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id y200so1525551itc.7
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 17:31:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c23sor623653itb.108.2018.01.31.17.31.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jan 2018 17:31:52 -0800 (PST)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] KVM/x86: remove WARN_ON() for when vm_munmap() fails
Date: Wed, 31 Jan 2018 17:30:21 -0800
Message-Id: <20180201013021.151884-1-ebiggers3@gmail.com>
In-Reply-To: <001a1141c71c13f559055d1b28eb@google.com>
References: <001a1141c71c13f559055d1b28eb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, Eric Biggers <ebiggers@google.com>

From: Eric Biggers <ebiggers@google.com>

On x86, special KVM memslots such as the TSS region have anonymous
memory mappings created on behalf of userspace, and these mappings are
removed when the VM is destroyed.

It is however possible for removing these mappings via vm_munmap() to
fail.  This can most easily happen if the thread receives SIGKILL while
it's waiting to acquire ->mmap_sem.   This triggers the 'WARN_ON(r < 0)'
in __x86_set_memory_region().  syzkaller was able to hit this, using
'exit()' to send the SIGKILL.  Note that while the vm_munmap() failure
results in the mapping not being removed immediately, it is not leaked
forever but rather will be freed when the process exits.

It's not really possible to handle this failure properly, so almost
every other caller of vm_munmap() doesn't check the return value.  It's
a limitation of having the kernel manage these mappings rather than
userspace.

So just remove the WARN_ON() so that users can't spam the kernel log
with this warning.

Fixes: f0d648bdf0a5 ("KVM: x86: map/unmap private slots in __x86_set_memory_region")
Reported-by: syzbot <syzkaller@googlegroups.com>
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/x86/kvm/x86.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index c53298dfbf50..53b57f18baec 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -8272,10 +8272,8 @@ int __x86_set_memory_region(struct kvm *kvm, int id, gpa_t gpa, u32 size)
 			return r;
 	}
 
-	if (!size) {
-		r = vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
-		WARN_ON(r < 0);
-	}
+	if (!size)
+		vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
 
 	return 0;
 }
-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
