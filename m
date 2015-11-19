Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 795A76B0253
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 04:31:41 -0500 (EST)
Received: by wmvv187 with SMTP id v187so15769925wmv.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 01:31:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z76si10930572wmz.87.2015.11.19.01.31.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 01:31:40 -0800 (PST)
Subject: Re: [PATCH] mm: Loosen MADV_NOHUGEPAGE to enable Qemu postcopy on
 s390
References: <1447341516-18076-1-git-send-email-jjherne@linux.vnet.ibm.com>
 <564C7DCA.8010400@suse.cz> <564D86AE.1010305@de.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <564D96F8.2020609@suse.cz>
Date: Thu, 19 Nov 2015 10:31:36 +0100
MIME-Version: 1.0
In-Reply-To: <564D86AE.1010305@de.ibm.com>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, linux-s390@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, linux-api@vger.kernel.org, linux-man@vger.kernel.org, qemu-devel <qemu-devel@nongnu.org>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Juan Quintela <quintela@redhat.com>

On 11/19/2015 09:22 AM, Christian Borntraeger wrote:
> On 11/18/2015 02:31 PM, Vlastimil Babka wrote:
>> [CC += linux-api@vger.kernel.org]
>> Anyway, I agree that it doesn't make sense to fail madvise when the given flag
>> is already set. On the other hand, I don't think the userspace app should fail
>> just because of madvise failing? It should in general be an advice that the
>> kernel is also strictly speaking free to ignore as it shouldn't affect
>> correctnes, just performance. Yeah, there are exceptions today like
>> MADV_DONTNEED, but that shouldn't apply to hugepages?
>> So I think Qemu needs fixing too.
>
> yes, I agree. David, Juan. I think The postcopy code should not fail if the madvise.
> Can you fix that?
>
>   Also what happens if the kernel is build
>> without CONFIG_TRANSPARENT_HUGEPAGE? Then madvise also returns EINVAL,
>
> Does it? To me it looks more like we would trigger a kernel bug.
>
> mm/madvise.c:
>          case MADV_HUGEPAGE:
>          case MADV_NOHUGEPAGE:
>                  error = hugepage_madvise(vma, &new_flags, behavior);  <-----
>                  if (error)
>                          goto out;
>                  break;
>          }
>
>
> include/linux/huge_mm.h:
> static inline int hugepage_madvise(struct vm_area_struct *vma,
>                                     unsigned long *vm_flags, int advice)
> {
>          BUG();
>          return 0;
> }
>
> If we just remove the BUG() statement the code would actually be correct
> in simply ignoring an MADVISE it cannot handle. If you agree, I can
> spin a patch.

Yeah this looks suspicious at first, but the code is not reachable 
thanks to madvise_behavior_valid() returning false:

...
#ifdef CONFIG_TRANSPARENT_HUGEPAGE
         case MADV_HUGEPAGE:
         case MADV_NOHUGEPAGE:
#endif
         case MADV_DONTDUMP:
         case MADV_DODUMP:
                 return true;

         default:
                 return false;

I think the BUG() is pointless (KSM doesn't use it) but not wrong. I 
wouldn't object to removal.

>
>
>> how does Qemu handle that?
>
> The normal qemu startup ignores the return value of the madvise. Only the
> recent post migration changes want to disable huge pages for userfaultd.
> And this code checks the return value. And yes, we should change that
> in QEMU.

Great, thanks :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
