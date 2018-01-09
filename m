Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 24ECB6B027B
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:15 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id t88so11126417pfg.17
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u196sor3316240pgc.375.2018.01.09.12.57.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:57:13 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 33/36] kvm: x86: fix KVM_XEN_HVM_CONFIG ioctl
Date: Tue,  9 Jan 2018 12:56:02 -0800
Message-Id: <1515531365-37423-34-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Paolo Bonzini <pbonzini@redhat.com>, kernel-hardening@lists.openwall.com, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org

From: Paolo Bonzini <pbonzini@redhat.com>

This ioctl is obsolete (it was used by Xenner as far as I know) but
still let's not break it gratuitously...  Its handler is copying
directly into struct kvm.  Go through a bounce buffer instead, with
the added benefit that we can actually do something useful with the
flags argument---the previous code was exiting with -EINVAL but still
doing the copy.

This technically is a userspace ABI breakage, but since no one should be
using the ioctl, it's a good occasion to see if someone actually
complains.

Cc: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 arch/x86/kvm/x86.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index eee8e7faf1af..6c16461e3a86 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -4238,13 +4238,14 @@ long kvm_arch_vm_ioctl(struct file *filp,
 		mutex_unlock(&kvm->lock);
 		break;
 	case KVM_XEN_HVM_CONFIG: {
+		struct kvm_xen_hvm_config xhc;
 		r = -EFAULT;
-		if (copy_from_user(&kvm->arch.xen_hvm_config, argp,
-				   sizeof(struct kvm_xen_hvm_config)))
+		if (copy_from_user(&xhc, argp, sizeof(xhc)))
 			goto out;
 		r = -EINVAL;
-		if (kvm->arch.xen_hvm_config.flags)
+		if (xhc.flags)
 			goto out;
+		memcpy(&kvm->arch.xen_hvm_config, &xhc, sizeof(xhc));
 		r = 0;
 		break;
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
