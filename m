Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [ PATCH ] - Avoid slow TLB purges on SGI Altix systems
Date: Thu, 27 Oct 2005 11:41:13 -0700
Message-ID: <B8E391BBE9FE384DAA4C5C003888BE6F04CC08DF@scsmsx401.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dean Roe <roe@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>flush_tlb_range() only calls platform_global_tlb_purge() for CONFIG_SMP,
>so there's no point in having that code in ia64_global_tlb_purge().

So you have dropped the "mm->context = 0;" for the UP case (and replaced
it with a series of ia64_ptcl() calls).

To maintain the old behaivour you need to have:

#ifndef SMP
	if (mm != current->active_mm) {
		mm->context = 0;
		return;
	}
#endif

in the start of flush_tlb_range().


-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
