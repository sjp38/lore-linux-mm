Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97CB86B0262
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:45:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id x79so46711529lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:45:49 -0700 (PDT)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id y206si7992756lff.259.2016.10.13.03.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 03:45:48 -0700 (PDT)
Received: by mail-lf0-x244.google.com with SMTP id x23so6271497lfi.1
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:45:48 -0700 (PDT)
Subject: Re: [RFC PATCH v1 21/28] KVM: introduce KVM_SEV_ISSUE_CMD ioctl
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190849706.9523.17127624683768628621.stgit@brijesh-build-machine>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <6a6e6a1a-eec8-c547-553d-7746d65fc182@redhat.com>
Date: Thu, 13 Oct 2016 12:45:42 +0200
MIME-Version: 1.0
In-Reply-To: <147190849706.9523.17127624683768628621.stgit@brijesh-build-machine>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.or



On 23/08/2016 01:28, Brijesh Singh wrote:
> The ioctl will be used by qemu to issue the Secure Encrypted
> Virtualization (SEV) guest commands to transition a guest into
> into SEV-enabled mode.
> 
> a typical usage:
> 
> struct kvm_sev_launch_start start;
> struct kvm_sev_issue_cmd data;
> 
> data.cmd = KVM_SEV_LAUNCH_START;
> data.opaque = &start;
> 
> ret = ioctl(fd, KVM_SEV_ISSUE_CMD, &data);
> 
> On SEV command failure, data.ret_code will contain the firmware error code.

Please modify the ioctl to require the file descriptor for the PSP.  A
program without access to /dev/psp should not be able to use SEV.

> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
> ---
>  arch/x86/include/asm/kvm_host.h |    3 +
>  arch/x86/kvm/x86.c              |   13 ++++
>  include/uapi/linux/kvm.h        |  125 +++++++++++++++++++++++++++++++++++++++
>  3 files changed, 141 insertions(+)
> 
> diff --git a/arch/x86/include/asm/kvm_host.h b/arch/x86/include/asm/kvm_host.h
> index 9b885fc..a94e37d 100644
> --- a/arch/x86/include/asm/kvm_host.h
> +++ b/arch/x86/include/asm/kvm_host.h
> @@ -1040,6 +1040,9 @@ struct kvm_x86_ops {
>  	void (*cancel_hv_timer)(struct kvm_vcpu *vcpu);
>  
>  	void (*setup_mce)(struct kvm_vcpu *vcpu);
> +
> +	int (*sev_issue_cmd)(struct kvm *kvm,
> +			     struct kvm_sev_issue_cmd __user *argp);
>  };
>  
>  struct kvm_arch_async_pf {
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index d6f2f4b..0c0adad 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -3820,6 +3820,15 @@ split_irqchip_unlock:
>  	return r;
>  }
>  
> +static int kvm_vm_ioctl_sev_issue_cmd(struct kvm *kvm,
> +				      struct kvm_sev_issue_cmd __user *argp)
> +{
> +	if (kvm_x86_ops->sev_issue_cmd)
> +		return kvm_x86_ops->sev_issue_cmd(kvm, argp);
> +
> +	return -ENOTTY;
> +}

Please make a more generic vm_ioctl callback.

