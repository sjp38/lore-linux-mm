Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 5BB286B0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 04:18:14 -0400 (EDT)
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 10 Jul 2013 09:14:00 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 95A431B08023
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 09:18:09 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6A8HwqY45547664
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 08:17:58 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r6A8I73n005323
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 02:18:08 -0600
Message-ID: <51DD18BD.9090201@de.ibm.com>
Date: Wed, 10 Jul 2013 10:18:05 +0200
From: Christian Borntraeger <borntraeger@de.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] PF: Async page fault support on s390
References: <1373378207-10451-1-git-send-email-dingel@linux.vnet.ibm.com> <1373378207-10451-5-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1373378207-10451-5-git-send-email-dingel@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: Gleb Natapov <gleb@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Xiantao Zhang <xiantao.zhang@intel.com>, Alexander Graf <agraf@suse.de>, Christoffer Dall <christoffer.dall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Ralf Baechle <ralf@linux-mips.org>, kvm@vger.kernel.org, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/07/13 15:56, Dominik Dingel wrote:
> This patch enables async page faults for s390 kvm guests.
> It provides the userspace API to enable, disable or get the status of this
> feature. Also it includes the diagnose code, called by the guest to enable
> async page faults.
> 
> The async page faults will use an already existing guest interface for this
> purpose, as described in "CP Programming Services (SC24-6084)".
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>

Re-reading this patch again, found some thing that you should take 
care of (nothing major, just small details). Sorry for not seeing them
earlier.

[...]
> +	case 1: /* CANCEL */
> +		if (vcpu->run->s.regs.gprs[rx] & 7)
> +			return kvm_s390_inject_program_int(vcpu, PGM_ADDRESSING);
> +
> +		vcpu->run->s.regs.gprs[ry] = 0;
> +
> +		if (vcpu->arch.pfault_token == KVM_S390_PFAULT_TOKEN_INVALID)
> +			vcpu->run->s.regs.gprs[ry] = 1;
> +
> +		vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
> +		rc = 0;
> +		break;

Dont we need a kvm_clear_async_pf_completion_queue(vcpu) or similar here as well?
The cancel function is supposed to purge all outstanding requests (those were no 
completion signal was made pending yet)

[...]
> @@ -264,6 +292,7 @@ void kvm_arch_vcpu_destroy(struct kvm_vcpu *vcpu)
>  {
>  	VCPU_EVENT(vcpu, 3, "%s", "free cpu");
>  	trace_kvm_s390_destroy_vcpu(vcpu->vcpu_id);
> +	kvm_clear_async_pf_completion_queue(vcpu);
>  	if (!kvm_is_ucontrol(vcpu->kvm)) {
>  		clear_bit(63 - vcpu->vcpu_id,
>  			  (unsigned long *) &vcpu->kvm->arch.sca->mcn);
> @@ -313,6 +342,9 @@ void kvm_arch_destroy_vm(struct kvm *kvm)
>  /* Section: vcpu related */
>  int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
>  {
> +	vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
> +	kvm_clear_async_pf_completion_queue(vcpu);
> +	kvm_async_pf_wakeup_all(vcpu);
>  	if (kvm_is_ucontrol(vcpu->kvm)) {
>  		vcpu->arch.gmap = gmap_alloc(current->mm);
>  		if (!vcpu->arch.gmap)

We should also reset pfault handling for CPU reset, no?

> @@ -691,10 +723,75 @@ static void kvm_arch_fault_in_sync(struct kvm_vcpu *vcpu)
>  	up_read(&mm->mmap_sem);
>  }
> 
> +static void __kvm_inject_pfault_token(struct kvm_vcpu *vcpu, bool start_token,
> +				      unsigned long token)
> +{
> +	struct kvm_s390_interrupt inti;
> +	inti.type = start_token ? KVM_S390_INT_PFAULT_INIT :
> +				  KVM_S390_INT_PFAULT_DONE;
> +	inti.parm64 = token;
> +	if (kvm_s390_inject_vcpu(vcpu, &inti))
> +		WARN(1, "pfault interrupt injection failed");
> +}

The PFAULT_DONE is architectured as a floating interrupt (can happen
on other CPUs).

[...]
> --- a/arch/s390/kvm/sigp.c
> +++ b/arch/s390/kvm/sigp.c
> @@ -187,6 +187,8 @@ static int __sigp_set_arch(struct kvm_vcpu *vcpu, u32 parameter)
>  {
>  	int rc;
> 
> +	vcpu->arch.pfault_token = KVM_S390_PFAULT_TOKEN_INVALID;
> +

sigp set architecture affects all cpus, so we must reset pfault via
kvm_for_each_vcpu, I guess.

Otherwise patch looks good. I guess only one more iteration
Christian



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
