Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id CEFCF6B0036
	for <linux-mm@kvack.org>; Mon, 18 Aug 2014 07:26:53 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id j15so4344173qaq.29
        for <linux-mm@kvack.org>; Mon, 18 Aug 2014 04:26:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e1si23623861qci.27.2014.08.18.04.26.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Aug 2014 04:26:53 -0700 (PDT)
Date: Mon, 18 Aug 2014 13:26:35 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [PATCH V2 2/2] x86: add phys addr validity check for /dev/mem
 mmap
Message-ID: <20140818112635.GA3223@localhost.localdomain>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <1408025927-16826-1-git-send-email-fhrbata@redhat.com>
 <1408103043-31015-1-git-send-email-fhrbata@redhat.com>
 <1408103043-31015-3-git-send-email-fhrbata@redhat.com>
 <53EE4D11.5020001@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53EE4D11.5020001@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com

On Fri, Aug 15, 2014 at 11:10:25AM -0700, Dave Hansen wrote:
> On 08/15/2014 04:44 AM, Frantisek Hrbata wrote:
> > +int valid_phys_addr_range(phys_addr_t addr, size_t count)
> > +{
> > +	return addr + count <= __pa(high_memory);
> > +}
> > +
> > +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)
> > +{
> > +	return arch_pfn_possible(pfn + (count >> PAGE_SHIFT));
> > +}
> 
> It definitely fixes the issue as you described it.

Hi Dave,

many thanks for your time and help with this!

> 
> It's a bit unfortunate that the highmem check isn't tied in to the
> _existing_ /dev/mem limitations in some way, but it's not a deal breaker
> for me.

Agreed, I will do some more testing with the "patch" I proposed earlier in our
discussion. Meaning the one moving the high_memory check out of the
valid_phys_addr_range() to the xlate_dev_mem_ptr() for x86. IMHO this should
work fine and it should remove the high_memory limitation. But I for sure can be
missing something. If the testing goes well I will post the patch.

> 
> The only other thing is to make sure this doesn't add some limitation to
> 64-bit where we can't map things above the end of memory (end of memory
> == high_memory on 64-bit).  As long as you've done this, I can't see a
> downside.

Yes, from what I have tested, this patch should not introduce any new
limitation, except fixing the PTE problem. Also please note
that this kind of check is already done in ioremap by calling the
phys_addr_valid(). Again, I hope I haven't overlooked something.

Peter and others: Could you please consider including this fix? Of course only
if you do not have any other objections or problems with it.

Many thanks!

-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
