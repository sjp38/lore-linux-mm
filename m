Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 62F636B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 13:57:12 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gg9so208941252pac.6
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 10:57:12 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0062.outbound.protection.outlook.com. [104.47.38.62])
        by mx.google.com with ESMTPS id e17si28404464pgj.133.2016.10.17.10.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 17 Oct 2016 10:57:11 -0700 (PDT)
Subject: Re: [RFC PATCH v1 21/28] KVM: introduce KVM_SEV_ISSUE_CMD ioctl
References: <147190820782.9523.4967724730957229273.stgit@brijesh-build-machine>
 <147190849706.9523.17127624683768628621.stgit@brijesh-build-machine>
 <6a6e6a1a-eec8-c547-553d-7746d65fc182@redhat.com>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <59369ed7-9d35-baad-e0a9-ce4a62bc30bb@amd.com>
Date: Mon, 17 Oct 2016 12:57:00 -0500
MIME-Version: 1.0
In-Reply-To: <6a6e6a1a-eec8-c547-553d-7746d65fc182@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linus.walleij@linaro.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, devel@linuxdriverproject.org, tglx@linutronix.de, mchehab@kernel.or
Cc: brijesh.singh@amd.com

Hi Paolo,


On 10/13/2016 05:45 AM, Paolo Bonzini wrote:
>
>
> On 23/08/2016 01:28, Brijesh Singh wrote:
>> The ioctl will be used by qemu to issue the Secure Encrypted
>> Virtualization (SEV) guest commands to transition a guest into
>> into SEV-enabled mode.
>>
>> a typical usage:
>>
>> struct kvm_sev_launch_start start;
>> struct kvm_sev_issue_cmd data;
>>
>> data.cmd = KVM_SEV_LAUNCH_START;
>> data.opaque = &start;
>>
>> ret = ioctl(fd, KVM_SEV_ISSUE_CMD, &data);
>>
>> On SEV command failure, data.ret_code will contain the firmware error code.
>
> Please modify the ioctl to require the file descriptor for the PSP.  A
> program without access to /dev/psp should not be able to use SEV.
>

I am not sure if I fully understand this feedback. Let me summaries what 
we have right now.

At highest level SEV key management commands are divided into two sections:

- platform  management : commands used during platform provisioning. PSP 
drv provides ioctl's for these commands. Qemu will not use these 
ioctl's, i believe these ioctl will be used by other tools.

- guest management: command used during guest life cycle. PSP drv 
exports various function and KVM drv calls these function when it 
receives the SEV_ISSUE_CMD ioctl from qemu.

If I understanding correctly then you are recommending that instead of 
exporting various functions from PSP drv we should expose one function 
for the all the guest command handling (something like this).

int psp_issue_cmd_external_user(struct file *filep,
			    	int cmd, unsigned long addr,
			    	int *psp_ret)
{
	/* here we check to ensure that file->f_ops is a valid
	 * psp instance.
          */
	if (filep->f_ops != &psp_fops)
		return -EINVAL;

	/* handle the command */
	return psp_issue_cmd (cmd, addr, timeout, psp_ret);
}

In KVM driver use something like this to invoke the PSP command handler.

int kvm_sev_psp_cmd (struct kvm_sev_issue_cmd *input,
		     unsigned long data)
{
	int ret;
	struct fd f;

	f = fdget(input->psp_fd);
	if (!f.file)
		return -EBADF;
	....

	psp_issue_cmd_external_user(f.file, input->cmd,
				    data, &input->psp_ret);
	....
}

Please let me know if I understood this correctly.

>> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
>> ---
>>  arch/x86/include/asm/kvm_host.h |    3 +
>>  arch/x86/kvm/x86.c              |   13 ++++
>>  include/uapi/linux/kvm.h        |  125 +++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 141 insertions(+)
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
