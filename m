Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id CEA3F6B0072
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:37:19 -0400 (EDT)
Received: by qgh62 with SMTP id 62so45020249qgh.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:37:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a17si10403434qkh.61.2015.03.16.09.37.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Mar 2015 09:37:19 -0700 (PDT)
Date: Mon, 16 Mar 2015 17:35:21 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm: rcu-protected get_mm_exe_file()
Message-ID: <20150316163521.GA9306@redhat.com>
References: <20150316131257.32340.36600.stgit@buzz> <20150316140720.GA1859@redhat.com> <550701BE.40100@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <550701BE.40100@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>, Al Viro <viro@zeniv.linux.org.uk>

On 03/16, Konstantin Khlebnikov wrote:
>
> On 16.03.2015 17:07, Oleg Nesterov wrote:
>> I mean, I think we can do another cleanup on top of this change.
>>
>> 	1. set_mm_exe_file() should be called by exit/exec only, so
>> 	   it should use
>>
>> 		rcu_dereference_protected(mm->exe_file,
>> 					atomic_read(&mm->mm_users) <= 1);
>>
>> 	2. prctl() should not use it, it can do
>>
>> 	   get_file(new_exe);
>> 	   old_exe = xchg(&mm->exe_file);
>> 	   if (old_exe)
>> 	   	fput(old_exe);
>
> I think smp_mb() is required before xchg() or
> probably this stuff should be hidden inside yet another magic RCU macro
> ( with two screens of comments =)

Not really, xchg() implies mb's on both sides. As any other atomic operation
which returns the result.

(And in fact we do not even need rcu_assign_pointer() in set_mm_exe_file(),
 get_mm_exe_file() could do READ_ONCE() + inc_not_zero(). But this is off-
 topic, and of course rcu_* helpers look better)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
