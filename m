Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFE36B0299
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 21:19:36 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f8so1743945pgs.9
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 18:19:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g1sor4107963pgf.359.2018.01.10.18.19.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jan 2018 18:19:34 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 35/38] kvm: whitelist struct kvm_vcpu_arch
Date: Wed, 10 Jan 2018 18:03:07 -0800
Message-Id: <1515636190-24061-36-git-send-email-keescook@chromium.org>
In-Reply-To: <1515636190-24061-1-git-send-email-keescook@chromium.org>
References: <1515636190-24061-1-git-send-email-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Paolo Bonzini <pbonzini@redhat.com>, kernel-hardening@lists.openwall.com, Christian Borntraeger <borntraeger@redhat.com>, Christoffer Dall <cdall@linaro.org>, =?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org

From: Paolo Bonzini <pbonzini@redhat.com>

On x86, ARM and s390, struct kvm_vcpu_arch has a usercopy region
that is read and written by the KVM_GET/SET_CPUID2 ioctls (x86)
or KVM_GET/SET_ONE_REG (ARM/s390).  Without whitelisting the area,
KVM is completely broken on those architectures with usercopy hardening
enabled.

For now, allow writing to the entire struct on all architectures.
The KVM tree will not refine this to an architecture-specific
subset of struct kvm_vcpu_arch.

Cc: kernel-hardening@lists.openwall.com
Cc: Kees Cook <keescook@chromium.org>
Cc: Christian Borntraeger <borntraeger@redhat.com>
Cc: Christoffer Dall <cdall@linaro.org>
Cc: Radim KrA?mA!A? <rkrcmar@redhat.com>
Signed-off-by: Paolo Bonzini <pbonzini@redhat.com>
Acked-by: Christoffer Dall <christoffer.dall@linaro.org>
Acked-by: Marc Zyngier <marc.zyngier@arm.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 virt/kvm/kvm_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index c422c10cd1dd..96689967f5c3 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -4029,8 +4029,12 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
 	/* A kmem cache lets us meet the alignment requirements of fx_save. */
 	if (!vcpu_align)
 		vcpu_align = __alignof__(struct kvm_vcpu);
-	kvm_vcpu_cache = kmem_cache_create("kvm_vcpu", vcpu_size, vcpu_align,
-					   SLAB_ACCOUNT, NULL);
+	kvm_vcpu_cache =
+		kmem_cache_create_usercopy("kvm_vcpu", vcpu_size, vcpu_align,
+					   SLAB_ACCOUNT,
+					   offsetof(struct kvm_vcpu, arch),
+					   sizeof_field(struct kvm_vcpu, arch),
+					   NULL);
 	if (!kvm_vcpu_cache) {
 		r = -ENOMEM;
 		goto out_free_3;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
