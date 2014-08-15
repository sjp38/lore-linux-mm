Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id D1DFC6B0036
	for <linux-mm@kvack.org>; Fri, 15 Aug 2014 14:11:06 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so3893539pad.38
        for <linux-mm@kvack.org>; Fri, 15 Aug 2014 11:11:06 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id es5si9537769pbb.15.2014.08.15.11.11.04
        for <linux-mm@kvack.org>;
        Fri, 15 Aug 2014 11:11:05 -0700 (PDT)
Message-ID: <53EE4D11.5020001@intel.com>
Date: Fri, 15 Aug 2014 11:10:25 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2 2/2] x86: add phys addr validity check for /dev/mem
 mmap
References: <1408025927-16826-1-git-send-email-fhrbata@redhat.com> <1408103043-31015-1-git-send-email-fhrbata@redhat.com> <1408103043-31015-3-git-send-email-fhrbata@redhat.com>
In-Reply-To: <1408103043-31015-3-git-send-email-fhrbata@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

On 08/15/2014 04:44 AM, Frantisek Hrbata wrote:
> +int valid_phys_addr_range(phys_addr_t addr, size_t count)
> +{
> +	return addr + count <= __pa(high_memory);
> +}
> +
> +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
> +{
> +	return arch_pfn_possible(pfn + (count >> PAGE_SHIFT));
> +}

It definitely fixes the issue as you described it.

It's a bit unfortunate that the highmem check isn't tied in to the
_existing_ /dev/mem limitations in some way, but it's not a deal breaker
for me.

The only other thing is to make sure this doesn't add some limitation to
64-bit where we can't map things above the end of memory (end of memory
== high_memory on 64-bit).  As long as you've done this, I can't see a
downside.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
