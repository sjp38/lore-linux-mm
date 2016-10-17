Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5157F6B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 16:15:35 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id n3so107946643lfn.5
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:15:35 -0700 (PDT)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTPS id qt6si43551753wjc.220.2016.10.17.13.15.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 13:15:33 -0700 (PDT)
Date: Mon, 17 Oct 2016 16:14:56 -0400 (EDT)
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <28535418.4145222.1476735296810.JavaMail.zimbra@redhat.com>
In-Reply-To: <59369ed7-9d35-baad-e0a9-ce4a62bc30bb@amd.com>
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine> <147190849706.9523.17127624683768628621.stgit@brijesh-build-machine> <6a6e6a1a-eec8-c547-553d-7746d65fc182@redhat.com> <59369ed7-9d35-baad-e0a9-ce4a62bc30bb@amd.com>
Subject: Re: [RFC PATCH v1 21/28] KVM: introduce KVM_SEV_ISSUE_CMD ioctl
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brijesh Singh <brijesh.singh@amd.com>
Cc: simon guinot <simon.guinot@sequanux.org>, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus walleij <linus.walleij@linaro.org>, linux-mm@kvack.org, paul gortmaker <paul.gortmaker@windriver.com>, hpa@zytor.com, dan j williams <dan.j.williams@intel.com>, aarcange@redhat.com, sfr@canb.auug.org.au, andriy shevchenko <andriy.shevchenko@linux.intel.com>, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross zwisler <ross.zwisler@linux.intel.com>, bp@suse.de, dyoung@redhat.com, thomas lendacky <thomas.lendacky@amd.com>, jroedel@suse.de, keescook@chromium.org, toshi kani <toshi.kani@hpe.com>, mathieu desnoyers <mathieu.desnoyers@efficios.com>, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.or

> I am not sure if I fully understand this feedback. Let me summaries what
> we have right now.
> 
> At highest level SEV key management commands are divided into two sections:
> 
> - platform  management : commands used during platform provisioning. PSP
> drv provides ioctl's for these commands. Qemu will not use these
> ioctl's, i believe these ioctl will be used by other tools.
> 
> - guest management: command used during guest life cycle. PSP drv
> exports various function and KVM drv calls these function when it
> receives the SEV_ISSUE_CMD ioctl from qemu.
> 
> If I understanding correctly then you are recommending that instead of
> exporting various functions from PSP drv we should expose one function
> for the all the guest command handling (something like this).

My understanding is that a user could exhaust the ASIDs for encrypted
VMs if it was allowed to start an arbitrary number of KVM guests.  So
we would need some kind of control.  Is this correct?

If so, does /dev/psp provide any functionality that you believe is
dangerous for the KVM userspace (which runs in a very confined
environment)?  Is this functionality blocked through capability
checks?

Thanks,

Paolo


> int psp_issue_cmd_external_user(struct file *filep,
> 			    	int cmd, unsigned long addr,
> 			    	int *psp_ret)
> {
> 	/* here we check to ensure that file->f_ops is a valid
> 	 * psp instance.
>           */
> 	if (filep->f_ops != &psp_fops)
> 		return -EINVAL;
> 
> 	/* handle the command */
> 	return psp_issue_cmd (cmd, addr, timeout, psp_ret);
> }
> 
> In KVM driver use something like this to invoke the PSP command handler.
> 
> int kvm_sev_psp_cmd (struct kvm_sev_issue_cmd *input,
> 		     unsigned long data)
> {
> 	int ret;
> 	struct fd f;
> 
> 	f = fdget(input->psp_fd);
> 	if (!f.file)
> 		return -EBADF;
> 	....
> 
> 	psp_issue_cmd_external_user(f.file, input->cmd,
> 				    data, &input->psp_ret);
> 	....
> }
> 
> Please let me know if I understood this correctly.
> 
> >> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
> >> ---
> >>  arch/x86/include/asm/kvm_host.h |    3 +
> >>  arch/x86/kvm/x86.c              |   13 ++++
> >>  include/uapi/linux/kvm.h        |  125
> >>  +++++++++++++++++++++++++++++++++++++++
> >>  3 files changed, 141 insertions(+)
> >>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
