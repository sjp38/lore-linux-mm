Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A03456B0036
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 04:50:11 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so6020553pdj.15
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 01:50:10 -0700 (PDT)
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Subject: [PATCH v9 10/13] KVM: PPC: remove warning from kvmppc_core_destroy_vm
Date: Wed, 28 Aug 2013 18:49:57 +1000
Message-Id: <1377679797-3744-1-git-send-email-aik@ozlabs.ru>
In-Reply-To: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
References: <1377679070-3515-1-git-send-email-aik@ozlabs.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linuxppc-dev@lists.ozlabs.org
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Graf <agraf@suse.de>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org

Book3S KVM implements in-kernel TCE tables via kvmppc_spapr_tce_table
structs list (created per KVM). Entries in the list are per LIOBN
(logical bus number) and have a TCE table so DMA hypercalls (such as
H_PUT_TCE) can convert LIOBN to a TCE table.

The entry in the list is created via KVM_CREATE_SPAPR_TCE ioctl which
returns an anonymous fd. This fd is used to map the TCE table to the user
space and it also defines the lifetime of the TCE table in the kernel.
Every list item also hold the link to KVM so when KVM is about to be
destroyed, all kvmppc_spapr_tce_table objects are expected to be
released and removed from the global list. And this is what the warning
verifies.

The upcoming support of VFIO IOMMU will extend kvmppc_spapr_tce_table use.
Unlike emulated devices, it will create kvmppc_spapr_tce_table structs
via new KVM device API which opens an anonymous fd
(as KVM_CREATE_SPAPR_TCE) but the release callback does not call
KVM Device's destroy callback immediately. Instead, KVM devices destruction
is postponed this till KVM destruction but this happens after arch-specific
KVM destroy function so the warning does a false alarm.

This removes the warning as it never happens in real life and there is no
any obvious place to put it.

Signed-off-by: Alexey Kardashevskiy <aik@ozlabs.ru>
---
 arch/powerpc/kvm/book3s_hv.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/powerpc/kvm/book3s_hv.c b/arch/powerpc/kvm/book3s_hv.c
index 9e823ad..5f15ff7 100644
--- a/arch/powerpc/kvm/book3s_hv.c
+++ b/arch/powerpc/kvm/book3s_hv.c
@@ -1974,7 +1974,6 @@ void kvmppc_core_destroy_vm(struct kvm *kvm)
 	kvmppc_rtas_tokens_free(kvm);
 
 	kvmppc_free_hpt(kvm);
-	WARN_ON(!list_empty(&kvm->arch.spapr_tce_tables));
 }
 
 /* These are stubs for now */
-- 
1.8.4.rc4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
