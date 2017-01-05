Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 302AA6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 16:06:48 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id i68so422370175uad.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 13:06:48 -0800 (PST)
Received: from mail-ua0-x229.google.com (mail-ua0-x229.google.com. [2607:f8b0:400c:c08::229])
        by mx.google.com with ESMTPS id f127si236192vkd.34.2017.01.05.13.06.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 13:06:47 -0800 (PST)
Received: by mail-ua0-x229.google.com with SMTP id 34so349918697uac.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 13:06:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105150558.GE17319@node.shutemov.name>
References: <20170105053658.GA36383@juliacomputing.com> <20170105150558.GE17319@node.shutemov.name>
From: Keno Fischer <keno@juliacomputing.com>
Date: Thu, 5 Jan 2017 16:06:06 -0500
Message-ID: <CABV8kRwUvNjyYPc3+yjQ6pzXoJj9HM3K4Mq_1cZc9sWzpjPEzQ@mail.gmail.com>
Subject: Re: [PATCH] mm: Respect FOLL_FORCE/FOLL_COW for thp
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Greg Thelen <gthelen@google.com>, npiggin@gmail.com, Willy Tarreau <w@1wt.eu>, Oleg Nesterov <oleg@redhat.com>, Kees Cook <keescook@chromium.org>, luto@kernel.org, mhocko@suse.com, Hugh Dickins <hughd@google.com>

>> @@ -783,7 +793,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
>>
>>       assert_spin_locked(pmd_lockptr(mm, pmd));
>>
>> -     if (flags & FOLL_WRITE && !pmd_write(*pmd))
>> +     if (flags & FOLL_WRITE && !can_follow_write_pmd(*pmd, flags))
>>               return NULL;
>
> I don't think this part is needed: once we COW devmap PMD entry, we split
> it into PTE table, so IIUC we never get here with PMD.
>
> Maybe we should WARN_ONCE() if have FOLL_COW here.

Sounds good to me. As I said, I don't have a testcase for this code
path, I just noticed the same pattern.
Will send an updated patch with the WARN_ONCE there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
