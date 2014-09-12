Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDB86B003C
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 16:33:05 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so2030767pab.12
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 13:33:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id gp10si10118635pbd.32.2014.09.12.13.33.03
        for <linux-mm@kvack.org>;
        Fri, 12 Sep 2014 13:33:04 -0700 (PDT)
Message-ID: <5413587E.4000303@intel.com>
Date: Fri, 12 Sep 2014 13:33:02 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos> <541239F1.2000508@intel.com> <alpine.DEB.2.10.1409120950260.4178@nanos> <54130F9A.3000406@intel.com> <alpine.DEB.2.10.1409121934520.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409121934520.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/12/2014 10:42 AM, Thomas Gleixner wrote:
> On Fri, 12 Sep 2014, Dave Hansen wrote:
>> The prctl(register) is meant to be a signal from userspace to the kernel
>> to say, "I would like your help in managing these bounds tables".
>> prctl(unregister) is the opposite, meaning "I don't want your help any
>> more".
> 
> Fine, but that's a totally different story. I can see the usefulness
> of this, but then it's a complete misnomer. It should be:
> 
>    prctl(EN/DISABLE_MPX_BT_MANAGEMENT)

Agreed.  Those are much better names.

> So this wants to be a boolean value and not some random user space
> address collected at some random point and then ignored until you do
> the magic cleanup. See the other reply.

I know at this point you think the kernel can not or should not keep a
copy of the bounds directory location around.  I understand that.  Bear
with me for a moment, and please just assume for a moment that we need it.

It's far from a random userspace address.  When you make a syscall, we
put the arguments in registers.  The register we're putting it in here
just happens to be used by the hardware.

Right now, we do (ignoring the actual xsave/xrstr):

	bndcfgu = bnd_dir_ptr | ENABLE_BIT;
	prctl(ENABLE_MPX_BT_MANAGEMENT); // kernel grabs from xsave buf

We could pass it explicitly in %rdi as a syscall argument and not have
the prctl() code fetch it from the xsave buffer.  I'm just not sure what
this buys us:

	bndcfgu = bnd_dir_ptr | ENABLE_BIT;
	prctl(ENABLE_MPX_BT_MANAGEMENT, bndcfgu);

Also, the "random cleanup" just happens to correspond with memory
deallocation, which is something we want to go fast.  I'd _prefer_ to
keep xsaves out of the unmap path if possible.  It's not a strict
requirement, but it does seem prudent as an xsave eats a dozen or so
cachelines.

It's also not "sampled".  I can't imagine a situation where the register
will change values during the execution of any sane program.  It really
is essentially fixed.  It's probably one of the reasons it is so
expensive to access: there's *no* reason to do it frequently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
