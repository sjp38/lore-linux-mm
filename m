Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4B80B6B003C
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:36:18 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so2004969pad.23
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:36:18 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id fw9si9910900pdb.187.2014.09.12.13.36.17
        for <linux-mm@kvack.org>;
        Fri, 12 Sep 2014 13:36:17 -0700 (PDT)
Message-ID: <54135900.6010606@intel.com>
Date: Fri, 12 Sep 2014 13:35:12 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos> <541239F1.2000508@intel.com> <alpine.DEB.2.10.1409120950260.4178@nanos> <alpine.DEB.2.10.1409121120440.4178@nanos> <5413050A.1090307@intel.com> <alpine.DEB.2.10.1409121812550.4178@nanos> <alpine.DEB.2.10.1409122038590.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409122038590.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/12/2014 11:42 AM, Thomas Gleixner wrote:
> On Fri, 12 Sep 2014, Thomas Gleixner wrote:
>> On Fri, 12 Sep 2014, Dave Hansen wrote:
>> The proper solution to this problem is:
>>
>>     do_bounds()
>> 	bd_addr = get_bd_addr_from_xsave();
>> 	bd_entry = bndstatus & ADDR_MASK:
> 
> Just for clarification. You CANNOT avoid the xsave here because it's
> the only way to access BNDSTATUS according to the manual.
> 
> "The BNDCFGU and BNDSTATUS registers are accessible only with
>  XSAVE/XRSTOR family of instructions"
> 
> So there is no point to cache BNDCFGU as you get it anyway when you
> need to retrieve the invalid BD entry.

Agreed.  It serves no purpose during a bounds fault.

However, it does keep you from having to do an xsave during the bounds
table free operations, like at unmap() time.  That is actually a much
more critical path than bounds faults.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
