Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFC46B0069
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 15:32:18 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g49so2457346qtc.7
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 12:32:18 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0070.outbound.protection.outlook.com. [104.47.33.70])
        by mx.google.com with ESMTPS id 33si4846324qtq.133.2016.10.18.12.32.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 12:32:17 -0700 (PDT)
Subject: Re: [RFC PATCH v1 21/28] KVM: introduce KVM_SEV_ISSUE_CMD ioctl
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190849706.9523.17127624683768628621.stgit@brijesh-build-machine>
 <6a6e6a1a-eec8-c547-553d-7746d65fc182@redhat.com>
 <59369ed7-9d35-baad-e0a9-ce4a62bc30bb@amd.com>
 <28535418.4145222.1476735296810.JavaMail.zimbra@redhat.com>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <014b833f-a6e6-fcde-ecc5-2109bf2a0382@amd.com>
Date: Tue, 18 Oct 2016 14:32:07 -0500
MIME-Version: 1.0
In-Reply-To: <28535418.4145222.1476735296810.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: brijesh.singh@amd.com, simon guinot <simon.guinot@sequanux.org>, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus walleij <linus.walleij@linaro.org>, linux-mm@kvack.org, paul gortmaker <paul.gortmaker@windriver.com>, hpa@zytor.com, dan j williams <dan.j.williams@intel.com>, aarcange@redhat.com, sfr@canb.auug.org.au, andriy shevchenko <andriy.shevchenko@linux.intel.com>, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross zwisler <ross.zwisler@linux.intel.com>, bp@suse.de, dyoung@redhat.com, thomas
 lendacky <thomas.lendacky@amd.com>, jroedel@suse.de, keescook@chromium.org, toshi kani <toshi.kani@hpe.com>, mathieu desnoyers <mathieu.desnoyers@efficios.com>, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.or

Hi Paolo,

On 10/17/2016 03:14 PM, Paolo Bonzini wrote:
>> I am not sure if I fully understand this feedback. Let me summaries what
>> we have right now.
>>
>> At highest level SEV key management commands are divided into two sections:
>>
>> - platform  management : commands used during platform provisioning. PSP
>> drv provides ioctl's for these commands. Qemu will not use these
>> ioctl's, i believe these ioctl will be used by other tools.
>>
>> - guest management: command used during guest life cycle. PSP drv
>> exports various function and KVM drv calls these function when it
>> receives the SEV_ISSUE_CMD ioctl from qemu.
>>
>> If I understanding correctly then you are recommending that instead of
>> exporting various functions from PSP drv we should expose one function
>> for the all the guest command handling (something like this).
>
> My understanding is that a user could exhaust the ASIDs for encrypted
> VMs if it was allowed to start an arbitrary number of KVM guests.  So
> we would need some kind of control.  Is this correct?
>

Yes, there is limited number of ASIDs for encrypted VMs. Do we need to 
pass the psp_fd into SEV_ISSUE_CMD ioctl or can we handle it from Qemu 
itself ? e.g when user asks to transition a guest into SEV-enabled mode 
then before calling LAUNCH_START Qemu tries to open /dev/psp device. If 
open() returns success then we know user has permission to communicate 
with PSP firmware. Please let me know if I am missing something.

> If so, does /dev/psp provide any functionality that you believe is
> dangerous for the KVM userspace (which runs in a very confined
> environment)?  Is this functionality blocked through capability
> checks?
>

I do not see /dev/psp providing anything which would be dangerous to KVM 
userspace. It should be safe to access /dev/psp into KVM userspace.

> Thanks,
>
> Paolo
>
>
>> int psp_issue_cmd_external_user(struct file *filep,
>> 			    	int cmd, unsigned long addr,
>> 			    	int *psp_ret)
>> {
>> 	/* here we check to ensure that file->f_ops is a valid
>> 	 * psp instance.
>>           */
>> 	if (filep->f_ops != &psp_fops)
>> 		return -EINVAL;
>>
>> 	/* handle the command */
>> 	return psp_issue_cmd (cmd, addr, timeout, psp_ret);
>> }
>>
>> In KVM driver use something like this to invoke the PSP command handler.
>>
>> int kvm_sev_psp_cmd (struct kvm_sev_issue_cmd *input,
>> 		     unsigned long data)
>> {
>> 	int ret;
>> 	struct fd f;
>>
>> 	f = fdget(input->psp_fd);
>> 	if (!f.file)
>> 		return -EBADF;
>> 	....
>>
>> 	psp_issue_cmd_external_user(f.file, input->cmd,
>> 				    data, &input->psp_ret);
>> 	....
>> }
>>
>> Please let me know if I understood this correctly.
>>
>>>> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
>>>> ---
>>>>  arch/x86/include/asm/kvm_host.h |    3 +
>>>>  arch/x86/kvm/x86.c              |   13 ++++
>>>>  include/uapi/linux/kvm.h        |  125
>>>>  +++++++++++++++++++++++++++++++++++++++
>>>>  3 files changed, 141 insertions(+)
>>>>
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