>  long kvm_arch_vm_ioctl(struct file *filp,
>  		       unsigned int ioctl, unsigned long arg)
>  {
> @@ -4085,6 +4094,10 @@ long kvm_arch_vm_ioctl(struct file *filp,
>  		r = kvm_vm_ioctl_enable_cap(kvm, &cap);
>  		break;
>  	}
> +	case KVM_SEV_ISSUE_CMD: {
> +		r = kvm_vm_ioctl_sev_issue_cmd(kvm, argp);
> +		break;
> +	}
>  	default:
>  		r = kvm_vm_ioctl_assigned_device(kvm, ioctl, arg);
>  	}
> diff --git a/include/uapi/linux/kvm.h b/include/uapi/linux/kvm.h
> index 300ef25..72c18c3 100644
> --- a/include/uapi/linux/kvm.h
> +++ b/include/uapi/linux/kvm.h
> @@ -1274,6 +1274,131 @@ struct kvm_s390_ucas_mapping {
>  /* Available with KVM_CAP_X86_SMM */
>  #define KVM_SMI                   _IO(KVMIO,   0xb7)
>  
> +/* Secure Encrypted Virtualization mode */
> +enum sev_cmd {
> +	KVM_SEV_LAUNCH_START = 0,
> +	KVM_SEV_LAUNCH_UPDATE,
> +	KVM_SEV_LAUNCH_FINISH,
> +	KVM_SEV_GUEST_STATUS,
> +	KVM_SEV_DBG_DECRYPT,
> +	KVM_SEV_DBG_ENCRYPT,
> +	KVM_SEV_RECEIVE_START,
> +	KVM_SEV_RECEIVE_UPDATE,
> +	KVM_SEV_RECEIVE_FINISH,
> +	KVM_SEV_SEND_START,
> +	KVM_SEV_SEND_UPDATE,
> +	KVM_SEV_SEND_FINISH,
> +	KVM_SEV_API_VERSION,
> +	KVM_SEV_NR_MAX,
> +};
> +
> +struct kvm_sev_issue_cmd {
> +	__u32 cmd;
> +	__u64 opaque;
> +	__u32 ret_code;
> +};
> +
> +struct kvm_sev_launch_start {
> +	__u32 handle;
> +	__u32 flags;
> +	__u32 policy;
> +	__u8 nonce[16];
> +	__u8 dh_pub_qx[32];
> +	__u8 dh_pub_qy[32];
> +};
> +
> +struct kvm_sev_launch_update {
> +	__u64	address;
> +	__u32	length;
> +};
> +
> +struct kvm_sev_launch_finish {
> +	__u32 vcpu_count;
> +	__u32 vcpu_length;
> +	__u64 vcpu_mask_addr;
> +	__u32 vcpu_mask_length;
> +	__u8  measurement[32];
> +};
> +
> +struct kvm_sev_guest_status {
> +	__u32 policy;
> +	__u32 state;
> +};
> +
> +struct kvm_sev_dbg_decrypt {
> +	__u64 src_addr;
> +	__u64 dst_addr;
> +	__u32 length;
> +};
> +
> +struct kvm_sev_dbg_encrypt {
> +	__u64 src_addr;
> +	__u64 dst_addr;
> +	__u32 length;
> +};
> +
> +struct kvm_sev_receive_start {
> +	__u32 handle;
> +	__u32 flags;
> +	__u32 policy;
> +	__u8 policy_meas[32];
> +	__u8 wrapped_tek[24];
> +	__u8 wrapped_tik[24];
> +	__u8 ten[16];
> +	__u8 dh_pub_qx[32];
> +	__u8 dh_pub_qy[32];
> +	__u8 nonce[16];
> +};
> +
> +struct kvm_sev_receive_update {
> +	__u8 iv[16];
> +	__u64 address;
> +	__u32 length;
> +};
> +
> +struct kvm_sev_receive_finish {
> +	__u8 measurement[32];
> +};
> +
> +struct kvm_sev_send_start {
> +	__u8 nonce[16];
> +	__u32 policy;
> +	__u8 policy_meas[32];
> +	__u8 wrapped_tek[24];
> +	__u8 wrapped_tik[24];
> +	__u8 ten[16];
> +	__u8 iv[16];
> +	__u32 flags;
> +	__u8 api_major;
> +	__u8 api_minor;
> +	__u32 serial;
> +	__u8 dh_pub_qx[32];
> +	__u8 dh_pub_qy[32];
> +	__u8 pek_sig_r[32];
> +	__u8 pek_sig_s[32];
> +	__u8 cek_sig_r[32];
> +	__u8 cek_sig_s[32];
> +	__u8 cek_pub_qx[32];
> +	__u8 cek_pub_qy[32];
> +	__u8 ask_sig_r[32];
> +	__u8 ask_sig_s[32];
> +	__u32 ncerts;
> +	__u32 cert_length;
> +	__u64 certs_addr;
> +};
> +
> +struct kvm_sev_send_update {
> +	__u32 length;
> +	__u64 src_addr;
> +	__u64 dst_addr;
> +};
> +
> +struct kvm_sev_send_finish {
> +	__u8 measurement[32];
> +};
> +
> +#define KVM_SEV_ISSUE_CMD	_IOWR(KVMIO, 0xb8, struct kvm_sev_issue_cmd)
> +
>  #define KVM_DEV_ASSIGN_ENABLE_IOMMU	(1 << 0)
>  #define KVM_DEV_ASSIGN_PCI_2_3		(1 << 1)
>  #define KVM_DEV_ASSIGN_MASK_INTX	(1 << 2)
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
