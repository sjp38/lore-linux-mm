Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 795CB6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 02:29:22 -0400 (EDT)
Received: by layy10 with SMTP id y10so5741624lay.0
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 23:29:21 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id 7si5300359lai.138.2015.04.22.23.29.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Apr 2015 23:29:20 -0700 (PDT)
Message-ID: <55389133.8070701@parallels.com>
Date: Thu, 23 Apr 2015 09:29:07 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] uffd: Introduce the v2 API
References: <5509D342.7000403@parallels.com> <5509D375.7000809@parallels.com> <20150421121817.GD4481@redhat.com>
In-Reply-To: <20150421121817.GD4481@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

On 04/21/2015 03:18 PM, Andrea Arcangeli wrote:
> On Wed, Mar 18, 2015 at 10:35:17PM +0300, Pavel Emelyanov wrote:
>> +		if (!(ctx->features & UFFD_FEATURE_LONGMSG)) {
> 
> If we are to use different protocols, it'd be nicer to have two
> different methods to assign to userfaultfd_fops.read that calls an
> __always_inline function, so that the above check can be optimized
> away at build time when the inline is expanded. So the branch is
> converted to calling a different pointer to function which is zero
> additional cost.

OK :)

>> +			/* careful to always initialize addr if ret == 0 */
>> +			__u64 uninitialized_var(addr);
>> +			__u64 uninitialized_var(mtype);
>> +			if (count < sizeof(addr))
>> +				return ret ? ret : -EINVAL;
>> +			_ret = userfaultfd_ctx_read(ctx, no_wait, &mtype, &addr);
>> +			if (_ret < 0)
>> +				return ret ? ret : _ret;
>> +			BUG_ON(mtype != UFFD_PAGEFAULT);
>> +			if (put_user(addr, (__u64 __user *) buf))
>> +				return ret ? ret : -EFAULT;
>> +			_ret = sizeof(addr);
>> +		} else {
>> +			struct uffd_v2_msg msg;
>> +			if (count < sizeof(msg))
>> +				return ret ? ret : -EINVAL;
>> +			_ret = userfaultfd_ctx_read(ctx, no_wait, &msg.type, &msg.arg);
>> +			if (_ret < 0)
>> +				return ret ? ret : _ret;
>> +			if (copy_to_user(buf, &msg, sizeof(msg)))
>> +				return ret ? ret : -EINVAL;
>> +			_ret = sizeof(msg);
> 
> Reading 16bytes instead of 8bytes for each fault, probably wouldn't
> move the needle much in terms of userfaultfd_read performance. Perhaps
> we could consider using the uffd_v2_msg unconditionally and then have
> a single protocol differentiated by the feature bits.

So your proposal is to always report 16 bytes per PF from read() and
let userspace decide itself how to handle the result?

> The only reason to have two different protocols would be to be able to
> read 8 bytes per userfault, in the cooperative usage (i.e. qemu
> postcopy). But if we do that we want to use the __always_inline trick
> to avoid branches and additional runtime costs (otherwise we may as
> well forget all microoptimizations and read 16bytes always).
> 
>> @@ -992,6 +1013,12 @@ static int userfaultfd_api(struct userfaultfd_ctx *ctx,
>>  	/* careful not to leak info, we only read the first 8 bytes */
>>  	uffdio_api.bits = UFFD_API_BITS;
>>  	uffdio_api.ioctls = UFFD_API_IOCTLS;
>> +
>> +	if (uffdio_api.api == UFFD_API_V2) {
>> +		ctx->features |= UFFD_FEATURE_LONGMSG;
>> +		uffdio_api.bits |= UFFD_API_V2_BITS;
>> +	}
>> +
>>  	ret = -EFAULT;
>>  	if (copy_to_user(buf, &uffdio_api, sizeof(uffdio_api)))
>>  		goto out;
> 
> The original meaning of the bits is:
> 
> If UFFD_BIT_WRITE was set in api.bits, it means the
> !!(address&UFFD_BIT_WRITE) tells if it was a write fault (missing or
> WP).
> 
> If UFFD_BIT_WP was set in api.bits, it means the
> !!(address&UFFD_BIT_WP) tells if it was a WP fault (if not set it
> means it was a missing fault).
> 
> Currently api.bits sets only UFFD_BIT_WRITE, and UFFD_BIT_WP will be
> set later, after the WP tracking mode will be implemented.
> 
> I'm uncertain how bits translated to features and if they should be
> unified or only have features.
> 
>> +struct uffd_v2_msg {
>> +	__u64	type;
>> +	__u64	arg;
>> +};
>> +
>> +#define UFFD_PAGEFAULT	0x1
>> +
>> +#define UFFD_PAGEFAULT_BIT	(1 << (UFFD_PAGEFAULT - 1))
>> +#define __UFFD_API_V2_BITS	(UFFD_PAGEFAULT_BIT)
>> +
>> +/*
>> + * Lower PAGE_SHIFT bits are used to report those supported
>> + * by the pagefault message itself. Other bits are used to
>> + * report the message types v2 API supports
>> + */
>> +#define UFFD_API_V2_BITS	(__UFFD_API_V2_BITS << 12)
>> +
> 
> And why exactly is this 12 hardcoded?

Ah, it should have been the PAGE_SHIFT one, but I was unsure whether it
would be OK to have different shifts in different arches.

But taking into account your comment that bits field id bad for these
values, if we introduce the new .features one for api message, then this
12 will just go away.

> And which field should be masked
> with the bits? In the V1 protocol it was the "arg" (userfault address)
> not the "type". So this is a bit confusing and probably requires
> simplification.

I see. Actually I decided that since bits higher than 12th (for x86) is
always 0 in api message (no bits allowed there, since pfn sits in this
place), it would be OK to put non-PF bits there.

Should I better introduce another .features field in uffd API message?

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
