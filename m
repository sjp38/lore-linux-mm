Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15C286B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 11:41:51 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id v21so17613119iob.0
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 08:41:51 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id t73si6313775ioe.219.2017.12.22.08.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 08:41:50 -0800 (PST)
Subject: Re: [RFC PATCH v4 09/18] kvm: hook in the VM introspection subsystem
References: <20171218190642.7790-1-alazar@bitdefender.com>
 <20171218190642.7790-10-alazar@bitdefender.com>
From: Patrick Colp <patrick.colp@oracle.com>
Message-ID: <91dcdfae-22c3-5d77-6864-5c136cf58e01@oracle.com>
Date: Fri, 22 Dec 2017 11:36:39 -0500
MIME-Version: 1.0
In-Reply-To: <20171218190642.7790-10-alazar@bitdefender.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Adalber_Laz=c4=83r?= <alazar@bitdefender.com>, kvm@vger.kernel.org
Cc: linux-mm@kvack.org, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>

On 2017-12-18 02:06 PM, Adalber LazA?r wrote:
> From: Adalbert Lazar <alazar@bitdefender.com>
> 
> Handle the new KVM_INTROSPECTION ioctl and pass the socket from QEMU to
> the KVMI subsystem. Notify KVMI on vCPU create/destroy and VM destroy
> events. Also, the EPT AD bits feature is disabled by this patch.
> 
> Signed-off-by: Adalbert LazA?r <alazar@bitdefender.com>
> ---
>   arch/x86/kvm/vmx.c  |  3 ++-
>   virt/kvm/kvm_main.c | 19 +++++++++++++++++++
>   2 files changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/kvm/vmx.c b/arch/x86/kvm/vmx.c
> index 093a2e1f7ea6..c03580abf9e8 100644
> --- a/arch/x86/kvm/vmx.c
> +++ b/arch/x86/kvm/vmx.c
> @@ -34,6 +34,7 @@
>   #include <linux/tboot.h>
>   #include <linux/hrtimer.h>
>   #include <linux/frame.h>
> +#include <linux/kvmi.h>
>   #include "kvm_cache_regs.h"
>   #include "x86.h"
>   
> @@ -6785,7 +6786,7 @@ static __init int hardware_setup(void)
>   	    !cpu_has_vmx_invept_global())
>   		enable_ept = 0;
>   
> -	if (!cpu_has_vmx_ept_ad_bits() || !enable_ept)
> +	if (!cpu_has_vmx_ept_ad_bits() || !enable_ept || kvmi_is_present())
>   		enable_ept_ad_bits = 0;
>   
>   	if (!cpu_has_vmx_unrestricted_guest() || !enable_ept)
> diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
> index 210bf820385a..7895d490bd71 100644
> --- a/virt/kvm/kvm_main.c
> +++ b/virt/kvm/kvm_main.c
> @@ -51,6 +51,7 @@
>   #include <linux/slab.h>
>   #include <linux/sort.h>
>   #include <linux/bsearch.h>
> +#include <linux/kvmi.h>
>   
>   #include <asm/processor.h>
>   #include <asm/io.h>
> @@ -298,6 +299,9 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *kvm, unsigned id)
>   	r = kvm_arch_vcpu_init(vcpu);
>   	if (r < 0)
>   		goto fail_free_run;
> +
> +	kvmi_vcpu_init(vcpu);
> +
>   	return 0;
>   
>   fail_free_run:
> @@ -315,6 +319,7 @@ void kvm_vcpu_uninit(struct kvm_vcpu *vcpu)
>   	 * descriptors are already gone.
>   	 */
>   	put_pid(rcu_dereference_protected(vcpu->pid, 1));
> +	kvmi_vcpu_uninit(vcpu);
>   	kvm_arch_vcpu_uninit(vcpu);
>   	free_page((unsigned long)vcpu->run);
>   }
> @@ -711,6 +716,7 @@ static void kvm_destroy_vm(struct kvm *kvm)
>   	int i;
>   	struct mm_struct *mm = kvm->mm;
>   
> +	kvmi_destroy_vm(kvm);
>   	kvm_uevent_notify_change(KVM_EVENT_DESTROY_VM, kvm);
>   	kvm_destroy_vm_debugfs(kvm);
>   	kvm_arch_sync_events(kvm);
> @@ -3118,6 +3124,15 @@ static long kvm_vm_ioctl(struct file *filp,
>   	case KVM_CHECK_EXTENSION:
>   		r = kvm_vm_ioctl_check_extension_generic(kvm, arg);
>   		break;
> +	case KVM_INTROSPECTION: {
> +		struct kvm_introspection i;
> +
> +		r = -EFAULT;
> +		if (copy_from_user(&i, argp, sizeof(i)) || !kvmi_hook(kvm, &i))
> +			goto out;

Looking at this, I wonder if it would actually make more sense to have 
kvmi_hook() return an int? This can then be broken into two separate if 
checks. This way would match the rest of the kvm_vm_ioctl() code a bit 
better.

> +		r = 0;
> +		break;
> +	}
>   	default:
>   		r = kvm_arch_vm_ioctl(filp, ioctl, arg);
>   	}
> @@ -4072,6 +4087,9 @@ int kvm_init(void *opaque, unsigned vcpu_size, unsigned vcpu_align,
>   	r = kvm_vfio_ops_init();
>   	WARN_ON(r);
>   
> +	r = kvmi_init();
> +	WARN_ON(r);
> +
>   	return 0;
>   
>   out_undebugfs:
> @@ -4100,6 +4118,7 @@ EXPORT_SYMBOL_GPL(kvm_init);
>   
>   void kvm_exit(void)
>   {
> +	kvmi_uninit();
>   	debugfs_remove_recursive(kvm_debugfs_dir);
>   	misc_deregister(&kvm_dev);
>   	kmem_cache_destroy(kvm_vcpu_cache);
> 


Patrick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
