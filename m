Message-ID: <4919DD1E.2070203@redhat.com>
Date: Tue, 11 Nov 2008 21:29:34 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] ksm - dynamic page sharing driver for linux
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>	<20081111103051.979aea57.akpm@linux-foundation.org>	<4919D370.7080301@redhat.com> <20081111111110.decc0f06.akpm@linux-foundation.org>
In-Reply-To: <20081111111110.decc0f06.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ieidus@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>> For kvm, the kernel never knew those pages were shared.  They are loaded 
>> from independent (possibly compressed and encrypted) disk images.  These 
>> images are different; but some pages happen to be the same because they 
>> came from the same installation media.
>>     
>
> What userspace-only changes could fix this?  Identify the common data,
> write it to a flat file and mmap it, something like that?
>
>   

This was considered.  You can't scan the image, because it may be 
encrypted/compressed/offset (typical images _are_ offset because the 
first partition starts at sector 63...).  The data may come from the 
network and not a disk image.  You can't scan in userspace because the 
images belong to different users and contain sensitive data.  Pages may 
come from several images (multiple disk images per guest) so you end up 
with one vma per page.

So you have to scan memory, after the guest has retrieved it from 
disk/network/manufactured it somehow, decompressed and encrypted it, 
written it to the offset it wants.  You can't scan from userspace since 
it's sensitive data, and of course the actual merging need to be done 
atomically, which can only be done from the holy of holies, the vm.

>> For OpenVZ the situation is less clear, but if you allow users to 
>> independently upgrade their chroots you will eventually arrive at the 
>> same scenario (unless of course you apply the same merging strategy at 
>> the filesystem level).
>>     
>
> hm.
>
> There has been the occasional discussion about idenfifying all-zeroes
> pages and scavenging them, repointing them at the zero page.  Could
> this infrastructure be used for that?  

Yes, trivially.  ksm may be an overkill for this, though.

> (And how much would we gain from
> it?)
>   

A lot of zeros.

> [I'm looking for reasons why this is more than a muck-up-the-vm-for-kvm
> thing here ;) ]
>   

I sympathize -- us too.  Consider the typical multiuser gnome 
minicomputer with all 150 users reading lwn.net at the same time instead 
of working.  You could share the firefox rendered page cache, reducing 
memory utilization drastically.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
