Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3186B0389
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 10:45:39 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id v127so68672947qkb.5
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 07:45:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y2si6588522qta.230.2017.03.17.07.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 07:45:38 -0700 (PDT)
Subject: Re: [RFC PATCH v2 14/32] x86: mm: Provide support to use memblock
 when spliting large pages
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846771545.2349.9373586041426414252.stgit@brijesh-build-machine>
 <20170310110657.hophlog2juw5hpzz@pd.tnic>
 <cb6a9a56-2c52-d98d-3ff6-3b61d0e5875e@amd.com>
 <20170316182836.tyvxoeq56thtc4pd@pd.tnic>
 <ec134379-6a48-905c-26e4-f6f2738814dc@redhat.com>
 <20170317101737.icdois7sdmtutt6b@pd.tnic>
 <b6f9f46c-58c4-a19c-4955-2d07bd411443@redhat.com>
 <20170317105610.musvo4baokgssvye@pd.tnic>
 <78c99889-f175-f60f-716b-34a62203418a@redhat.com>
 <20170317113337.syvpat3c4s2l4nuz@pd.tnic>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <b516a873-029a-b20a-3c43-d8bf4a200cb7@redhat.com>
Date: Fri, 17 Mar 2017 15:45:26 +0100
MIME-Version: 1.0
In-Reply-To: <20170317113337.syvpat3c4s2l4nuz@pd.tnic>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@suse.de>
Cc: Brijesh Singh <brijesh.singh@amd.com>, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org



On 17/03/2017 12:33, Borislav Petkov wrote:
> On Fri, Mar 17, 2017 at 12:03:31PM +0100, Paolo Bonzini wrote:
> 
>> If it is possible to do it in a fairly hypervisor-independent manner,
>> I'm all for it.  That is, only by looking at AMD-specified CPUID leaves
>> and at kernel ELF sections.
> 
> Not even that.
> 
> What that needs to be able to do is:
> 
> 	kvm_map_percpu_hv_shared(st, sizeof(*st)))
> 
> where st is the percpu steal time ptr:
> 
> 	struct kvm_steal_time *st = &per_cpu(steal_time, cpu);
> 
> Underneath, what it does basically is it clears the encryption mask from
> the pte, see patch 16/32.

Yes, and I'd like that to be done with a new data section rather than a
special KVM hook.

> And I keep talking about SEV-ES because this is going to expand on the
> need of having a shared memory region which the hypervisor and the guest
> needs to access, thus unencrypted. See
> 
> http://support.amd.com/TechDocs/Protecting%20VM%20Register%20State%20with%20SEV-ES.pdf
> 
> This is where you come in and say what would be the best approach there...

I have no idea.  SEV-ES seems to be very hard to set up at the beginning
of the kernel bootstrap.  There's all sorts of chicken and egg problems,
as well as complicated handshakes between the firmware and the guest,
and the way to do it also depends on the trust and threat models.

A much simpler way is to just boot under a trusted hypervisor, do
"modprobe sev-es" and save a snapshot of the guest.  Then you sign the
snapshot and pass it to your cloud provider.

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
