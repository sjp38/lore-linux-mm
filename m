Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C0586B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:27:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so313288827pfv.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:27:54 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id o3si27610903pav.101.2016.09.19.00.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 00:27:53 -0700 (PDT)
Subject: Re: [PATCH v2] mm, proc: Fix region lost in /proc/self/smaps
References: <1473649964-20191-1-git-send-email-guangrong.xiao@linux.intel.com>
 <20160912125447.GM14524@dhcp22.suse.cz> <57D6C332.4000409@intel.com>
 <20160912191035.GD14997@dhcp22.suse.cz> <20160913145906.GA28037@redhat.com>
 <57D8277E.80505@intel.com> <20160914153814.GA21284@redhat.com>
From: Xiao Guangrong <guangrong.xiao@linux.intel.com>
Message-ID: <7d1089c8-7921-3245-af2f-106c0c3880b4@linux.intel.com>
Date: Mon, 19 Sep 2016 15:21:56 +0800
MIME-Version: 1.0
In-Reply-To: <20160914153814.GA21284@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@kernel.org>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com



On 09/14/2016 11:38 PM, Oleg Nesterov wrote:
> On 09/13, Dave Hansen wrote:
>>
>> On 09/13/2016 07:59 AM, Oleg Nesterov wrote:
>>> I agree. I don't even understand why this was considered as a bug.
>>> Obviously, m_stop() which drops mmap_sep should not be called, or
>>> all the threads should be stopped, if you want to trust the result.
>>
>> There was a mapping at a given address.  That mapping did not change, it
>> was not split, its attributes did not change.  But, it didn't show up
>> when reading smaps.  Folks _actually_ noticed this in a test suite
>> looking for that address range in smaps.
>
> I understand, and I won't argue with any change which makes the things
> better. Just I do not think this is a real problem. And this patch can't
> fix other oddities and it seems it adds another one (at least) although
> I can easily misread this patch and/or the code.
>
> So we change m_cache_vma(),
>
> 	-        m->version = m_next_vma(m->private, vma) ? vma->vm_start : -1UL;
> 	+        m->version = m_next_vma(m->private, vma) ? vma->vm_end : -1UL;
>
> OK, and another change in m_start()
>
> 	-        if (vma && (vma = m_next_vma(priv, vma)))
> 	+        if (vma)
>
> means that it can return the same vma if it grows in between.
>
> show_map_vma() has another change
>
> 	+       start = max(vma->vm_start, start);
>
> so it will be reported as _another_ vma, and this doesn't look exactly
> right.

We noticed it in the discussion of v1, however it is not bad as Dave said
it is about 'address range' rather that vma.

>
> And after that *ppos will be falsely incremented... but probably this
> doesn't matter because the "if (pos < mm->map_count)" logic in m_start()
> looks broken anyway.

The 'broken' can happen only if it is not the first read and m->version is
zero (*ppos != 0 && m->version == 0). If i understand the code correctly,
only m->buffer overflowed can trigger this, for smaps, each vma only
uses ~1k memory that means this could not happen. Right?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
