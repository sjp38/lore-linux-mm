Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C0ED56B03C3
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:49:52 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@hack.frob.com>
Subject: Re: Fwd: [PATCH-V2] perf symbols: fix symbol offset breakage with
 separated debug info
In-Reply-To: Dave Martin's message of  Wednesday, 13 June 2012 11:14:36 +0100 <20120613101436.GA2122@linaro.org>
References: <4FA0DBEE.3040909@linux.vnet.ibm.com>
	<4FD5D3CE.2010307@linux.vnet.ibm.com>
	<20120611135352.GA2202@infradead.org>
	<20120613101436.GA2122@linaro.org>
Message-Id: <20120625234951.B839C2C08D@topped-with-meat.com>
Date: Mon, 25 Jun 2012 16:49:51 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Martin <dave.martin@linaro.org>
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>, Prashanth Nageshappa <prashanth@linux.vnet.ibm.com>, peterz@infradead.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, ananth@in.ibm.com, jkenisto@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, oleg@redhat.com, andi@firstfloor.org, hch@infradead.org, rostedt@goodmis.org, masami.hiramatsu.pt@hitachi.com, tglx@linutronix.de, anton@redhat.com, srikar@linux.vnet.ibm.com, linux-perf-users@vger.kernel.org, mingo@elte.hu

> For one thing, I assumed that the section headers for a debug-only image
> may be bogus garbage and not useful for some aspects of symbol
> processing.  I'm no longer sure that this is the case: if not, then we
> don't need to bother with saving the section headers because once we
> have chosen a reference image for the symbols, we know that image is
> good enough for all the symbol processing.  My previous assumption
> that we may need to juggle parts of two ELF images in order to do the
> symbol processing does complicate things -- hopefully we don't need it.

The section headers in a .debug file are never "bogus garbage".  Aside
from sh_offset fields, they match the original unstripped file except
that sh_type is changed to SHT_NOBITS for each section that is kept only
in the stripped file.

The one issue you have to deal with (in ET_DYN files) is that the
addresses used in the section headers and everywhere else in the .debug
file (symbol table st_value fields, all DWARF data containing addresses,
etc.) may no longer match the addresses used in the stripped file, if
prelink has changed that file after stripping.  For this, all you need
to do is calculate the offset between .debug file and stripped-file
addresses.  The way to do that is to examine the PT_LOAD program headers
(just the first one is all you really need), and take the difference
between the p_vaddr fields of the same PT_LOAD command in the two files.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
