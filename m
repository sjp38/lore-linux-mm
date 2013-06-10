Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id BA63C6B0037
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 08:03:58 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dingel@linux.vnet.ibm.com>;
	Mon, 10 Jun 2013 13:00:18 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id AE7071B0805D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 13:03:54 +0100 (BST)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5AC3h3054788264
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 12:03:43 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r5AC3rb8003329
	for <linux-mm@kvack.org>; Mon, 10 Jun 2013 06:03:54 -0600
From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Subject: [PATCH 3/4] PF: Additional flag for direct page fault inject
Date: Mon, 10 Jun 2013 14:03:47 +0200
Message-Id: <1370865828-2053-4-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
References: <1370865828-2053-1-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dominik Dingel <dingel@linux.vnet.ibm.com>

On some architectures, as on s390x we may want to be able to directly inject
notifications to the guest in case of a swapped in page. Also on s390x
there is no need to go from gfn to hva as by calling gmap_fault we already
have the needed address.

Due to a possible race, we now always have to insert the page to the queue.
So if we are not able to schedule the async page, we have to remove it from
the list again. As this is only when we also have to page in synchronously,
the overhead is not really important.

Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/x86/kvm/mmu.c       |  2 +-
 include/linux/kvm_host.h |  3 ++-
 virt/kvm/async_pf.c      | 33 +++++++++++++++++++++++++++------
 3 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 956ca35..02a49a9 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -3223,7 +3223,7 @@ static int kvm_arch_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn)
 	arch.direct_map = vcpu->arch.mmu.direct_map;
 	arch.cr3 = vcpu->arch.mmu.get_cr3(vcpu);
 
-	return kvm_setup_async_pf(vcpu, gva, gfn, &arch);
+	return kvm_setup_async_pf(vcpu, gva, gfn, &arch, false);
 }
 
 static bool can_do_async_pf(struct kvm_vcpu *vcpu)
diff --git a/include/linux/kvm_host.h b/include/linux/kvm_host.h
index 9bd29ef..a798deb 100644
--- a/include/linux/kvm_host.h
+++ b/include/linux/kvm_host.h
@@ -165,12 +165,13 @@ struct kvm_async_pf {
 	struct kvm_arch_async_pf arch;
 	struct page *page;
 	bool done;
+	bool direct_inject;
 };
 
 void kvm_clear_async_pf_completion_queue(struct kvm_vcpu *vcpu);
 void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu);
 int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
-		       struct kvm_arch_async_pf *arch);
+		       struct kvm_arch_async_pf *arch, bool is_direct);
 int kvm_async_pf_wakeup_all(struct kvm_vcpu *vcpu);
 #endif
 
diff --git a/virt/kvm/async_pf.c b/virt/kvm/async_pf.c
index ea475cd..a4a6483 100644
--- a/virt/kvm/async_pf.c
+++ b/virt/kvm/async_pf.c
@@ -73,9 +73,17 @@ static void async_pf_execute(struct work_struct *work)
 	unuse_mm(mm);
 
 	spin_lock(&vcpu->async_pf.lock);
-	list_add_tail(&apf->link, &vcpu->async_pf.done);
 	apf->page = page;
 	apf->done = true;
+	if (apf->direct_inject) {
+		kvm_arch_async_page_present(vcpu, apf);
+		list_del(&apf->queue);
+		vcpu->async_pf.queued--;
+		kvm_release_page_clean(apf->page);
+		kmem_cache_free(async_pf_cache, apf);
+	} else {
+		list_add_tail(&apf->link, &vcpu->async_pf.done);
+	}
 	spin_unlock(&vcpu->async_pf.lock);
 
 	/*
@@ -145,7 +153,7 @@ void kvm_check_async_pf_completion(struct kvm_vcpu *vcpu)
 }
 
 int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
-		       struct kvm_arch_async_pf *arch)
+		       struct kvm_arch_async_pf *arch, bool is_direct)
 {
 	struct kvm_async_pf *work;
 
@@ -165,13 +173,24 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
 	work->page = NULL;
 	work->done = false;
 	work->vcpu = vcpu;
-	work->gva = gva;
-	work->addr = gfn_to_hva(vcpu->kvm, gfn);
+	if (gfn == -1) {
+		work->gva = -1;
+		work->addr = gva;
+	} else {
+		work->gva = gva;
+		work->addr = gfn_to_hva(vcpu->kvm, gfn);
+	}
+	work->direct_inject = is_direct;
 	work->arch = *arch;
 	work->mm = current->mm;
 	atomic_inc(&work->mm->mm_count);
 	kvm_get_kvm(work->vcpu->kvm);
 
+	spin_lock(&vcpu->async_pf.lock);
+	list_add_tail(&work->queue, &vcpu->async_pf.queue);
+	vcpu->async_pf.queued++;
+	spin_unlock(&vcpu->async_pf.lock);
+
 	/* this can't really happen otherwise gfn_to_pfn_async
 	   would succeed */
 	if (unlikely(kvm_is_error_hva(work->addr)))
@@ -181,11 +200,13 @@ int kvm_setup_async_pf(struct kvm_vcpu *vcpu, gva_t gva, gfn_t gfn,
 	if (!schedule_work(&work->work))
 		goto retry_sync;
 
-	list_add_tail(&work->queue, &vcpu->async_pf.queue);
-	vcpu->async_pf.queued++;
 	kvm_arch_async_page_not_present(vcpu, work);
 	return 1;
 retry_sync:
+	spin_lock(&vcpu->async_pf.lock);
+	list_del(&work->queue);
+	vcpu->async_pf.queued--;
+	spin_unlock(&vcpu->async_pf.lock);
 	kvm_put_kvm(work->vcpu->kvm);
 	mmdrop(work->mm);
 	kmem_cache_free(async_pf_cache, work);
-- 
1.8.1.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
