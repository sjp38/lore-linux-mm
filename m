Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 34B806B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 20:10:28 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id ft15so12239591pdb.11
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 17:10:27 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id kf2si4428516pad.177.2014.09.11.17.10.26
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 17:10:26 -0700 (PDT)
Message-ID: <541239F1.2000508@intel.com>
Date: Thu, 11 Sep 2014 17:10:25 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409120020060.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 04:28 PM, Thomas Gleixner wrote:
> On Thu, 11 Sep 2014, Qiaowei Ren wrote:
>> This patch adds the PR_MPX_REGISTER and PR_MPX_UNREGISTER prctl()
>> commands. These commands can be used to register and unregister MPX
>> related resource on the x86 platform.
> 
> I cant see anything which is registered/unregistered.

This registers the location of the bounds directory with the kernel.

>From the app's perspective, it says "I'm using MPX, and here is where I
put the root data structure".

Without this, the kernel would have to do an (expensive) xsave operation
every time it wanted to see if MPX was in use.  This also makes the
user/kernel interaction more explicit.  We would be in a world of hurt
if userspace was allowed to move the bounds directory around.  With this
interface, it's a bit more obvious that userspace can't just move it
around willy-nilly.

>> The base of the bounds directory is set into mm_struct during
>> PR_MPX_REGISTER command execution. This member can be used to
>> check whether one application is mpx enabled.
> 
> This changelog is completely useless.

Yeah, it's pretty bare-bones.  Let me know if the explanation above
makes sense, and we'll get it updated.

>> +/*
>> + * This should only be called when cpuid has been checked
>> + * and we are sure that MPX is available.
> 
> Groan. Why can't you put that cpuid check into that function right
> away instead of adding a worthless comment?

Sounds reasonable to me.  We should just move the cpuid check in to
task_get_bounds_dir().

>> + */
>> +static __user void *task_get_bounds_dir(struct task_struct *tsk)
>> +{
>> +	struct xsave_struct *xsave_buf;
>> +
>> +	fpu_xsave(&tsk->thread.fpu);
>> +	xsave_buf = &(tsk->thread.fpu.state->xsave);
>> +	if (!(xsave_buf->bndcsr.cfg_reg_u & MPX_BNDCFG_ENABLE_FLAG))
>> +		return NULL;
> 
> Now this might be understandable with a proper comment. Right now it's
> a magic check for something uncomprehensible.

It's a bit ugly to access, but it seems pretty blatantly obvious that
this is a check for "Is the enable flag in a hardware register set?"

Yes, the registers have names only a mother could love.  But that is
what they're really called.

I guess we could add some comments about why we need to do the xsave.

>> +int mpx_register(struct task_struct *tsk)
>> +{
>> +	struct mm_struct *mm = tsk->mm;
>> +
>> +	if (!cpu_has_mpx)
>> +		return -EINVAL;
>> +
>> +	/*
>> +	 * runtime in the userspace will be responsible for allocation of
>> +	 * the bounds directory. Then, it will save the base of the bounds
>> +	 * directory into XSAVE/XRSTOR Save Area and enable MPX through
>> +	 * XRSTOR instruction.
>> +	 *
>> +	 * fpu_xsave() is expected to be very expensive. In order to do
>> +	 * performance optimization, here we get the base of the bounds
>> +	 * directory and then save it into mm_struct to be used in future.
>> +	 */
> 
> Ah. Now we get some information what this might do. But that does not
> make any sense at all.
> 
> So all it does is:
> 
>     tsk->mm.bd_addr = xsave_buf->bndcsr.cfg_reg_u & MPX_BNDCFG_ADDR_MASK;
> 
> or:
> 
>     tsk->mm.bd_addr = NULL;
> 
> So we use that information to check, whether we need to tear down a
> VM_MPX flagged region with mpx_unmap(), right?

Well, we use it to figure out whether we _potentially_ need to tear down
an VM_MPX-flagged area.  There's no guarantee that there will be one.

>> +         /*
>> +          * Check whether this vma comes from MPX-enabled application.
>> +          * If so, release this vma related bound tables.
>> +          */
>> +         if (mm->bd_addr && !(vma->vm_flags & VM_MPX))
>> +                 mpx_unmap(mm, start, end);
> 
> You really must be kidding. The application maps that table and never
> calls that prctl so do_unmap() will happily ignore it?

Yes.  The only other way the kernel can possibly know that it needs to
go tearing things down is with a potentially frequent and expensive xsave.

Either we change mmap to say "this mmap() is for a bounds directory", or
we have some other interface that says "the mmap() for the bounds
directory is at $foo".  We could also record the bounds directory the
first time that we catch userspace using it.  I'd rather have an
explicit interface than an implicit one like that, though I don't feel
that strongly about it.

> The design to support this feature makes no sense at all to me. We
> have a special mmap interface, some magic kernel side mapping
> functionality and then on top of it a prctl telling the kernel to
> ignore/respect it.

That's a good point.  We don't seem to have anything in the
allocate_bt() side of things to tell the kernel to refuse to create
things if the prctl() hasn't been called.  That needs to get added.

> All I have seen so far is the hint to read some intel feature
> documentation, but no coherent explanation how this patch set makes
> use of that very feature. The last patch in the series does not count
> as coherent explanation. It merily documents parts of the
> implementation details which are required to make use of it but
> completely lacks of a coherent description how all of this is supposed
> to work.

It sounds like we need to take the patch00 plus the documentation patch
and try to lay things out more clearly.

> Despite the fact that this is V8, I can't suppress the feeling that
> this is just cobbled together to make it work somehow and we'll deal
> with the fallout later.

It's v8, but it's been very lightly reviewed.  I do appreciate the
review at this point, though.

> I wouldn't be surprised if some of the fallout
> is going to be security related. I have a pretty good idea how to
> exploit it even without understanding the non-malicious intent of the
> whole thing.

If you don't want to share them in public, I'm happy to take this
off-list, but please do share.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
