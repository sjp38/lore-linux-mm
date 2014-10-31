Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id CE4F5280011
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 05:09:27 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so711180wiv.8
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 02:09:27 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id gp3si5070538wib.50.2014.10.31.02.09.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 02:09:26 -0700 (PDT)
Date: Fri, 31 Oct 2014 10:09:13 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 09/12] x86, mpx: decode MPX instruction to get bound
 violation information
In-Reply-To: <5452EFF7.4090204@intel.com>
Message-ID: <alpine.DEB.2.11.1410311007230.5308@nanos>
References: <1413088915-13428-1-git-send-email-qiaowei.ren@intel.com> <1413088915-13428-10-git-send-email-qiaowei.ren@intel.com> <5452BDD8.2080605@intel.com> <5452EFF7.4090204@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ren Qiaowei <qiaowei.ren@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org

On Fri, 31 Oct 2014, Ren Qiaowei wrote:
> On 10/31/2014 06:38 AM, Dave Hansen wrote:
> > > @@ -316,6 +317,11 @@ dotraplinkage void do_bounds(struct pt_regs *regs,
> > > long error_code)
> > >   		break;
> > > 
> > >   	case 1: /* Bound violation. */
> > > +		do_mpx_bounds(regs, &info, xsave_buf);
> > > +		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs,
> > > +				error_code, &info);
> > > +		break;
> > > +
> > >   	case 0: /* No exception caused by Intel MPX operations. */
> > >   		do_trap(X86_TRAP_BR, SIGSEGV, "bounds", regs, error_code,
> > > NULL);
> > >   		break;
> > > 
> > 
> > So, siginfo is stack-allocarted here.  do_mpx_bounds() can error out if
> > it sees an invalid bndregno.  We still send the signal with the &info
> > whether or not we filled the 'info' in do_mpx_bounds().
> > 
> > Can't this leak some kernel stack out in the 'info'?
> > 
> 
> This should check the return value of do_mpx_bounds and should be fixed.

And how's that answering Dave's question about leaking stack information? 

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
