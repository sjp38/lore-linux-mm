Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C0C3B440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:08:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p15so59356658pgs.7
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 07:08:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id h3si4262547pfc.115.2017.07.13.07.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 07:08:09 -0700 (PDT)
Subject: Re: [RFC v5 34/38] procfs: display the protection-key number
 associated with a vma
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
 <8b0827c9-9fc9-c2d5-d1a5-52d9eef8965e@intel.com>
 <20170713080348.GH5525@ram.oc3035372033.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e3355a7a-8899-b69d-968a-6862c29633a2@intel.com>
Date: Thu, 13 Jul 2017 07:07:48 -0700
MIME-Version: 1.0
In-Reply-To: <20170713080348.GH5525@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/13/2017 01:03 AM, Ram Pai wrote:
> On Tue, Jul 11, 2017 at 11:13:56AM -0700, Dave Hansen wrote:
>> On 07/05/2017 02:22 PM, Ram Pai wrote:
>>> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
>>> +void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
>>> +{
>>> +	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
>>> +}
>>> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
>>
>> This seems like kinda silly unnecessary duplication.  Could we just put
>> this in the fs/proc/ code and #ifdef it on ARCH_HAS_PKEYS?
> 
> Well x86 predicates it based on availability of X86_FEATURE_OSPKE.
> 
> powerpc doesn't need that check or any similar check. So trying to
> generalize the code does not save much IMHO.

I know all your hardware doesn't support it. :)

So, for instance, if you are running on a new POWER9 with radix page
tables, you will just always output "ProtectionKey: 0" in every VMA,
regardless?

> maybe have a seperate inline function that does
> seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> and is called from x86 and powerpc's arch_show_smap()?
> At least will keep the string format captured in 
> one single place.

Now that we have two architectures, is there a strong reason we can't
just have an arch_pkeys_enabled(), and stick the seq_printf() back in
generic code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
