Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 114126B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 04:12:09 -0400 (EDT)
Message-ID: <4A794008.6030204@redhat.com>
Date: Wed, 05 Aug 2009 11:17:12 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <4A793B92.9040204@redhat.com>
In-Reply-To: <4A793B92.9040204@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------070107090206080801090808"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>Andrea Arcangeli <aarcange@redhat.com>, KVM list <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070107090206080801090808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 08/05/2009 10:58 AM, Avi Kivity wrote:
> On 08/05/2009 05:40 AM, Wu Fengguang wrote:
>> Greetings,
>>
>> Jeff Dike found that many KVM pages are being refaulted in 2.6.29:
>>
>> "Lots of pages between discarded due to memory pressure only to be
>> faulted back in soon after. These pages are nearly all stack pages.
>> This is not consistent - sometimes there are relatively few such pages
>> and they are spread out between processes."
>>
>> The refaults can be drastically reduced by the following patch, which
>> respects the referenced bit of all anonymous pages (including the KVM
>> pages).
>>
>> However it risks reintroducing the problem addressed by commit 7e9cd4842
>> (fix reclaim scalability problem by ignoring the referenced bit,
>> mainly the pte young bit). I wonder if there are better solutions?
>
> How do you distinguish between kvm pages and non-kvm anonymous pages?  
> More importantly, why should you?
>
> Jeff, do you see the refaults on Nehalem systems?  If so, that's 
> likely due to the lack of an accessed bit on EPT pagetables.  It would 
> be interesting to compare with Barcelona  (which does).
>
> If that's indeed the case, we can have the EPT ageing mechanism give 
> pages a bit more time around by using an available bit in the EPT PTEs 
> to return accessed on the first pass and not-accessed on the second.
>

The attached patch implements this.

-- 
error compiling committee.c: too many arguments to function


--------------070107090206080801090808
Content-Type: text/x-patch;
 name="ept-emulate-accessed-bit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ept-emulate-accessed-bit.patch"

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 7b53614..310938a 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -195,6 +195,7 @@ static u64 __read_mostly shadow_x_mask;	/* mutual exclusive with nx_mask */
 static u64 __read_mostly shadow_user_mask;
 static u64 __read_mostly shadow_accessed_mask;
 static u64 __read_mostly shadow_dirty_mask;
+static int __read_mostly shadow_accessed_shift;
 
 static inline u64 rsvd_bits(int s, int e)
 {
@@ -219,6 +220,8 @@ void kvm_mmu_set_mask_ptes(u64 user_mask, u64 accessed_mask,
 {
 	shadow_user_mask = user_mask;
 	shadow_accessed_mask = accessed_mask;
+	shadow_accessed_shift
+		= find_first_bit((void *)&shadow_accessed_mask, 64);
 	shadow_dirty_mask = dirty_mask;
 	shadow_nx_mask = nx_mask;
 	shadow_x_mask = x_mask;
@@ -817,11 +820,11 @@ static int kvm_age_rmapp(struct kvm *kvm, unsigned long *rmapp)
 	while (spte) {
 		int _young;
 		u64 _spte = *spte;
-		BUG_ON(!(_spte & PT_PRESENT_MASK));
-		_young = _spte & PT_ACCESSED_MASK;
+		BUG_ON(!(_spte & shadow_accessed_mask));
+		_young = _spte & shadow_accessed_mask;
 		if (_young) {
 			young = 1;
-			clear_bit(PT_ACCESSED_SHIFT, (unsigned long *)spte);
+			clear_bit(shadow_accessed_shift, (unsigned long *)spte);
 		}
 		spte = rmap_next(kvm, rmapp, spte);
 	}
@@ -2572,7 +2575,7 @@ static void kvm_mmu_access_page(struct kvm_vcpu *vcpu, gfn_t gfn)
 	    && shadow_accessed_mask
 	    && !(*spte & shadow_accessed_mask)
 	    && is_shadow_present_pte(*spte))
-		set_bit(PT_ACCESSED_SHIFT, (unsigned long *)spte);
+		set_bit(shadow_accessed_shift, (unsigned long *)spte);
 }
 
 void kvm_mmu_pte_write(struct kvm_vcpu *vcpu, gpa_t gpa,
diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
index 0ba706e..bc99367 100644
--- a/arch/x86/kvm/vmx.c
+++ b/arch/x86/kvm/vmx.c
@@ -4029,7 +4029,7 @@ static int __init vmx_init(void)
 		bypass_guest_pf = 0;
 		kvm_mmu_set_base_ptes(VMX_EPT_READABLE_MASK |
 			VMX_EPT_WRITABLE_MASK);
-		kvm_mmu_set_mask_ptes(0ull, 0ull, 0ull, 0ull,
+		kvm_mmu_set_mask_ptes(0ull, 1ull << 63, 0ull, 0ull,
 				VMX_EPT_EXECUTABLE_MASK);
 		kvm_enable_tdp();
 	} else

--------------070107090206080801090808--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
