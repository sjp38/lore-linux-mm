Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 26F846B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 02:39:49 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so100509405pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 23:39:48 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id n2si34866377pap.239.2015.09.28.23.39.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 23:39:48 -0700 (PDT)
Message-ID: <1443508783.29119.2.camel@ellerman.id.au>
Subject: Re: [PATCH 21/25] mm: implement new mprotect_key() system call
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Tue, 29 Sep 2015 16:39:43 +1000
In-Reply-To: <20150928191826.F1CD5256@viggo.jf.intel.com>
References: <20150928191817.035A64E2@viggo.jf.intel.com>
	 <20150928191826.F1CD5256@viggo.jf.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, linux-api@vger.kernel.org

On Mon, 2015-09-28 at 12:18 -0700, Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> mprotect_key() is just like mprotect, except it also takes a
> protection key as an argument.  On systems that do not support
> protection keys, it still works, but requires that key=0.

I'm not sure how userspace is going to use the key=0 feature? ie. userspace
will still have to detect that keys are not supported and use key 0 everywhere.
At that point it could just as well skip the mprotect_key() syscalls entirely
couldn't it?

> I expect it to get used like this, if you want to guarantee that
> any mapping you create can *never* be accessed without the right
> protection keys set up.
> 
> 	pkey_deny_access(11); // random pkey
> 	int real_prot = PROT_READ|PROT_WRITE;
> 	ptr = mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
> 	ret = mprotect_key(ptr, PAGE_SIZE, real_prot, 11);
> 
> This way, there is *no* window where the mapping is accessible
> since it was always either PROT_NONE or had a protection key set.
> 
> We settled on 'unsigned long' for the type of the key here.  We
> only need 4 bits on x86 today, but I figured that other
> architectures might need some more space.

If the existing mprotect() syscall had a flags argument you could have just
used that. So is it worth just adding mprotect2() now and using it for this? ie:

int mprotect2(unsigned long start, size_t len, unsigned long prot, unsigned long flags) ..

And then you define bit zero of flags to say you're passing a pkey, and it's in
bits 1-63?

That way if other arches need to do something different you at least have the
flags available?

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
