Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEF316B0038
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 15:01:51 -0500 (EST)
Received: by wmww144 with SMTP id w144so173641308wmw.1
        for <linux-mm@kvack.org>; Wed, 11 Nov 2015 12:01:51 -0800 (PST)
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com. [195.75.94.109])
        by mx.google.com with ESMTPS id f18si14589677wmd.62.2015.11.11.12.01.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Nov 2015 12:01:50 -0800 (PST)
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Wed, 11 Nov 2015 20:01:49 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 323161B0805F
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:02:03 +0000 (GMT)
Received: from d06av11.portsmouth.uk.ibm.com (d06av11.portsmouth.uk.ibm.com [9.149.37.252])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id tABK1kBm5898594
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 20:01:46 GMT
Received: from d06av11.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av11.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id tABK1jYK027820
	for <linux-mm@kvack.org>; Wed, 11 Nov 2015 13:01:45 -0700
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
References: <1447256116-16461-1-git-send-email-jjherne@linux.vnet.ibm.com>
 <20151111173044.GF4573@redhat.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Message-ID: <56439EA8.80505@de.ibm.com>
Date: Wed, 11 Nov 2015 21:01:44 +0100
MIME-Version: 1.0
In-Reply-To: <20151111173044.GF4573@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>
Cc: linux-s390@vger.kernel.org, linux-mm@kvack.org, KVM list <kvm@vger.kernel.org>

Am 11.11.2015 um 18:30 schrieb Andrea Arcangeli:
> Hi Jason,
> 
> On Wed, Nov 11, 2015 at 10:35:16AM -0500, Jason J. Herne wrote:
>> MADV_NOHUGEPAGE processing is too restrictive. kvm already disables
>> hugepage but hugepage_madvise() takes the error path when we ask to turn
>> on the MADV_NOHUGEPAGE bit and the bit is already on. This causes Qemu's
> 
> I wonder why KVM disables transparent hugepages on s390. It sounds
> weird to disable transparent hugepages with KVM. In fact on x86 we
> call MADV_HUGEPAGE to be sure transparent hugepages are enabled on the
> guest physical memory, even if the transparent_hugepage/enabled ==
> madvise.
> 
>> new postcopy migration feature to fail on s390 because its first action is
>> to madvise the guest address space as NOHUGEPAGE. This patch modifies the
>> code so that the operation succeeds without error now.
> 
> The other way is to change qemu to keep track it already called
> MADV_NOHUGEPAGE and not to call it again. I don't have a strong
> opinion on this, I think it's ok to return 0 but it's a visible change
> to userland, I can't imagine it to break anything though. It sounds
> very unlikely that an app could error out if it notices the kernel
> doesn't error out on the second call of MADV_NOHUGEPAGE.
> 
> Glad to hear KVM postcopy live migration is already running on s390 too.

Sometimes....we have some issues with userfaultd, which we currently address.
One place is interesting: the kvm code might have to call fixup_user_fault
for a guest address (to map the page writable). Right now we do not pass
FAULT_FLAG_ALLOW_RETRY, which can trigger a warning like

[  119.414573] FAULT_FLAG_ALLOW_RETRY missing 1
[  119.414577] CPU: 42 PID: 12853 Comm: qemu-system-s39 Not tainted 4.3.0+ #315
[  119.414579]        000000011c4579b8 000000011c457a48 0000000000000002 0000000000000000 
                      000000011c457ae8 000000011c457a60 000000011c457a60 0000000000113e26 
                      00000000000002cf 00000000009feef8 0000000000a1e054 000000000000000b 
                      000000011c457aa8 000000011c457a48 0000000000000000 0000000000000000 
                      0000000000000000 0000000000113e26 000000011c457a48 000000011c457aa8 
[  119.414590] Call Trace:
[  119.414596] ([<0000000000113d16>] show_trace+0xf6/0x148)
[  119.414598]  [<0000000000113dda>] show_stack+0x72/0xf0
[  119.414600]  [<0000000000551b9e>] dump_stack+0x6e/0x90
[  119.414605]  [<000000000032d168>] handle_userfault+0xe0/0x448
[  119.414609]  [<000000000029a2d4>] handle_mm_fault+0x16e4/0x1798
[  119.414611]  [<00000000002930be>] fixup_user_fault+0x86/0x118
[  119.414614]  [<0000000000126bb8>] gmap_ipte_notify+0xa0/0x170
[  119.414617]  [<000000000013ae90>] kvm_arch_vcpu_ioctl_run+0x448/0xc58
[  119.414619]  [<000000000012e4dc>] kvm_vcpu_ioctl+0x37c/0x668
[  119.414622]  [<00000000002eba68>] do_vfs_ioctl+0x3a8/0x508
[  119.414624]  [<00000000002ebc6c>] SyS_ioctl+0xa4/0xb8
[  119.414627]  [<0000000000815c56>] system_call+0xd6/0x264
[  119.414629]  [<000003ff9628721a>] 0x3ff9628721a

I think we can rework this to use something that sets FAULT_FLAG_ALLOW_RETRY,
but this begs the question if a futex operation on userfault backed memory 
would also be broken. The futex code also does fixup_user_fault without 
FAULT_FLAG_ALLOW_RETRY as far as I can tell.

Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
