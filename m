Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2965A440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:04:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s70so61201140pfs.5
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 10:04:25 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s71si4495787pfk.12.2017.07.13.10.04.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 10:04:23 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6DGwcY5105623
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:04:23 -0400
Received: from e11.ny.us.ibm.com (e11.ny.us.ibm.com [129.33.205.201])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bpb4m4v8x-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:04:23 -0400
Received: from localhost
	by e11.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 13 Jul 2017 13:04:21 -0400
Date: Thu, 13 Jul 2017 10:04:11 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v5 34/38] procfs: display the protection-key number
 associated with a vma
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-35-git-send-email-linuxram@us.ibm.com>
 <8b0827c9-9fc9-c2d5-d1a5-52d9eef8965e@intel.com>
 <20170713080348.GH5525@ram.oc3035372033.ibm.com>
 <e3355a7a-8899-b69d-968a-6862c29633a2@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e3355a7a-8899-b69d-968a-6862c29633a2@intel.com>
Message-Id: <20170713170411.GI5525@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Thu, Jul 13, 2017 at 07:07:48AM -0700, Dave Hansen wrote:
> On 07/13/2017 01:03 AM, Ram Pai wrote:
> > On Tue, Jul 11, 2017 at 11:13:56AM -0700, Dave Hansen wrote:
> >> On 07/05/2017 02:22 PM, Ram Pai wrote:
> >>> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> >>> +void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> >>> +{
> >>> +	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> >>> +}
> >>> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> >>
> >> This seems like kinda silly unnecessary duplication.  Could we just put
> >> this in the fs/proc/ code and #ifdef it on ARCH_HAS_PKEYS?
> > 
> > Well x86 predicates it based on availability of X86_FEATURE_OSPKE.
> > 
> > powerpc doesn't need that check or any similar check. So trying to
> > generalize the code does not save much IMHO.
> 
> I know all your hardware doesn't support it. :)

Wow! you bring a good point which I had not considered yet. I need some
runtime checks for RPT.

But regardless, my above statement is still partially true. x86
predicates it based on availability of X86_FEATURE_OSPKE, and powerpc
should predicate it based on HPT. So we have our own
customized checks. Hence a unified function won't suffice.

> 
> So, for instance, if you are running on a new POWER9 with radix page
> tables, you will just always output "ProtectionKey: 0" in every VMA,
> regardless?
> 
> > maybe have a seperate inline function that does
> > seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> > and is called from x86 and powerpc's arch_show_smap()?
> > At least will keep the string format captured in 
> > one single place.
> 
> Now that we have two architectures, is there a strong reason we can't
> just have an arch_pkeys_enabled(), and stick the seq_printf() back in
> generic code?

correct. that looks like the correct approach. Was trying to avoid
touching arch neutral code. But this approach will force me
do so. Will do.

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
