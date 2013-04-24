Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 8BFA56B0002
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 07:37:00 -0400 (EDT)
Date: Wed, 24 Apr 2013 13:36:52 +0200
From: Frantisek Hrbata <fhrbata@redhat.com>
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
Message-ID: <20130424113652.GC3358@dhcp-26-164.brq.redhat.com>
Reply-To: Frantisek Hrbata <fhrbata@redhat.com>
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com>
 <515B2802.1050405@zytor.com>
 <20130402191012.GC3314@dhcp-26-164.brq.redhat.com>
 <515B3F98.5020101@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515B3F98.5020101@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

On Tue, Apr 02, 2013 at 01:29:12PM -0700, H. Peter Anvin wrote:
> On 04/02/2013 12:10 PM, Frantisek Hrbata wrote:
> > 
> > Hi, this is exactly what the patch is doing imho. Note that the
> > valid_phys_addr_range(), which is using the high_memory, is the same as the
> > default one in drivers/char/mem.c(#ifndef ARCH_HAS_VALID_PHYS_ADDR_RANGE). I
> > just added x86 specific check for valid_mmap_phys_addr_range and moved both
> > functions to arch/x86/mm/mmap.c, rather then modifying the default generic ones.
> > This is how other archs(arm) are doing it.
> > 
> > Also valid_phys_addr_range is used just in read|write_mem and
> > valid_mmap_phys_addr_range is checked in mmap_mem and it calls phys_addr_valid
> > 
> > static inline int phys_addr_valid(resource_size_t addr)
> > {
> > #ifdef CONFIG_PHYS_ADDR_T_64BIT
> > 	return !(addr >> boot_cpu_data.x86_phys_bits);
> > #else
> >         return 1;
> > #endif
> > }                          
> > 
> > I for sure could overlooked something, but this seems right to me.
> > 
> 
> OK, this is really confusing ... which isn't a *huge* surprise (the
> entire /dev/mem code has some gigantic bugs in it.)
> 
> I think I need to do more of an in-depth review.  The other question is
> why we don't call phys_addr_valid() everywhere.
> 
> 	-hpa

Hi Peter,

please, have you had a chance to look at this?

Many thanks

> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Frantisek Hrbata

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
