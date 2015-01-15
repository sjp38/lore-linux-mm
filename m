Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 788F16B006E
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 03:58:17 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so13575262wgh.6
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 00:58:17 -0800 (PST)
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com. [195.75.94.107])
        by mx.google.com with ESMTPS id uo9si1538843wjc.89.2015.01.15.00.58.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 00:58:16 -0800 (PST)
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Thu, 15 Jan 2015 08:58:15 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 22601219005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:57:41 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t0F8wDqJ52756708
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 08:58:13 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t0F3sKLg013648
	for <linux-mm@kvack.org>; Wed, 14 Jan 2015 22:54:21 -0500
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 1/8] ppc/kvm: Replace ACCESS_ONCE with READ_ONCE
Date: Thu, 15 Jan 2015 09:58:27 +0100
Message-Id: <1421312314-72330-2-git-send-email-borntraeger@de.ibm.com>
In-Reply-To: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
References: <1421312314-72330-1-git-send-email-borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arch@vger.kernel.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Christian Borntraeger <borntraeger@de.ibm.com>

ACCESS_ONCE does not work reliably on non-scalar types. For
example gcc 4.6 and 4.7 might remove the volatile tag for such
accesses during the SRA (scalar replacement of aggregates) step
(https://gcc.gnu.org/bugzilla/show_bug.cgi?id=58145)

Change the ppc/kvm code to replace ACCESS_ONCE with READ_ONCE.

Signed-off-by: Christian Borntraeger <borntraeger@de.ibm.com>
---
 arch/powerpc/kvm/book3s_hv_rm_xics.c |  8 ++++----
 arch/powerpc/kvm/book3s_xics.c       | 16 ++++++++--------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/arch/powerpc/kvm/book3s_hv_rm_xics.c b/arch/powerpc/kvm/book3s_hv_rm_xics.c
index 7b066f6..7c22997 100644
--- a/arch/powerpc/kvm/book3s_hv_rm_xics.c
+++ b/arch/powerpc/kvm/book3s_hv_rm_xics.c
@@ -152,7 +152,7 @@ static void icp_rm_down_cppr(struct kvmppc_xics *xics, struct kvmppc_icp *icp,
 	 * in virtual mode.
 	 */
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		/* Down_CPPR */
 		new_state.cppr = new_cppr;
@@ -211,7 +211,7 @@ unsigned long kvmppc_rm_h_xirr(struct kvm_vcpu *vcpu)
 	 * pending priority
 	 */
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		xirr = old_state.xisr | (((u32)old_state.cppr) << 24);
 		if (!old_state.xisr)
@@ -277,7 +277,7 @@ int kvmppc_rm_h_ipi(struct kvm_vcpu *vcpu, unsigned long server,
 	 * whenever the MFRR is made less favored.
 	 */
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		/* Set_MFRR */
 		new_state.mfrr = mfrr;
@@ -352,7 +352,7 @@ int kvmppc_rm_h_cppr(struct kvm_vcpu *vcpu, unsigned long cppr)
 	icp_rm_clr_vcpu_irq(icp->vcpu);
 
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		reject = 0;
 		new_state.cppr = cppr;
diff --git a/arch/powerpc/kvm/book3s_xics.c b/arch/powerpc/kvm/book3s_xics.c
index 807351f..a4a8d9f 100644
--- a/arch/powerpc/kvm/book3s_xics.c
+++ b/arch/powerpc/kvm/book3s_xics.c
@@ -327,7 +327,7 @@ static bool icp_try_to_deliver(struct kvmppc_icp *icp, u32 irq, u8 priority,
 		 icp->server_num);
 
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		*reject = 0;
 
@@ -512,7 +512,7 @@ static void icp_down_cppr(struct kvmppc_xics *xics, struct kvmppc_icp *icp,
 	 * in virtual mode.
 	 */
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		/* Down_CPPR */
 		new_state.cppr = new_cppr;
@@ -567,7 +567,7 @@ static noinline unsigned long kvmppc_h_xirr(struct kvm_vcpu *vcpu)
 	 * pending priority
 	 */
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		xirr = old_state.xisr | (((u32)old_state.cppr) << 24);
 		if (!old_state.xisr)
@@ -634,7 +634,7 @@ static noinline int kvmppc_h_ipi(struct kvm_vcpu *vcpu, unsigned long server,
 	 * whenever the MFRR is made less favored.
 	 */
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		/* Set_MFRR */
 		new_state.mfrr = mfrr;
@@ -679,7 +679,7 @@ static int kvmppc_h_ipoll(struct kvm_vcpu *vcpu, unsigned long server)
 		if (!icp)
 			return H_PARAMETER;
 	}
-	state = ACCESS_ONCE(icp->state);
+	state = READ_ONCE(icp->state);
 	kvmppc_set_gpr(vcpu, 4, ((u32)state.cppr << 24) | state.xisr);
 	kvmppc_set_gpr(vcpu, 5, state.mfrr);
 	return H_SUCCESS;
@@ -721,7 +721,7 @@ static noinline void kvmppc_h_cppr(struct kvm_vcpu *vcpu, unsigned long cppr)
 				      BOOK3S_INTERRUPT_EXTERNAL_LEVEL);
 
 	do {
-		old_state = new_state = ACCESS_ONCE(icp->state);
+		old_state = new_state = READ_ONCE(icp->state);
 
 		reject = 0;
 		new_state.cppr = cppr;
@@ -885,7 +885,7 @@ static int xics_debug_show(struct seq_file *m, void *private)
 		if (!icp)
 			continue;
 
-		state.raw = ACCESS_ONCE(icp->state.raw);
+		state.raw = READ_ONCE(icp->state.raw);
 		seq_printf(m, "cpu server %#lx XIRR:%#x PPRI:%#x CPPR:%#x MFRR:%#x OUT:%d NR:%d\n",
 			   icp->server_num, state.xisr,
 			   state.pending_pri, state.cppr, state.mfrr,
@@ -1082,7 +1082,7 @@ int kvmppc_xics_set_icp(struct kvm_vcpu *vcpu, u64 icpval)
 	 * the ICS states before the ICP states.
 	 */
 	do {
-		old_state = ACCESS_ONCE(icp->state);
+		old_state = READ_ONCE(icp->state);
 
 		if (new_state.mfrr <= old_state.mfrr) {
 			resend = false;
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
