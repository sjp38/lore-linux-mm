Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64C8F6B0387
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 14:11:14 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 2so66339169oif.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 11:11:14 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0078.outbound.protection.outlook.com. [104.47.37.78])
        by mx.google.com with ESMTPS id a124si3778514oih.67.2017.03.02.11.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 02 Mar 2017 11:11:13 -0800 (PST)
Subject: Re: [RFC PATCH v2 19/32] crypto: ccp: Introduce the AMD Secure
 Processor device
References: <148846752022.2349.13667498174822419498.stgit@brijesh-build-machine>
 <148846777589.2349.11698765767451886038.stgit@brijesh-build-machine>
 <20170302173936.GC11970@leverpostej>
From: Brijesh Singh <brijesh.singh@amd.com>
Message-ID: <0db0055f-9208-524f-74aa-674894ee90d3@amd.com>
Date: Thu, 2 Mar 2017 13:11:04 -0600
MIME-Version: 1.0
In-Reply-To: <20170302173936.GC11970@leverpostej>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: brijesh.singh@amd.com, simon.guinot@sequanux.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, matt@codeblueprint.co.uk, linux-pci@vger.kernel.org, linus.walleij@linaro.org, gary.hook@amd.com, linux-mm@kvack.org, paul.gortmaker@windriver.com, hpa@zytor.com, cl@linux.com, dan.j.williams@intel.com, aarcange@redhat.com, sfr@canb.auug.org.au, andriy.shevchenko@linux.intel.com, herbert@gondor.apana.org.au, bhe@redhat.com, xemul@parallels.com, joro@8bytes.org, x86@kernel.org, peterz@infradead.org, piotr.luc@intel.com, mingo@redhat.com, msalter@redhat.com, ross.zwisler@linux.intel.com, bp@suse.de, dyoung@redhat.com, thomas.lendacky@amd.com, jroedel@suse.de, keescook@chromium.org, arnd@arndb.de, toshi.kani@hpe.com, mathieu.desnoyers@efficios.com, luto@kernel.org, devel@linuxdriverproject.org, bhelgaas@google.com, tglx@linutronix.de, mchehab@kernel.org, iamjoonsoo.kim@lge.com, labbott@fedoraproject.org, tony.luck@intel.com, alexandre.bounine@idt.com, kuleshovmail@gmail.com, linux-kernel@vger.kernel.org, mcgrof@kernel.org, mst@redhat.com, linux-crypto@vger.kernel.org, tj@kernel.org, pbonzini@redhat.com, akpm@linux-foundation.org, davem@davemloft.net

Hi Mark,

On 03/02/2017 11:39 AM, Mark Rutland wrote:
> On Thu, Mar 02, 2017 at 10:16:15AM -0500, Brijesh Singh wrote:
>> The CCP device is part of the AMD Secure Processor. In order to expand the
>> usage of the AMD Secure Processor, create a framework that allows functional
>> components of the AMD Secure Processor to be initialized and handled
>> appropriately.
>>
>> Signed-off-by: Brijesh Singh <brijesh.singh@amd.com>
>> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
>> ---
>>  drivers/crypto/Kconfig           |   10 +
>>  drivers/crypto/ccp/Kconfig       |   43 +++--
>>  drivers/crypto/ccp/Makefile      |    8 -
>>  drivers/crypto/ccp/ccp-dev-v3.c  |   86 +++++-----
>>  drivers/crypto/ccp/ccp-dev-v5.c  |   73 ++++-----
>>  drivers/crypto/ccp/ccp-dev.c     |  137 +++++++++-------
>>  drivers/crypto/ccp/ccp-dev.h     |   35 ----
>>  drivers/crypto/ccp/sp-dev.c      |  308 ++++++++++++++++++++++++++++++++++++
>>  drivers/crypto/ccp/sp-dev.h      |  140 ++++++++++++++++
>>  drivers/crypto/ccp/sp-pci.c      |  324 ++++++++++++++++++++++++++++++++++++++
>>  drivers/crypto/ccp/sp-platform.c |  268 +++++++++++++++++++++++++++++++
>>  include/linux/ccp.h              |    3
>>  12 files changed, 1240 insertions(+), 195 deletions(-)
>>  create mode 100644 drivers/crypto/ccp/sp-dev.c
>>  create mode 100644 drivers/crypto/ccp/sp-dev.h
>>  create mode 100644 drivers/crypto/ccp/sp-pci.c
>>  create mode 100644 drivers/crypto/ccp/sp-platform.c
>
>> diff --git a/drivers/crypto/ccp/Makefile b/drivers/crypto/ccp/Makefile
>> index 346ceb8..8127e18 100644
>> --- a/drivers/crypto/ccp/Makefile
>> +++ b/drivers/crypto/ccp/Makefile
>> @@ -1,11 +1,11 @@
>> -obj-$(CONFIG_CRYPTO_DEV_CCP_DD) += ccp.o
>> -ccp-objs := ccp-dev.o \
>> +obj-$(CONFIG_CRYPTO_DEV_SP_DD) += ccp.o
>> +ccp-objs := sp-dev.o sp-platform.o
>> +ccp-$(CONFIG_PCI) += sp-pci.o
>> +ccp-$(CONFIG_CRYPTO_DEV_CCP) += ccp-dev.o \
>>  	    ccp-ops.o \
>>  	    ccp-dev-v3.o \
>>  	    ccp-dev-v5.o \
>> -	    ccp-platform.o \
>>  	    ccp-dmaengine.o
>
> It looks like ccp-platform.c has morphed into sp-platform.c (judging by
> the compatible string and general shape of the code), and the original
> ccp-platform.c is no longer built.
>
> Shouldn't ccp-platform.c be deleted by this patch?
>

Good catch. Both ccp-platform.c and ccp-pci.c should have been deleted 
by this patch. I missed deleting it, will fix in next rev.

~ Brijesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
