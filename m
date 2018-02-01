Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9816B0003
	for <linux-mm@kvack.org>; Thu,  1 Feb 2018 12:12:11 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id h12so12643873oti.16
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 09:12:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s35si18077otc.46.2018.02.01.09.12.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 09:12:10 -0800 (PST)
Subject: Re: [PATCH] KVM/x86: remove WARN_ON() for when vm_munmap() fails
References: <001a1141c71c13f559055d1b28eb@google.com>
 <20180201013021.151884-1-ebiggers3@gmail.com> <20180201153310.GD31080@flask>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <584ef475-21cc-9ef5-8ac9-d6b00e93134e@redhat.com>
Date: Thu, 1 Feb 2018 12:12:00 -0500
MIME-Version: 1.0
In-Reply-To: <20180201153310.GD31080@flask>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Eric Biggers <ebiggers3@gmail.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, Eric Biggers <ebiggers@google.com>

On 01/02/2018 10:33, Radim KrA?mA!A? wrote:
> 2018-01-31 17:30-0800, Eric Biggers:
>> From: Eric Biggers <ebiggers@google.com>
>>
>> On x86, special KVM memslots such as the TSS region have anonymous
>> memory mappings created on behalf of userspace, and these mappings are
>> removed when the VM is destroyed.
>>
>> It is however possible for removing these mappings via vm_munmap() to
>> fail.  This can most easily happen if the thread receives SIGKILL while
>> it's waiting to acquire ->mmap_sem.   This triggers the 'WARN_ON(r < 0)'
>> in __x86_set_memory_region().  syzkaller was able to hit this, using
>> 'exit()' to send the SIGKILL.  Note that while the vm_munmap() failure
>> results in the mapping not being removed immediately, it is not leaked
>> forever but rather will be freed when the process exits.
>>
>> It's not really possible to handle this failure properly, so almost
> 
> We could check "r < 0 && r != -EINTR" to get rid of the easily
> triggerable warning.

Considering that vm_munmap uses down_write_killable, that would be
preferrable I think.

Paolo

>> every other caller of vm_munmap() doesn't check the return value.  It's
>> a limitation of having the kernel manage these mappings rather than
>> userspace.
>>
>> So just remove the WARN_ON() so that users can't spam the kernel log
>> with this warning.
>>
>> Fixes: f0d648bdf0a5 ("KVM: x86: map/unmap private slots in __x86_set_memory_region")
>> Reported-by: syzbot <syzkaller@googlegroups.com>
>> Signed-off-by: Eric Biggers <ebiggers@google.com>
>> ---
> 
> Removing it altogether doesn't sound that bad, though ...
> Queued, thanks.
> 
>>  arch/x86/kvm/x86.c | 6 ++----
>>  1 file changed, 2 insertions(+), 4 deletions(-)
>>
>> diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
>> index c53298dfbf50..53b57f18baec 100644
>> --- a/arch/x86/kvm/x86.c
>> +++ b/arch/x86/kvm/x86.c
>> @@ -8272,10 +8272,8 @@ int __x86_set_memory_region(struct kvm *kvm, int id, gpa_t gpa, u32 size)
>>  			return r;
>>  	}
>>  
>> -	if (!size) {
>> -		r = vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
>> -		WARN_ON(r < 0);
>> -	}
>> +	if (!size)
>> +		vm_munmap(old.userspace_addr, old.npages * PAGE_SIZE);
>>  
>>  	return 0;
>>  }
>> -- 
>> 2.16.0.rc1.238.g530d649a79-goog
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
