Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E9E436B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 10:33:29 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id 1so11616601oiq.8
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 07:33:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p3si6540559ote.143.2018.02.01.07.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 07:33:28 -0800 (PST)
Date: Thu, 1 Feb 2018 16:33:10 +0100
From: Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>
Subject: Re: [PATCH] KVM/x86: remove WARN_ON() for when vm_munmap() fails
Message-ID: <20180201153310.GD31080@flask>
References: <001a1141c71c13f559055d1b28eb@google.com>
 <20180201013021.151884-1-ebiggers3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180201013021.151884-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: kvm@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, Eric Biggers <ebiggers@google.com>

2018-01-31 17:30-0800, Eric Biggers:
> From: Eric Biggers <ebiggers@google.com>
> 
> On x86, special KVM memslots such as the TSS region have anonymous
> memory mappings created on behalf of userspace, and these mappings are
> removed when the VM is destroyed.
> 
> It is however possible for removing these mappings via vm_munmap() to
> fail.  This can most easily happen if the thread receives SIGKILL while
> it's waiting to acquire ->mmap_sem.   This triggers the 'WARN_ON(r < 0)'
> in __x86_set_memory_region().  syzkaller was able to hit this, using
> 'exit()' to send the SIGKILL.  Note that while the vm_munmap() failure
> results in the mapping not being removed immediately, it is not leaked
> forever but rather will be freed when the process exits.
> 
> It's not really possible to handle this failure properly, so almost

We could check "r < 0 && r != -EINTR" to get rid of the easily
triggerable warning.

> every other caller of vm_munmap() doesn't check the return value.  It's
> a limitation of having the kernel manage these mappings rather than
> userspace.
> 
> So just remove the WARN_ON() so that users can't spam the kernel log
> with this warning.
> 
> Fixes: f0d648bdf0a5 ("KVM: x86: map/unmap private slots in __x86_set_memory_region")
> Reported-by: syzbot <syzkaller@googlegroups.com>
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> ---

Removing it altogether doesn't sound that bad, though ...
Queued, thanks.

>  arch/x86/kvm/x86.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
> index c53298dfbf50..53b57f18baec 100644
> --- a/arch/x86/kvm/x86.c
> +++ b/arch/x86/kvm/x86.c
> @@ -8272,10 +8272,8 @@ int __x86_set_memory_region(struct kvm *kvm, int id, gpa_t gpa, u32 size)
>  			return r;
>  	}
>  
> -	if (!size) {
> -		r = vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
> -		WARN_ON(r < 0);
> -	}
> +	if (!size)
> +		vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
>  
>  	return 0;
>  }
> -- 
> 2.16.0.rc1.238.g530d649a79-goog
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
